pragma solidity ^0.4.0;
import "./ProviderRegistry.sol";

contract ClaimsRegistry is ProviderRegistry{
    
   ProviderRegistry providerRegistry;
   
    struct Claim {
        uint256 accountType; // can be either individual or organzation
        uint256 category; // this shall be one of the many from : doctor, nurse, receptionist etc 
        //uint256 scheme; // in our case we don't need scheme as of now, as we shall be using the symmetric keys for encoding-decoding
        address issuer; // msg.sender
        bytes signature; // this.address + claimType + data
        bytes data; // this is going to the hash of the data
        string uri; // the data shall reside here
    }
    
    
    mapping (bytes32 => Claim) claims;
    mapping (uint256 => bytes32[]) claimsByType; // either organization or individual

    function ClaimsRegistry(address _providerRegistry) {
        if (_providerRegistry != 0x0) {
            providerRegistry = ProviderRegistry(_providerRegistry);
        }
        else {
            revert(); //the provider controller address is wrong
        }
         
    }

    //events
    //event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed accountType, uint256  category, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed accountType, uint256  category, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed accountType, uint256  category, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed accountType, uint256  category, address indexed issuer, bytes signature, bytes data, string uri);
    
    function getClaim(bytes32 _claimId )public constant returns (uint256 accountType,uint256 category, address issuer,bytes signature,bytes data,string uri){
            Claim memory _claim = claims[_claimId];
            return (_claim.accountType, _claim.category, _claim.issuer, _claim.signature, _claim.data, _claim.uri);
        }


    function getClaimsIdByType(uint256 _accountType) public constant returns(bytes32[]) {
        return claimsByType[_accountType];
    }

    // it shall add or change the claim directly. no need to check anything. it will be called by the ISSUER
    function addClaim(uint256 _accountType, uint256 _category, address _issuer, bytes _signature, bytes _data, string _uri ) public returns (bytes32 claimId) {
            claimId = keccak256(_issuer, _accountType);
            if(claims[claimId].issuer !=  0x0){
                ClaimChanged(claimId, _accountType, _category, _issuer, _signature, _data, _uri);
            }else{
                ClaimAdded(claimId, _accountType,  _category, _issuer, _signature, _data, _uri);
            }
                
             claims[claimId] = Claim(
                 {
                     accountType: _accountType,
                     issuer: _issuer,
                     category: _category,
                    //  signatureType: _signatureType,
                     signature: _signature,
                     data: _data,
                     uri: _uri
                 }
             );
            claimsByType[_accountType].push(claimId);
            
            return claimId;
        }

    // need some conditions here e.g. where is the condition so that only the two people can delete the claim, not just anybody
    function removeClaim(bytes32 _claimId) public returns (bool success) {
            Claim memory c = claims[_claimId];
            require(WhiteListedProviders[msg.sender].state == State.Accepted);
            ClaimRemoved(_claimId, c.accountType, c.category, c.issuer, c.signature, c.data, c.uri);
            delete claims[_claimId];
            return true;
        }
}