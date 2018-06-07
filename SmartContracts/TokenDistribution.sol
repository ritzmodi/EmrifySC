pragma solidity 0.4.23;


import "./library.sol";
import "./ERC20.sol";
import "./Hodler.sol";


contract TokenDistribution is Ownable {    
    ERC20  public  constant tokenContract = ERC20(0x1233);        //our ERC20 token contract, correct address will be added during the time of deployment.
    Hodler public  constant hodlerContract = Hodler(0x123);      //Holder contract, correct address will be added during the time of deployment;
   
    //internal method to transfer the tokens to a user address. This is an internal method. 
    function distributeTokens(address _beneficiaryAddress,uint256 _amount) internal returns (bool) {
        require(tokenContract.transfer(_beneficiaryAddress,_amount));
        return true;
    }
    
    //This method can be used by the admin to allocate tokens to the presale users.
    function saleDistribution(address _beneficiaryAddress,uint256 _amount)  public onlyOwner returns (bool) {
        require(_beneficiaryAddress!=address(0)&&_beneficiaryAddress!=owner);
        require(hodlerContract.addHodlerStake(_beneficiaryAddress,_amount));
        require(distributeTokens(_beneficiaryAddress,_amount));
        return true;
    }
    
    //This method can be used by the admin to allocate tokens to multiple presale users at a single shot.
    function saleDistributionMultiAddress(address[] _addresses,uint256[] _values) public onlyOwner returns (bool) {    
        require(_addresses.length>0);
        require(_addresses.length == _values.length);
        
        for(uint i=0;i<_addresses.length;i++)
        {
            saleDistribution(_addresses[i],_values[i]);
        }
        
        return true;
    }
    
    //This method can be used by the admin to send tokens to multiple addresses ins a single method.
    function batchTransfer(address[] _addresses,uint256[] _values) public onlyOwner returns (bool) {    
        require(_addresses.length>0);
        require(_addresses.length==_values.length);
        
        for(uint i=0;i<_addresses.length;i++){
            
            require(_addresses[i]!=address(0)&&_addresses[i]!=owner);
         
            require(distributeTokens(_addresses[i],_values[i]));
        }
        return true;
    }
}

