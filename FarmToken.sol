// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FarmToken is ERC20{
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;
    constructor(address _token)ERC20("FarmToken","FRMT"){
        token  = IERC20(_token);
    }

    function balance() public view returns(uint256){
        return token.balanceOf(address(this));
    }

    function deposit(uint256 _amount )public{
        require(_amount > 0,"Amount cannot be 0");
        token.safeTransferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender,_amount);
    }

    function withdraw(uint256 _withdraw) public {
        _burn(msg.sender,_withdraw);
        token.safeTransfer(msg.sender, _withdraw);
    }

    function totalSup() public view returns(uint256){
        return token.totalSupply();
    }

}