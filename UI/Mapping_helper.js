
var myContractInstance;

function startApp(_myContractInstance){
    console.error("startup");
	myContractInstance=_myContractInstance;
    
}


// this shall be called by the individual doctors. and the doctor address shall go in the pending list. Pending list for this organisation can be fetched by calling the `returnPendingList()` method of this JS file
function submitAttachMemberRequest() {
var providerAdd =  document.getElementById('providerAdd').value;

var addNewAdmin = myContractInstance.submitAttachMemberRequest(providerAdd,function(err,result){
    if(!err){
        console.log("Request submitted successfully. "+ result);
      }
      else {
          console.err(error);
      }
});
}

// this shall be called by the organisation to approve the doctor request which is present in the pending list
function approveMember() {
    var doctorAdd =  document.getElementById('doctorAdd').value;
    
    var addNewAdmin = myContractInstance.approveMember(doctorAdd,function(err,result){
        if(!err){
            console.log("approve member request submitted successfully. "+ result);
          }
          else {
              console.err(error);
          }
    });
    
    var event = myContractInstance.DoctorAdded({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
                var msg = "Member with address :" + result.args._doctorAddress +" has been approved by "+ result.args._orgAddress+" address" ;
                document.getElementById('approvedMemberEvent').innerHTML = ""+msg;
                console.log(msg );
        }
        else {
            console.error(error);
        }
    });
    
}

// this shall be called by the organisation to remove the doctor 
function removeMember() {
    var doctorAdd =  document.getElementById('doctorAddToBeRemoved').value;
    
    var addNewAdmin = myContractInstance.removeMember(doctorAddToBeRemoved,function(err,result){
        if(!err){
            console.log("remove member request submitted successfully. "+ result);
          }
          else {
              console.err(error);
          }
    });
    
    var event = myContractInstance.DoctorRemoved({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
                var msg = "Member with address :" + result.args._doctorAddress +" has been removed by "+ result.args._orgAddress+" address" ;
                document.getElementById('removedMemberEvent').innerHTML = ""+msg;
                console.log(msg );
        }
        else {
            console.error(error);
        }
    });
    
}
// it shall return the array of the doctors pending for this org to approve
function returnPendingList() {
    // var docAdd =  document.getElementById('docAdd').value;
    var addNewAdmin = myContractInstance.getPendingMembersList.call( function(err,result){
        if(!err){
            var msg ="";
            for (var i = 0; i< result.length; i++){
                msg += result[i]+", ";
            }
            console.log("this is the Pending list=>"+ msg);
          }
          else {
              console.err(error);
          }
    });
}

// it shall return the array of the doctors approved by this org
function returnApprovedList() {
    // var docAdd =  document.getElementById('docAdd').value;
    var addNewAdmin = myContractInstance.getApprovedMembersList.call( function(err,result){
        if(!err){
            var msg ="";
            for (var i = 0; i< result.length; i++){
                msg += result[i]+", ";
            }
            console.log("this is the approved list=>"+ msg);
          }
          else {
              console.err(error);
          }
    });
}

// it shall return the array of the members approved by this org
function returnApprovedList() {
    var orgAddressToFetchMemberList =  document.getElementById('orgAddressToFetchMemberList').value;
    var addNewAdmin = myContractInstance.getApprovedMembersListForAnyAddress(orgAddressToFetchMemberList, function(err,result){
        if(!err){
            var msg ="";
            for (var i = 0; i< result.length; i++){
                msg += result[i]+", ";
            }
            console.log("this is the approved list=>"+ msg);
          }
          else {
              console.err(error);
          }
    });
}

// Fetch the org List with which this doctor is associated: if there is a flexibility of a doctor can get associated with more than one organisation
function fetchorgListForThisdoctor() {
    var AddToFetchTheAssociatedOrgnisation =  document.getElementById('AddToFetchTheAssociatedOrgnisation').value;
    var addNewAdmin = myContractInstance.getOrgAddress(AddToFetchTheAssociatedOrgnisation, function(err,result){
        if(!err){
            var msg ="";
            for (var i = 0; i< result.length; i++){
                msg += result[i]+", ";
            }
            console.log("this is the organisation list with which this address is associated=>"+ msg);
          }
          else {
              console.err(error);
          }
    });
}