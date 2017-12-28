
var myContractInstance;

function startApp(_myContractInstance){
    console.error("startup");
	myContractInstance=_myContractInstance;
    
}

function addAdminGroup() {
var newAdminAdd =  document.getElementById('newAdminAdd').value;
var addNewAdmin = myContractInstance.addAdminGroup(newAdminAdd,function(err,result){
    if(!err){
        console.log("Admin added successfully. "+ result);
      }
      else {
          console.err(error);
      }
});

var event = myContractInstance.NewAdminAdded({},function(error, result) {
    if (!error) {
        //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
            var msg = "A new admin have been added with Provider Address :" + result.args.newAdmin ;
            document.getElementById('callbackNewAdmin').innerHTML = ""+msg;
            console.log(msg );
    }
    else {
        console.error(error);
    }
});

}


function submitRequestForApproval(){
    var isOrgBool = (document.getElementById('isOrgBool').value == 'true');
    var providerDetails = document.getElementById('providerDetails').value;
console.log("IS ORG=" + isOrgBool);
	var addProvider = myContractInstance.submitRequestForApproval(isOrgBool,providerDetails,function(err,result){
		if(!err){
			console.log("Request submitted successfully"+ "\n" + result);
		  }
		  else {
			  console.err(error);
		  }
    });
var storeProviderNotesEvent = myContractInstance.RequestSubmittedForApproval({},function(error, result) {
	  if (!error) {
		    var msg = "A request have been submitted for approval :\n Provider Address :" + result.args._requsterAdd ;
                if(result.args.isOrg == true){
                    msg+=" \n as an organization";
                } else {
                    msg+=" \n as an individual";
                }
                msg+=" \n got these documents " + result.args.ProviderDetailsIPFShash;
                document.getElementById('callback1').innerHTML = msg;
                console.log(msg);
	  }
	  else {
		  console.error(error);
	  } 
});
    
}

function fetchAllReqSubmittedEvents(){
var allEvents = myContractInstance.RequestSubmittedForApproval({},{fromBlock: 0, toBlock: 'latest'},function(error, result) {
	  if (!error) {
		  var msg = "IPFS HASH"+(result.args.ProviderDetailsIPFShash);
           document.getElementById('callback22').innerHTML += "<hr/>"+msg;
		    console.log(msg);
	  }
	  else {
		  console.error(error);
	  } 
});
allEvents.stopWatching();

}

function approveProviderApplication(){
    var providerAddressForApproval = document.getElementById('providerAddressForApproval').value;
    console.log(providerAddressForApproval);

	var addProvider = myContractInstance.approveProviderApplication(providerAddressForApproval,function(err,result){
		if(!err){
			console.log("Approval request sent successfully"+ "\n" + result);
		  }
		  else {
			  console.err(error);
		  }
    });
    var event = myContractInstance.RequestApproved({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
                var msg = "Request of " +result.args.providerAddress+"approved sucessfully.";
                document.getElementById('callback2').innerHTML = ""+msg;
                console.log(msg);
        }
        else {
            console.error(error);
        }
    });
}

function fetchAllEventsforRequestAppproved(){
var allEvents = myContractInstance.RequestApproved({},{fromBlock: 0, toBlock: 'latest'},function(error, result) {
	  if (!error) {
		  var msg = "Request of " +result.args.providerAddress+"approved sucessfully.";
           document.getElementById('callback23').innerHTML += "<hr/>"+msg;
		    console.log(msg);
	  }
	  else {
		  console.error(error);
	  } 
});
allEvents.stopWatching();
}


function rejectProviderApplication(){
    var providerAddressForRejection = document.getElementById('providerAddressForRejection').value;

	var addProvider = myContractInstance.rejectProviderApplication(providerAddressForRejection,function(err,result){
		if(!err){
			console.log("Rejection request sent successfully"+ "\n" + result);
		  }
		  else {
			  console.err(error);
		  }
    });
    var event = myContractInstance.RequestRejected({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
                var msg = "Request of " +result.args.providerAddress+"rejected sucessfully.";
                document.getElementById('callback3').innerHTML = ""+msg;
                console.log(msg);
        }
        else {
            console.error(error);
        }
    });
}
 



function terminateProviderFromNetwork(){
    var providerAddressForTermination = document.getElementById('providerAddressForTermination').value;
    var DocumentForTermination = document.getElementById('DocumentForTermination').value;

	var addProvider = myContractInstance.terminateProviderFromNetwork(providerAddressForTermination,DocumentForTermination,function(err,result){
		if(!err){
			console.log("Terminate request sent successfully"+ "\n" + result);
		  }
		  else {
			  console.err(error);
		  }
    });
    var event = myContractInstance.Terminate({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
                var msg = "" +result.args.providerAddress+"have been terminated from the network."+ result.args.IPFSHash+" is the file for supporting the termination";
                document.getElementById('callback4').innerHTML = ""+msg;
                console.log(msg);
        }
        else {
            console.error(error);
        }
    });
}


