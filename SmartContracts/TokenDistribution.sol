pragma solidity 0.4.23;


import "./library.sol";
import "./ERC20.sol";
import "./Holder.sol";




contract TokenDistribution is Ownable {
    
    ERC20 tokenContract;        //our ERC20 token contract 
    Hodler hodlerContract;      //Holder contract 
    
    function setContractAddresses(address _tokenContractAddress,address _hodlerContractAddress) public onlyOwner{
        tokenContract   = ERC20(_tokenContractAddress);
        hodlerContract  = Hodler(_hodlerContractAddress);
    }
    
    
    //internal method to transfer the tokens to a user address. This is an internal method.
    
    function distributeTokens(address _beneficiaryAddress,uint256 _amount) internal {
        
        assert(tokenContract.transfer(_beneficiaryAddress,_amount));
        
    }
    
    
    
    //This method can be used by the admin to allocate tokens to the presale users.
    
    function SaleDistribution(address _beneficiaryAddress,uint256 _amount) onlyOwner {
        
        require(_beneficiaryAddress!=address(0)&&_beneficiaryAddress!=owner);
        
       
        hodlerContract.addHodlerStake(_beneficiaryAddress,_amount);
        
        distributeTokens(_beneficiaryAddress,_amount);
        
    }
    
    
    //This method can be used by the admin to allocate tokens to multiple presale users at a single shot.
    
    function SaleDistributionMultiAddress(address[] _addresses,uint256[] _values) onlyOwner returns (bool) {
        
        require(_addresses.length>0);
        require(_addresses.length == _values.length);
        
        for(uint i=0;i<_addresses.length;i++)
        {
            SaleDistribution(_addresses[i],_values[i]);
        }
        
        return true;
    }
    
    
    //This method can be used by the admin to send tokens to multiple addresses ins a single method.
    function BatchTransfer(address[] _addresses,uint256[] _values) onlyOwner returns (bool) {
        
        require(_addresses.length>0);
        require(_addresses.length==_values.length);
        
        for(uint i=0;i<_addresses.length;i++){
            
            require(_addresses[i]!=address(0)&&_addresses[i]!=owner);
         
            distributeTokens(_addresses[i],_values[i]);
        }
        return true;
        
    }
    
}
