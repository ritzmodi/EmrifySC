pragma solidity ^0.4.0;
// this controller shall allow Hostpital's entry in the system. 
// & then only the hospitals shall be able to start functioning in the etheruem ecosystem.

contract AdminController {
    // Emrify shall be admin here
    address public admin;
    
    struct hostpitalDetail{
    string name;
    string state;
    string pincode;
    bool isRegistered;
    string IPFSApprovalDocumentHash;
    string IPFSRemovalDocumentHash;
    // address[] sisteBranchesOfHospital;// will use later to add multiple branches of the same hospital
}
    
    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }

    function isAdmin(address addr) public returns(bool) { 
        return addr == admin; 
        
    }

    // transfer ownership function
    function transferOwnership(address _newAdmin) public onlyAdmin {
        if (_newAdmin != address(this)) {
            admin = _newAdmin;
        }
    }
    
    function AdminController(){
        admin = msg.sender; 
    }
    

    
    mapping (address => hostpitalDetail) public WhiteListedHospitals;
    
    //this function shall be called by Emrify to add the address of the hospital in the whitelist hospitals
    function approveHospitalInNetwork(address _hostpitalAddress, string _name, string _state, string _pincode,string _supportingApprovalDocument) onlyAdmin  {
        WhiteListedHospitals[_hostpitalAddress].name = _name;
        WhiteListedHospitals[_hostpitalAddress].state = _state;
        WhiteListedHospitals[_hostpitalAddress].pincode = _pincode; 
        WhiteListedHospitals[_hostpitalAddress].isRegistered = true;
        WhiteListedHospitals[_hostpitalAddress].IPFSApprovalDocumentHash = _supportingApprovalDocument;
    }
    
    function removeHospitalFromNetwork(address _hostpitalAddress, string _supportingRejectingDocument) onlyAdmin {
        WhiteListedHospitals[_hostpitalAddress].isRegistered = false;
        WhiteListedHospitals[_hostpitalAddress].IPFSRemovalDocumentHash = _supportingRejectingDocument;
        
    }
    
    
    
}
