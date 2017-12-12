pragma solidity ^0.4.0;
import "./ProviderRegistry.sol";

contract ClaimsRegistry is ProviderRegistry{
    
   ProviderRegistry providerRegistry;
   enum ClaimStatus { Pending, Accepted, Rejected } 
   mapping (address => mapping(address => ClaimStatus)) public RegisteredClaims;
    
    function ClaimsRegistry(address _providerRegistry){
        if (_providerRegistry != 0x0) {
            providerRegistry = ProviderRegistry(_providerRegistry);
        }
        else {
            revert(); //the provider controller address is wrong
        }
         
    }

    /// A Provider can request the claims using this function. This shall be put in the Pending queue
    function requestClaim(address _bodyToWhomYouAreSubmittingForApproval) {
      //require(ListOfPeopleWhoCanPushClaim[msg.sender] == true);
      require(WhiteListedProviders[msg.sender].state == State.Accepted);
      RegisteredClaims[_bodyToWhomYouAreSubmittingForApproval][msg.sender] = ClaimStatus.Pending;
    }
  
  // these ACCEPT/REJECT function shall be called by the bodies who can accept and reject the providers.
    function AcceptApproval(address _providerAddress){
        require(WhiteListedProviders[_providerAddress].state == State.Accepted && RegisteredClaims[msg.sender][_providerAddress] == ClaimStatus.Pending);
        RegisteredClaims[msg.sender][_providerAddress] = ClaimStatus.Accepted;
    }
    
    function RejectApproval(address _providerAddress){
        require(WhiteListedProviders[_providerAddress].state == State.Accepted && RegisteredClaims[msg.sender][_providerAddress] == ClaimStatus.Pending);
        RegisteredClaims[msg.sender][_providerAddress] = ClaimStatus.Rejected;
    }

}
