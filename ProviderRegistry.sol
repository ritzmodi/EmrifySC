pragma solidity ^0.4.0;
import "./AdminController.sol";


contract ProviderRegistry is AdminController {

    AdminController adminController ;
    
 /*   function addSisterHospitalInTheNetwork (address _AdminController, address _sisterHospitalAddres){
        
        if (_AdminController != 0x0) {
            adminController = AdminController(_AdminController);
            
        }
        else {
            revert();
        }
        
}*/

function ProviderRegistry(address _adminController){
        if (_adminController != 0x0) {
            adminController = AdminController(_adminController);
        }
        else {
            revert(); //the admin controller address is wrong
        }
         
    }
    
    struct DoctorDetails{
        address doctorAddress;
        bool isRegistered ;
        string IPFSDoctorApprovalDocumentHash;
        string IPFSDoctorRemovalDocumentHash; 
    }
    
    
    mapping (address => DoctorDetails) public DoctorInformation;
    
    /// this function shall be called by those hospitals which is already registered by the admin in the AdminController contract.
    function AssociateDoctorUnderMyHospital(address _doctorAddress, string _IPFSDocumentHash)  internal {
        if(WhiteListedProviders[msg.sender].isRegistered && WhiteListedProviders[msg.sender].isOrganization == true){
            DoctorInformation[msg.sender].doctorAddress = _doctorAddress;
            DoctorInformation[msg.sender].isRegistered = true;
            DoctorInformation[msg.sender].IPFSDoctorApprovalDocumentHash = _IPFSDocumentHash;
        } else {
            revert();//the hospital is not registered under Emrify yet.
        }
        
    }
    
    function DisassociateDoctorfromTheHospital(){
        if(WhiteListedProviders[msg.sender].isRegistered && WhiteListedProviders[msg.sender].isOrganization){
            if(DoctorInformation[msg.sender].isRegistered == true){
                DoctorInformation[msg.sender].isRegistered = false;
            } else {
                revert();//doctor already disassociated
            }
            
        } else {
            revert();//the hospital is not registered under Emrify yet.
        }
        
    }
}
