pragma solidity ^0.4.0;
import "./AdminController.sol";

contract Mapping {
    AdminController adminController ;
    
     function Mapping(address _adminController){
        if (_adminController != 0x0 ) {
            adminController = AdminController(_adminController);
        }
        else {
            revert(); //the admin controller address is wrong
        }
    }
    modifier isAppprovedProvider (address _checkIfApproved){
        require(adminController.isState(_checkIfApproved));
        _;
    }
    
    mapping (address => address[]) memberList;
    mapping (address => address[] ) withWhichProviderThisDocIsAssociated;
    
    function attachMember (address _providerAddress)
    isAppprovedProvider(_providerAddress)
    {
        memberList[_providerAddress].push(msg.sender);
        withWhichProviderThisDocIsAssociated[msg.sender].push(_providerAddress);
    }
    
    // should be called by approved provider only
    function removeMember(address _doctorAddress)
    isAppprovedProvider(msg.sender){
        memberList[msg.sender] = removeAddress(memberList[msg.sender],findIndexOfAddress(memberList[msg.sender], _doctorAddress));
        withWhichProviderThisDocIsAssociated[_doctorAddress] = removeAddress(withWhichProviderThisDocIsAssociated[_doctorAddress],findIndexOfAddress(withWhichProviderThisDocIsAssociated[_doctorAddress], msg.sender));
    }
    
    function getAssociatedMembersList()
    isAppprovedProvider(msg.sender)
    constant returns (address[]){
        return memberList[msg.sender];
    }
    
    function getOrgAddress() constant returns (address[]){
        return withWhichProviderThisDocIsAssociated[msg.sender];
    }
    
    
    function removeAddress(address[] array, uint index) internal returns(address[] value) {
        if (index >= array.length) return;

        address[] memory arrayNew = new address[](array.length-1);
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
    
    function findIndexOfAddress(address[] array, address findIndexOfThisAddress) internal  returns (uint256) {
        for (uint i = 0; i<array.length; i++){
            if( array[i] == findIndexOfThisAddress){
                break;
            }
        }
        if(i>=0 && i<array.length){
            return i;
        } else {
            return array.length;
        }
        
    }
}