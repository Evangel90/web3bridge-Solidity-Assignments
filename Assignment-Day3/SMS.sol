// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {SchoolToken} from 'contracts/SchoolToken.sol';

contract SMS{
    SchoolToken token;
    address admin;

    struct Student{
        address studentAddress;
        uint8 level;
        bool feePaid;
        uint256 paymentTimestamp;
    }

    struct Staff{
        address staffAddress;
        bool salaryPaid;
    }

    mapping (uint64 => uint256) public schoolFeesPerLevel;
    mapping (address => Student) public registeredStudents;
    mapping (address => Staff) public registeredStaffs;

    address[] private studentsAddress;
    address[] private staffsAddress;

    event studentRegistered(address indexed student, uint indexed feePaid);
    event staffRegistered(address indexed staff);
    event staffPaid(address indexed staff, uint indexed amountPaid);

    constructor(address _token, address _admin){
        token = SchoolToken(_token);
        admin = _admin;

        schoolFeesPerLevel[100] = 500;
        schoolFeesPerLevel[200] = 1000;
        schoolFeesPerLevel[300] = 1500;
        schoolFeesPerLevel[400] = 2000;
    }

    function getAllStudents() external view returns(address[] memory) {
        return studentsAddress;
    }

    function getAllStaff() external view returns(address[] memory) {
        return staffsAddress;
    }

    function register(uint256 amount, uint8 studentLevel) public payable returns(bool) {
        require(token.allowance(msg.sender, address(this)) >= amount, "Allowance not sufficient");
        require(amount == schoolFeesPerLevel[studentLevel], "Not appropriate fee for level");
        require(!registeredStudents[msg.sender].feePaid, "Student already registered");

        token.transferFrom(msg.sender, address(this), amount);
        Student memory student;

        student.studentAddress = msg.sender;
        student.feePaid = true;
        student.level = studentLevel;
        student.paymentTimestamp = block.timestamp;
        registeredStudents[msg.sender] = student;
        studentsAddress.push(msg.sender);

        emit studentRegistered(msg.sender, amount);

        return true;
    }

    function registerStaff(address _staff) public returns(bool) {
        require(msg.sender == admin, "Unauthorized");
        require(registeredStaffs[_staff].staffAddress == address(0), "already registered");

        Staff memory staff;
        staff.staffAddress = _staff;
        staff.salaryPaid = false;
        registeredStaffs[_staff] = staff;

        emit staffRegistered(_staff);

        return true;
    }

    function payStaff(uint amount, address staff) public returns(bool) {
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        require(!registeredStaffs[staff].salaryPaid, "Not eligible for payment");

        registeredStaffs[staff].salaryPaid = true;
        token.transfer(staff, amount);

        emit staffPaid(staff, amount);
        
        return true;
    }

    receive() external payable{}
    fallback() external {}

}