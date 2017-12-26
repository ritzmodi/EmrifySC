
var myContractInstance;

function startApp(_myContractInstance){
    console.error("startup");
	myContractInstance=_myContractInstance1;
    web3 = web2;
}

function AssociateDoctorUnderMyHospital() {
var adddocAdd =  document.getElementById('adddocAdd').value;
var associateDocIpfsHash = document.getElementById('associateDocIpfsHash').value;
var AssociateDoctorUnderMyHospital = myContractInstance.AssociateDoctorUnderMyHospital(adddocAdd,associateDocIpfsHash,function(err,result){
    if(!err){
        console.log("New Doctor added successfully");
      }
      else {
          console.err(error);
      }
});

var event = myContractInstance.DoctorAssociated({},function(error, result) {
    if (!error) {
        //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
            var msg = "A new doctor with Address :" + result.args.doctorAddress+" have been added under oragnization:"+ result.args._orgAddress + "with document hash"+result.args.IPFSDocumentHash;
            document.getElementById('callbackNewDoctor').innerHTML = ""+msg;
            console.log(msg);
    }
    else {
        console.error(error);
    }
});

}


function DisassociateDoctorfromTheHospital() {
    var removedocAdd =  document.getElementById('removedocAdd').value;
    var disassociateDocIpfsHash = document.getElementById('disassociateDocIpfsHash').value;
    var AssociateDoctorUnderMyHospital = myContractInstance.DisassociateDoctorfromTheHospital(removedocAdd,disassociateDocIpfsHash,function(err,result){
        if(!err){
            console.log(" Doctor removed successfully");
          }
          else {
              console.err(error);
          }
    });
    
    var event = myContractInstance.DoctorDisassociated({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
                var msg = "A doctor with Address :" + result.args.doctorAddress+" have been removed from oragnization:"+ result.args._orgAddress + "with document hash"+result.args.IPFSDocumentHash;
                document.getElementById('callbackDisDoctor').innerHTML = ""+msg;
                console.log(msg);
        }
        else {
            console.error(error);
        }
    });
    
    }
4