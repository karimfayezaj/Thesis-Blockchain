// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract PoAContract {
    address public immutable owner;
    bytes32 public immutable poAType;
    address public immutable controller;
    bool public revoked;

    constructor(address _owner, bytes32 _poAType, address _controller) {
        owner = _owner;
        poAType = _poAType;
        controller = _controller;
        revoked = false;
    }

    function revokeContract() external {
        require(msg.sender == controller, "Not authorized");
        revoked = true;
    }

    function isActive() external view returns (bool) {
        return !revoked;
    }
}

contract ProofOfAuthority {
    address public admin;
    mapping(address => bool) public isAuthorized;
    mapping(address => address) public authorizedContract;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
        isAuthorized[msg.sender] = true;
    }

    function authorize(address _deployer, bytes32 _poAType) external onlyAdmin {
        require(!isAuthorized[_deployer], "Already authorized");
        isAuthorized[_deployer] = true;
        PoAContract record = new PoAContract(
            _deployer,
            _poAType,
            address(msg.sender)
        );
        authorizedContract[_deployer] = address(record);
    }

    function revoke(address deployer) external onlyAdmin {
        isAuthorized[deployer] = false;
        address deployed = authorizedContract[deployer];
        if (deployed != address(0)) {
            PoAContract(deployed).revokeContract();
            delete authorizedContract[deployer];
        }
    }

    function checkAuthorization(address deployer) external view returns (bool) {
        return isAuthorized[deployer];
    }
}
