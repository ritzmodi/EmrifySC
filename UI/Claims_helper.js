
var myContractInstance;

function startApp(_myContractInstance){
    console.error("startup");
	myContractInstance=_myContractInstance1;
    web3 = web2;
}

function getClaim() {
var claimID =  document.getElementById('claimID').value;
var getClaim = myContractInstance.getClaim(claimID,,function(err,result){
    if(!err){
        console.log("claim fetched successfully");
        console.log("These are the details for the :"+claimID+"=> \n accountType=" + result[0]," category="+result[1]," issuer="+result[2]," signature="+result[3]," data="+result[4]," uri="+result[5]);
      }
      else {
          console.err(error);
      }
});

}


function getClaimsIdByType(){
    var accType = document.getElementById('accType').value;
    
	var fetchList = myContractInstance.getClaimsIdByType(accType,function(err,result){
		if(!err){
			for (var i =0; i< result.length; i++){
                console.log(result[i]);
            }
		  }
		  else {
			  console.err(error);
		  }
    });
    
}


function addClaim(){
    var accTypeForAddClaim = document.getElementById('accTypeForAddClaim').value;
    var categoryForAddClaim = document.getElementById('categoryForAddClaim').value;
    var issuerAddressForAddClaim = document.getElementById('issuerAddressForAddClaim').value;
    var signatureForAddClaim = document.getElementById('signatureForAddClaim').value;
    var dataForAddClaim = document.getElementById('dataForAddClaim').value;
    var URIForAddClaim = document.getElementById('URIForAddClaim').value;


	var addProvider = myContractInstance.addClaim(accTypeForAddClaim,categoryForAddClaim,issuerAddressForAddClaim,signatureForAddClaim,dataForAddClaim,URIForAddClaim,function(err,result){
		if(!err){
			console.log("claim added/changed successfully for claimID="+ (result.value));
		  }
		  else {
			  console.err(error);
		  }
    });
    var event = myContractInstance.ClaimChanged({},function(error, result) {                                                            uint256  , address indexed , bytes , bytes data, string uri
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
                var msg = "Claim changed successfully with these details. \n Claim ID= " +result.args.claimId+
                ", Account Type= "+result.args.accountType+ ", Category="+result.args.category +
                " ,Issuer="+ result.args.issuer+", Signature="+result.args.signature+
                ", Data="+result.args.data+ ", URI="+result.args.uri;
                document.getElementById('callback2').innerHTML = ""+msg;
                console.log(msg);
        }
        else {
            console.error(error);
        }
    });

    var event1 = myContractInstance.ClaimAdded({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
            var msg = "Claim added successfully with these details. \n Claim ID= " +result.args.claimId+
            ", Account Type= "+result.args.accountType+ ", Category="+result.args.category +
            " ,Issuer="+ result.args.issuer+", Signature="+result.args.signature+
            ", Data="+result.args.data+ ", URI="+result.args.uri;
            document.getElementById('callback2').innerHTML = ""+msg;
                console.log(msg);
        }
        else {
            console.error(error);
        }
    });

}



function removeClaim(){
    var claimIdForRemoval = document.getElementById('claimIdForRemoval').value;

	var addProvider = myContractInstance.removeClaim(claimIdForRemoval,function(err,result){
		if(!err){
			console.log("Claim removed successfully")
		  }
		  else {
			  console.err(error);
		  }
    });
    var event = myContractInstance.ClaimRemoved({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
            var msg = "Claim removed successfully with these details. \n Claim ID= " +result.args.claimId+
            ", Account Type= "+result.args.accountType+ ", Category="+result.args.category +
            " ,Issuer="+ result.args.issuer+", Signature="+result.args.signature+
            ", Data="+result.args.data+ ", URI="+result.args.uri;
            document.getElementById('callback2').innerHTML = ""+msg;
                console.log(msg);
        }
        else {
            console.error(error);
        }
    });
}
 























