// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

contract Lottery{
    address payable[]  public players;
    address public manager;

    constructor(){
        manager = msg.sender;
        // challenge 2, make manager always included in the lottery without sending ether
        players.push(payable(manager));


    }

    receive() external payable{
        require(msg.value == 0.001 ether);
        //challenge 1, make manager cannot participate in the lottery
        require(msg.sender != manager);
        players.push(payable(msg.sender));
    }

    function getBalace() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance;
    }

    function random()public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,players.length)));

    }

    function getPlayerLength() public view returns(uint){
        return players.length;
    }

    function getLotteryWinner() public {
        require(msg.sender == manager);
        require(players.length >= 3);
        uint r = random();
        address payable winner;
        uint index = r % players.length;
        winner = players[index];
        winner.transfer(getBalace()); // transfer contract balance to winner address
        players = new address payable[](0); // reseting the lottery

    }

    
}