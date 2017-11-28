pragma solidity ^0.4.0;
import "./ProviderRegistry.sol";

contract DoctorRegistry is ProviderRegistry{
    
   ProviderRegistry providerRegistry;
    
function DoctorRegistry(address _providerRegistry){
        if (_providerRegistry != 0x0) {
            providerRegistry = ProviderRegistry(_providerRegistry);
        }
        else {
            revert(); //the admin controller address is wrong
        }
         
    }
    
   
    
}
