
pragma solidity 0.4.23;


contract Ownable {
    
  address public owner;
  
  address tempOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event OwnershipTransferRequest(address indexed previousOwner, address indexed newOwner);


    constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferRequest(owner, newOwner);
    owner = newOwner;
  }
  
  function acceptOwnership() public {
      
      require(tempOwner==msg.sender);
      emit OwnershipTransferred(owner,msg.sender);
      owner = msg.sender;
  }
}


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


library SafeMath40 {
  function mul(uint40 a, uint40 b) internal pure returns (uint40) {
    uint40 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint40 a, uint40 b) internal pure returns (uint40) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint40 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint40 a, uint40 b) internal pure returns (uint40) {
    assert(b <= a);
    return a - b;
  }

  function add(uint40 a, uint40 b) internal pure returns (uint40) {
    uint40 c = a + b;
    assert(c >= a);
    return c;
  }
}

