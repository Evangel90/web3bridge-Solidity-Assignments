// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import {SchoolToken} from './SchoolToken.sol';

contract SMS{
    SchoolToken token;

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

    // struct Receipt{
    //     uint256 amount;
    //     uint256 timestamp;
    // }

    mapping (uint64 => uint256) public schoolFeesPerLevel;
    // mapping (address => Receipt) public paymentReceipt;

    Student[] private students;
    Staff[] private staffs;

    constructor(address _token){
        token = SchoolToken(_token);

        schoolFeesPerLevel[100] = 500;
        schoolFeesPerLevel[200] = 1000;
        schoolFeesPerLevel[300] = 1500;
        schoolFeesPerLevel[400] = 2000;
    }

    function getAllStudents() external view returns(Student[] memory) {
        return students;
    }

    function getAllStaff() external view returns(Staff[] memory) {
        return staffs;
    }

    function register(uint256 amount, uint8 studentLevel) public payable returns(bool) {
        require(token.allowance(msg.sender, address(this)) >= amount, "Allowance not sufficient");
        require(amount == schoolFeesPerLevel[studentLevel], "Not appropriate fee for level");

        token.transferFrom(msg.sender, address(this), amount);
        Student memory student;

        student.studentAddress = msg.sender;
        student.feePaid = true;
        student.level = studentLevel;
        student.paymentTimestamp = block.timestamp;
        students.push(student);

        return true;
    }

    function payStaff(uint amount, address staff) public {
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");

        for(uint i = 0; i < staffs.length; i++){
            if(staff == staffs[i].staffAddress && !staffs[i].salaryPaid){
                staffs[i].salaryPaid = true;
                token.transfer(staff, amount);
                break;
            }
        }
    }

    receive() external payable{}
    fallback() external {}

}