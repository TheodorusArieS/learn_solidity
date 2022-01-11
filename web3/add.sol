// SPDX-License-Identifier: GPL-3.0


pragma solidity 0.8.11;

contract Add{
    uint sum;
    function Sum(uint _num1,uint _num2) public {
        sum = _num1 + _num2;
        
    }

    function getSum() public view returns(uint){
        return sum;
    }

}