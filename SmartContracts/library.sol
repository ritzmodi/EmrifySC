
pragma solidity 0.4.25;

/*
* Standard Ownable contract from Open Zepplin,
* With a change in ownership, This contract uses a
* two step process for ownership transfer.
*/

contract Ownable {    
    address public owner;
    address public tempOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferRequest(address indexed previousOwner, address indexed newOwner);
    
    // Constructor which will assing the admin to the contract deployer.
    constructor() public {
        owner = msg.sender;
    }

    // Modifier which will make sure only admin can call a particuler function.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // This method is used to transfer ownership to a new admin. This is the first of the two stesps.
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OwnershipTransferRequest(owner, newOwner);
        tempOwner = newOwner;
    }
  
    // This is the second of two steps of ownership transfer, new admin has to call to confirm transfer.
    function acceptOwnership() public {  
        require(tempOwner==msg.sender);
        emit OwnershipTransferred(owner,msg.sender);
        owner = msg.sender;
    }
}

