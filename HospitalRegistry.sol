pragma solidity ^0.4.0;
import "./AdminController.sol";
// import "./DoctorRegistry.sol";

contract HospitalRegistry is AdminController {

    AdminController adminController ;
    
 /*   function addSisterHospitalInTheNetwork (address _AdminController, address _sisterHospitalAddres){
        
        if (_AdminController != 0x0) {
            adminController = AdminController(_AdminController);
            
        }
        else {
            revert();
        }
        
}*/

function HospitalRegistry(address _adminController){
        if (_adminController != 0x0) {
            adminController = AdminController(_adminController);
        }
        else {
            revert(); //the admin controller address is wrong
        }
         
    }
    
    struct DoctorDetails{
        string name;
        string speciality;
        string licenseNo;
        bool isRegistered;
        string IPFSDoctorApprovalDocumentHash;
        string IPFSDoctorRemovalDocumentHash; 
    }
    
    
    mapping (address => DoctorDetails) public DoctorInformation;
    
    /// this function shall be called by those hospitals which is already registered by the admin in the AdminController contract.
    function AssociateDoctorUnderMyHospital(string _name, string _speciality, string _licenseNo, string _IPFSDocumentHash)  internal {
        if(WhiteListedHospitals[msg.sender].isRegistered){
            DoctorInformation[msg.sender].name = _name;
            DoctorInformation[msg.sender].speciality = _speciality;
            DoctorInformation[msg.sender].licenseNo = _licenseNo;
            DoctorInformation[msg.sender].isRegistered = true;
            DoctorInformation[msg.sender].IPFSDoctorApprovalDocumentHash = _IPFSDocumentHash;
        } else {
            revert();//the hospital is not registered under Emrify yet.
        }
        
    }
    
    function DisassociateDoctorfromTheHospital(){
        if(WhiteListedHospitals[msg.sender].isRegistered){
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
