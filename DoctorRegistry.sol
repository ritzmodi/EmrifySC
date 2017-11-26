pragma solidity ^0.4.0;
import "./HospitalRegistry.sol";

contract DoctorRegistry is HospitalRegistry{
    
    HospitalRegistry hospitalRegistry;
    
    function DoctorRegistry(address _hospitalRegistry){
        if (_hospitalRegistry != 0x0) {
            hospitalRegistry = HospitalRegistry(_hospitalRegistry);
        }
        else {
            revert(); //the admin controller address is wrong
        }
         
    }
    
   
    
}
