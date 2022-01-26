// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.0;

contract CrowdeFunding{
    mapping(address => uint) public contributors;
    address public admin;
    uint public numberOfContributors;
    uint public deadline;
    uint minimumContribution;
    uint public goal;
    uint public raisedAmount;

    event ContributeEvent(address _sender,uint _value);
    event CreateRequestEvent(string _description,address _recipient, uint _value);
    event MakePaymentEvent(address _recipient,uint _value);

    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint numberOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint =>Request) public requests;
    uint public numRequest;


    constructor(uint _goal,uint _deadline){
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100;
        admin = msg.sender;
    }

    receive()payable external{
        contribute();
    }

    function contribute() public payable{
        require(block.timestamp < deadline,"Deadline has passed");
        require(msg.value >= minimumContribution,"Minimum Contribution is 1000 wei");

        if(contributors[msg.sender] == 0){
            numberOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount +=msg.value;

        emit ContributeEvent(msg.sender,msg.value);
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getRefund()public{
        require(block.timestamp > deadline);
        require(raisedAmount < goal); 
        require(contributors[msg.sender] > 0);

        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];
        recipient.transfer(value);
        contributors[msg.sender] = 0;   
    }

    modifier onlyAdmin{
        require(msg.sender == admin,"Only Admin can call this function");
        _;
    }

    function createRequest(string memory _description, address payable _recipient,uint _value) public onlyAdmin {
        require(_value < raisedAmount);
        
        Request storage newRequest = requests[numRequest];
        numRequest++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.numberOfVoters = 0;

        emit CreateRequestEvent(_description,_recipient,_value);
    }

    function voteRequest(uint _noRequest) public{
        require(contributors[msg.sender] > 0,"you must be a contributor to vote");
        Request storage thisRequest = requests[_noRequest];
        
        require(thisRequest.voters[msg.sender] == false, "You have already vote!");
        thisRequest.voters[msg.sender] = true;
        thisRequest.numberOfVoters++;
    
    }

    function makePayment(uint _requestNumber)public onlyAdmin{
        require(raisedAmount>=goal);
        Request storage thisRequest = requests[_requestNumber];
        require(thisRequest.completed == false,"The request is already completed");
        require(thisRequest.numberOfVoters > numberOfContributors / 2);
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
        raisedAmount -= thisRequest.value;

        emit MakePaymentEvent(thisRequest.recipient,thisRequest.value);
        
    }

}