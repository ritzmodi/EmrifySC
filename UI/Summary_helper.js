
var myContractInstance;

function startApp(_myContractInstance){
    console.error("startup");
	myContractInstance=_myContractInstance;
    
}

function shareePermissionHash() {
var providerAdd =  document.getElementById('providerAdd').value;
var data =  document.getElementById('data').value;
var uri =  document.getElementById('uri').value;
var addNewAdmin = myContractInstance.addAdminGroup(providerAdd,data,uri,function(err,result){
    if(!err){
        console.log("Permission hash sharing request submitted successfully. "+ result);
      }
      else {
          console.err(error);
      }
});

var event = myContractInstance.PermissionHashShared({},function(error, result) {
    if (!error) {
        //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
            var msg = "permission Hash has been shared with :" + result.args.doctor +" from "+ result.args.patient+" address" +" with this data="+result.args.data +" & this uri=" + result.args.uri ;
            document.getElementById('permissionhashEvent').innerHTML = ""+msg;
            console.log(msg );
    }
    else {
        console.error(error);
    }
});

}

function returnSharedHash() {
    var patientAdd =  document.getElementById('patientAdd').value;
    var addNewAdmin = myContractInstance.returnSharedHash.call(patientAdd, function(err,result){
        if(!err){
            console.log("request for fetching the shared hash has been submitted successfully. "+ result);
          }
          else {
              console.err(error);
          }
    });
}

function fetchPatientListForThisIssuer() {
    var docAdd =  document.getElementById('docAdd').value;
    var addNewAdmin = myContractInstance.getListOfPatientsForThisDoctor.call(docAdd, function(err,result){
        if(!err){
            console.log("request for fetching the list of patient who have shared the permission hash has been submitted successfully. "+ result);
          }
          else {
              console.err(error);
          }
    });
}
