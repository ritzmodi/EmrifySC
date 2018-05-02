pragma solidity 0.4.23;


import "./library.sol";
import "./ERC20.sol";

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}




contract Airdrop is Ownable {
    
    ERC20 tokenContract;        //our ERC20 token contract 
         //Holder contract 
   
    
    
    function Airdrop(address _tokenContractAddress) public{
        
        tokenContract   = ERC20(_tokenContractAddress);
    
       
    }
    
    
    //internal method to transfer the tokens to a user address. This is an internal method.
    
    function distributeTokens(address _beneficiaryAddress,uint256 _amount) internal {
        
        assert(tokenContract.transfer(_beneficiaryAddress,_amount));
        
    }
    
    
    function AirDropTokens(address[] _addresses,uint256 _value) public onlyOwner returns (bool) {
        
        require(_addresses.length>0);
        
        for(uint i=0;i<_addresses.length;i++){
            
            require( _addresses[i]!=address(0) && _addresses[i]!=owner );
            distributeTokens(_addresses[i],_value);
        }
        return true;
    }
    
    function AirdropMultiValues(address[] _addresses,uint256[] _values) public onlyOwner returns (bool) {
        
        require(_addresses.length>0);
        require(_addresses.length==_values.length);
        
        for(uint i=0;i<_addresses.length;i++){
            
            require( _addresses[i]!=address(0) && _addresses[i]!=owner );
         
            distributeTokens(_addresses[i],_values[i]);
        }
        return true;
        
    }
    
}
