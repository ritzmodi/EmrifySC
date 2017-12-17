var abi1;
var myContractInstance1;
var MyContract1;
var abi2;
var myContractInstance2;
var MyContract2;
var web3;
function startApp(web2,abi11,MyContract11,myContractInstance11,abi22,MyContract22,myContractInstance22){

	console.error("startup");
				abi1=abi11;
				MyContract1=MyContract11;
				myContractInstance1=myContractInstance11;
				abi2=abi22;
				MyContract2=MyContract22;
				myContractInstance2=myContractInstance22;

	      web3 = web2;
}

function addProvider(){
	var providerAdd = document.getElementById('providerAdd').value;

	var addProvider = myContractInstance1.addProviderToNetwork(providerAdd,{from:web3.eth.accounts[0]},function(err,result){
		if(!err){
			console.log("Provider added successfully")
		  }
		  else {
			  console.err(error);
		  }
	});
}


function addPatient(){
	var patientAdd = document.getElementById('patientAdd').value;

	var addPatient = myContractInstance1.addPatientToNetwork(patientAdd,{from:web3.eth.accounts[0]},function(err,result){
		if(!err){
			console.log("Patient added successfully")
		  }
		  else {
			  console.err(error);
		  }
	});
}

function createClaim(){
	var patientAdd = document.getElementById('patientAdd').value;
	var providerAdd = document.getElementById('providerAdd').value;
	var visitID = document.getElementById('visitID').value;
	var claimID = document.getElementById('claimID').value;

	// var patBG = document.getElementById('patBG').value;
	// var patDisease = document.getElementById('patDisease').value;

	var createClaim = myContractInstance2.createClaim(patientAdd,providerAdd,visitID,claimID,{from:web3.eth.accounts[0]},function(err,result){
		if(!err){
			console.log("Claim created successfully")
		  }
		  else {
			  console.err(error);
		  }
	});
	var event = myContractInstance2.ClaimApproved({},function(error, result) {
		 if (!error) {
			 //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
				 var msg = "A claim is processed successfully. These are the details:\n Patient Address :" + result.args.patientAddress +
				 " \n got the services from : " + result.args.providerAddress +
				 " \n for amount : " + result.args.amount +
				 " \n on visit ID: " + result.args.visitID +
				 " \n for the claimID: " + result.args.claimID;
				 document.getElementById('callback1').innerHTML = ""+msg;
				 console.log(msg);
		 }
		 else {
			 console.error(error);
		 }
 });

}
