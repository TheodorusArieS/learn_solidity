// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
//test

contract MyStakeToken is ERC20, Ownable{
    using SafeMath for uint256;
    
    constructor(uint256 _supply) ERC20("MyStakeToken","MST") {
        
        _mint(owner(),_supply);
    }


    address[] internal stakeholders;
    mapping(address=>uint256) internal stakes;
    mapping(address=>uint256) internal rewards;

    //function to check is stakeholder or not without checking to the blockchain
    function isStakeHolder(address _address) public view returns(bool,uint256){

        for(uint256 s=0; s <stakeholders.length;s++){
            if(stakeholders[s] == _address) return (true,s);
        }

        return (false,0);

    }

    //function to add the stakeholder
    function addStakeholder(address _stakeholder) public {

        (bool _isStakeholder,) = isStakeHolder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }


    //function to remove the stakeholder
    function removeStakeholder(address _stakeholder) public {

        (bool _isStakeholder,uint256 index) = isStakeHolder(_stakeholder);
        if(_isStakeholder){
            stakeholders[index] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }

    }

    //retrieve the amount of stake of an address
    function stakeOf(address _stakeholder) public view returns(uint256) {

        return stakes[_stakeholder];

    }

    function totalStakes() public view returns(uint256){
        
        uint256 _totalStakes = 0;

        for(uint256 s = 0;s<stakeholders.length;s++){

            _totalStakes += _totalStakes.add(stakes[stakeholders[s]]);

        }

        return _totalStakes;


    }

    //staking function with burning staked 

    function createStake(uint256 _stake) public {

        require(balanceOf(msg.sender) >= _stake,"Not Enough token to stake");

        _burn(msg.sender,_stake);
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender].add(_stake);

    }

    function removeStake(uint256 _stake) public {
        require(stakes[msg.sender] >= _stake,"You cannot remove what you dont stake");
        
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
        _mint(msg.sender,_stake);


    }


    //to check reward of an address
    function rewardOf(address _stakeholder) public view returns(uint256){

        return rewards[_stakeholder];

    }

    //to check aggregated rewards for allocatedRewards
    function totalRewards() public view returns(uint256){
        uint256 _totalRewards = 0;

        for(uint256 s=0;s<stakeholders.length;s++){
            _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
        }

        return _totalRewards;

    }

    //calculate rewards based on 1% of staked token in certain time
    function calculateReward(address _stakeholder) public view returns(uint256){

        return stakes[_stakeholder] / 100;

    }

    //distribute reward to all stakeholder 
    // in real world project this need to be automated
    function distributeReward() public onlyOwner{

        for(uint256 s = 0;s < stakeholders.length;s++){
            address stakeholder = stakeholders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);


        }

    }

    //withdraw reward 
    function withdrawReward() public {

        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender,reward);

    }
 



}