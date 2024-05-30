// SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;

contract FundRequestSystem {
    enum Role { Citizen, Government, Auditor }
    enum RequestStatus { Submitted, Approved, Rejected }

    struct Request {
        string description;
        uint amount;
        address requester;
        RequestStatus status;
    }

    mapping(address => Role) public roles;
    Request[] public requests;

    event RequestSubmitted(uint indexed requestId, address indexed requester);
    event RequestReviewed(uint indexed requestId, RequestStatus status);
    event FundsTransferred(uint indexed requestId, uint amount);

    function FundRequestSystem() public {
        roles[msg.sender] = Role.Government;
    }

    modifier onlyRole(Role _role) {
        require(roles[msg.sender] == _role);
        _;
    }

    function assignRole(address _user, Role _role) public onlyRole(Role.Government) {
        roles[_user] = _role;
    }

    function submitRequest(string _description, uint _amount) public onlyRole(Role.Citizen) {
        requests.push(Request({
            description: _description,
            amount: _amount,
            requester: msg.sender,
            status: RequestStatus.Submitted
        }));
        RequestSubmitted(requests.length - 1, msg.sender);
    }

    function reviewRequest(uint _requestId, RequestStatus _status) public onlyRole(Role.Government) {
        Request storage request = requests[_requestId];
        request.status = _status;
        RequestReviewed(_requestId, _status);
    }

    function transferFunds(uint _requestId) public payable onlyRole(Role.Government) {
        Request storage request = requests[_requestId];
        require(request.status == RequestStatus.Approved);
        require(request.status == RequestStatus.Approved);

        request.requester.transfer(msg.value);
        FundsTransferred(_requestId, msg.value);
    }

    function getRequest(uint _requestId) public returns (string, uint, address, RequestStatus) {
        Request storage request = requests[_requestId];
        return (request.description, request.amount, request.requester, request.status);
    }
}
