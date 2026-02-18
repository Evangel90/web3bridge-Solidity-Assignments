// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "../Assignment-1/ERC20.sol";

contract Save {
    ERC20 public token;

    mapping(address => uint) private etherBalances;
    mapping(address => uint) private erc20Balances;

    event DepositEther(address indexed user, uint amount, string assetType);
    event DepositERC20(address indexed user, uint amount, string assetType);
    event WithdrawalEther(address indexed user, uint amount, string assetType);
    event WithdrawalERC20(address indexed user, uint amount, string assetType);
    event AllowanceApproved(address indexed user, uint amount);

    function depositEther() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        etherBalances[msg.sender] = etherBalances[msg.sender] +msg.value;
        emit DepositEther(msg.sender, msg.value, "ETH");
    }

    function allowanceApproveERC20(uint amount) public {
        token.approve(address(this), amount);
        emit AllowanceApproved(msg.sender, amount);
    }

    function depositERC20(uint amount) public {
        require(token.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(token.allowance(msg.sender, address(this)) >= amount, "Allowance not sufficient");
        token.transferFrom(msg.sender, address(this), amount);
        erc20Balances[msg.sender] = erc20Balances[msg.sender] + amount;
        emit DepositERC20(msg.sender, amount, "ERC20");
    }

    function withdrawEther(uint amount) public {
        require(etherBalances[msg.sender] >= amount, "Insufficient balance");
        etherBalances[msg.sender] = etherBalances[msg.sender] - amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Ether transfer failed");
        emit WithdrawalEther(msg.sender, amount, "ETH");
    }

    function withdrawERC20(uint amount) public {
        require(erc20Balances[msg.sender] >= amount, "Insufficient balance");
        erc20Balances[msg.sender] = erc20Balances[msg.sender] - amount;
        token.transfer(msg.sender, amount);
        emit WithdrawalERC20(msg.sender, amount, "ERC20");
    }

    function checkEtherBalance(address user) external view returns(uint) {
        return etherBalances[user];
    }

    function checkERC20Balance(address user) external view returns(uint) {
        return erc20Balances[user];
    }

    receive() external payable {}
    fallback() external {}

}
