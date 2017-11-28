pragma solidity ^0.4.0;
import "./ProviderRegistry.sol";

contract ClaimsRegistry is ProviderRegistry{
    
   ProviderRegistry providerRegistry;
   mapping (address => mapping (address => bool)) public RegisteredClaims;
    
function ClaimsRegistry(address _providerRegistry){
        if (_providerRegistry != 0x0) {
            providerRegistry = ProviderRegistry(_providerRegistry);
        }
        else {
            revert(); //the provider controller address is wrong
        }
         
    }
    
  function setClaim(address _providerAddress) {
      require(ListOfPeopleWhoCanPushClaim[msg.sender] == true);
      require(WhiteListedProviders[_providerAddress].state == State.Accepted);
      RegisteredClaims[msg.sender][_providerAddress]= true;
  }
   
    
}
