// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract MedicalRecord {
    address public owner;
    string private firstname;
    string private lastname;
    string private dateofbirth;
    uint256 public balances;

    constructor(
        address _owner,
        string memory _firstname,
        string memory _lastname,
        string memory _dateofbirth
    ) payable {
        owner = _owner;
        firstname = _firstname;
        lastname = _lastname;
        dateofbirth = _dateofbirth;
        balances += msg.value;
    }

    event Withdraw(address indexed to, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function contractInfo()
        external
        view
        returns (address, string memory, string memory, string memory, uint256)
    {
        return (owner, firstname, lastname, dateofbirth, balances);
    }

    function getBalance() public view returns (uint256) {
        return balances;
    }

    function withdraw(uint amount) public onlyOwner {
        require(balances >= amount, "Insufficient balance");
        balances -= amount;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to send Ether");
        emit Withdraw(msg.sender, amount);
    }
}
