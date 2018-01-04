pragma solidity ^0.4.0;
import "./ProviderRegistry.sol";

contract ClaimsRegistry is AdminController{
    
    AdminController adminController ;
   
    struct Claim {
        // uint256 accountType; // can be either individual or organzation
        uint256 claimType; // this shall be one of the many from : doctor, nurse, receptionist etc 
        //uint256 scheme; // in our case we don't need scheme as of now, as we shall be using the symmetric keys for encoding-decoding
        address issuer; // msg.sender
        address claimee;
        bytes signature; // this.address + claimType + data
        bytes data; // this is going to the hash of the data
        string uri; // the data shall reside here
        bool isApproved;
    }
    
    modifier onlyIssuer(address _issuer, bytes32 _claimId){
        Claim memory _claim = claims[_claimId];
        require(_issuer == _claim.issuer );
        _;
    }
    
     modifier onlyClaimee(address _claimee, bytes32 _claimId){
        Claim memory _claim = claims[_claimId];
        require(_claimee == _claim.claimee );
        _;
    }
    
    mapping(address => bytes32[]) public individualPendingClaims; // my total pending claims
    
    mapping(address => bytes32[]) public individualApprovedClaims; // my approved claims
    
    mapping(address => bytes32[]) public PendingClaimsForEachIssuers; // pending claims at individual issuers
    
    mapping(address => bytes32[]) public ApprovedClaimsForEachIssuers; // claims  which are approved  by Issuers
    
    mapping (bytes32 => Claim) public claims;
    
    // mapping (bytes32 => bytes32[]) claimsByType; // either organization or individual

    function ClaimsRegistry(address _adminController){
        if (_adminController != 0x0) {
            adminController = AdminController(_adminController);
        }
        else {
            revert(); //the admin controller address is wrong
        }
         
    }

    //events
    //event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed accountType, uint256  category, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimAdded(bytes32 indexed claimId, address indexed claimee, uint256 _claimType, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemovedByIssuer(bytes32 indexed claimId, address indexed claimee, uint256 _claimType, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemovedByClaimee(bytes32 indexed claimId, address indexed claimee, uint256 _claimType, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimApprovedByIssuer(bytes32 indexed claimId, address indexed claimee ,  uint256 _claimType, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimChangedByClaimee(bytes32 indexed claimId, address indexed claimee ,  uint256 _claimType, address indexed issuer, bytes signature, bytes data, string uri);
    
    
/*    function getSpecificClaimDetails(bytes32 _claimId)public constant returns (uint256 accountType, uint256 category, address issuer,address claimee, bytes signature, bytes data, string uri, bool isApproved){
            Claim memory _claim = claims[_claimId];
            return (_claim.accountType, _claim.category, _claim.issuer, _claim.claimee, _claim.signature, _claim.data, _claim.uri, _claim.isApproved);
        }*/

    function getAllApprovedClaimIdsForThisAddress (address _claimee) returns (bytes32[] ){
        return individualApprovedClaims[_claimee];
    }

    function getAllPendingClaimIdsForThisAddress (address _claimee) returns (bytes32[] ){
        return individualPendingClaims[_claimee];
    }
    
    function getAllApprovedClaimIdsForThisIssuer (address _issuer) returns (bytes32[] ){
        return ApprovedClaimsForEachIssuers[_issuer];
    }
    
    function getAllPendingClaimIdsForThisIssuer (address _issuer) returns (bytes32[] ){
        return PendingClaimsForEachIssuers[_issuer];
    }
/*    function getClaimsIdByType(uint256 _accountType, uint256 _category) public constant returns(bytes32[]) {
        return claimsByType[keccak256(_accountType, _category)];
    }*/

    // it shall add or change the claim directly. no need to check anything. it will be called by the ISSUER
    function addClaim(uint256 _claimType, address _issuer, bytes _signature, bytes _data, string _uri ) returns (bytes32 claimId, bool isNewClaimAdded) {
            claimId = keccak256(_claimType, msg.sender, _issuer); // three params: as a single claim can be uniquely identified by them
            uint256 index = findClaimIndex(individualApprovedClaims[msg.sender], claimId);
            
            if(index < individualApprovedClaims[msg.sender].length ){ // already existes condition
                return (claimId, false) ;
            }
            
            index = findClaimIndex(individualPendingClaims[msg.sender], claimId); // claim doesn't exit in both pending and approved claim array

            if(index == individualPendingClaims[msg.sender].length){

             claims[claimId] = Claim(
                 {
                    //  accountType: _accountType,
                     claimType: _claimType,
                     issuer: _issuer,
                     claimee: msg.sender,
                    //  signatureType: _signatureType,
                     signature: _signature,
                     data: _data,
                     uri: _uri,
                     isApproved: false
                 }
             );
    
                individualPendingClaims[msg.sender].push(claimId); // add to the list of the claimee
                PendingClaimsForEachIssuers[_issuer].push(claimId); // add to the list of the issuer
                ClaimAdded(claimId, msg.sender, _claimType, _issuer, _signature, _data, _uri);
                
                return (claimId, true);    
            }
            else {
                return (claimId, false);
            }
        }

    // shall be called by the ISSUER only
    function ApproveClaimByIssuer( bytes32 _claimId ) 
    onlyIssuer( msg.sender, _claimId)
    returns (bool isClaimApproved){
        Claim memory _claim = claims[_claimId];
        uint256 index = findClaimIndex(PendingClaimsForEachIssuers[msg.sender], _claimId);
        if(index < PendingClaimsForEachIssuers[msg.sender].length){
            claims[_claimId] = Claim(
                 {
                    //  accountType: _claim.accountType,
                     claimType: _claim.claimType,
                     issuer: _claim.issuer,
                     claimee: _claim.claimee,
                    //  signatureType: _signatureType,
                     signature: _claim.signature,
                     data: _claim.data,
                     uri: _claim.uri,
                     isApproved: true                 
                 }
             );
            ApprovedClaimsForEachIssuers[msg.sender].push(_claimId);
            PendingClaimsForEachIssuers[msg.sender] = remove (PendingClaimsForEachIssuers[msg.sender], findClaimIndex(PendingClaimsForEachIssuers[msg.sender], _claimId));
            individualApprovedClaims[_claim.claimee].push(_claimId);
            
            ClaimApprovedByIssuer(_claimId, msg.sender, _claim.claimType, _claim.issuer, _claim.signature, _claim.data, _claim.uri);
            return true;
        } else {
            return false;
        }
    }
    
    
    // submit a fresh request for a new claim overwriting the previous one
    /// untile this gets accepted, the old one shall be active
    function changeClaimByClaimee(uint256 _claimType, address _issuer, bytes _signature, bytes _data, string _uri, bytes32 _claimId ) 
    onlyClaimee( msg.sender, _claimId)
    returns (bool){
        bytes32 claimId = keccak256(_claimType, msg.sender, _issuer);
        Claim memory _claim = claims[_claimId];
        uint256 index = findClaimIndex(PendingClaimsForEachIssuers[msg.sender], _claimId);
        if(index != PendingClaimsForEachIssuers[msg.sender].length){
        claims[_claimId] = Claim(
                 {
                    //  accountType: _claim.accountType,
                     claimType: _claim.claimType,
                     issuer: _claim.issuer,
                     claimee: _claim.claimee,
                    //  signatureType: _signatureType,
                     signature: _claim.signature,
                     data: _claim.data,
                     uri: _claim.uri,
                     isApproved: true                 
                 }
             );
        
        individualPendingClaims[msg.sender].push(claimId); // add to the list of the claimee
        PendingClaimsForEachIssuers[_issuer].push(claimId); // add to the list of the issuer    
        ClaimChangedByClaimee(_claimId, msg.sender, _claim.claimType, _claim.issuer, _claim.signature, _claim.data, _claim.uri);
        }
        
    }
    
    // shall be called by ISSUER to remove the claim
    function removeClaimByIssuer(bytes32 _claimId) 
    onlyIssuer( msg.sender, _claimId)
    returns (bool success) {
            Claim memory c = claims[_claimId];
            require(WhiteListedProviders[msg.sender].state == State.Accepted && WhiteListedProviders[msg.sender].isOrganization == true) ;
             ClaimRemovedByIssuer(_claimId, c.claimee, c.claimType, c.issuer, c.signature, c.data, c.uri);
            // delete from three places: 1: issuer's approved list, 2: individual approved list, 3: from app wide claims  
            ApprovedClaimsForEachIssuers[msg.sender] = remove (ApprovedClaimsForEachIssuers[msg.sender], findClaimIndex(ApprovedClaimsForEachIssuers[msg.sender], _claimId));
            individualApprovedClaims[msg.sender] = remove (individualApprovedClaims[msg.sender], findClaimIndex(individualApprovedClaims[msg.sender], _claimId));
            delete claims[_claimId];
            
            return true;
        }
        
    
    
    // shall be called by ISSUER to remove the claim
    function removeSelfClaim(bytes32 _claimId) 
    onlyClaimee( msg.sender, _claimId)
    returns (bool success) {
            Claim memory c = claims[_claimId];
            require(WhiteListedProviders[msg.sender].state == State.Accepted ) ;
             ClaimRemovedByClaimee(_claimId, c.claimee, c.claimType, c.issuer, c.signature, c.data, c.uri);
            // delete from three places: 1: issuer's approved list, 2: individual approved list, 3: from app wide claims  
            PendingClaimsForEachIssuers[msg.sender] = remove (PendingClaimsForEachIssuers[msg.sender], findClaimIndex(PendingClaimsForEachIssuers[msg.sender], _claimId));
            individualApprovedClaims[msg.sender] = remove (individualApprovedClaims[msg.sender], findClaimIndex(individualApprovedClaims[msg.sender], _claimId));
            delete claims[_claimId];
            
            return true;
        }
        
    
        
    function remove(bytes32[] array, uint index) internal returns(bytes32[] value) {
        // if (index >= array.length) return;

        bytes32[] memory arrayNew = new bytes32[](array.length-1);
        for (uint i = 0; i<arrayNew.length; i++){
            if(i != index && i<index){
                arrayNew[i] = array[i];
            } else {
                arrayNew[i] = array[i+1];
            }
        }
        delete array;
        return arrayNew;
    }
    
    function findClaimIndex(bytes32[] _claimIds, bytes32 findThisClaim) internal returns (uint256){
        for (uint256 i = 0; i<_claimIds.length; i++){
             if( _claimIds[i] == findThisClaim){
                break;
            }
        }
        if(i>=0 && i<_claimIds.length){
            return i;
        } else {
            return _claimIds.length;
        }
        
        
    }
}