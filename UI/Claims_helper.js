
var myContractInstance;

function startApp(_myContractInstance){
    console.error("startup");
	myContractInstance=_myContractInstance;
    
}

function AddClaim() {
    var claimType =  document.getElementById('claimType').value;
    var claimIssuer =  document.getElementById('claimIssuer').value;
    var signature =  document.getElementById('signature').value;
    var data =  document.getElementById('data').value;
    var uri =  document.getElementById('uri').value;
var addClaim = myContractInstance.addClaim(claimType,claimIssuer,signature,data,uri,function(err,result){
    if(!err){
        console.log("Add claim request submitted successfully");
        // console.log("These are the details for the :"+claimID+"=> \n accountType=" + result[0]," category="+result[1]," issuer="+result[2]," signature="+result[3]," data="+result[4]," uri="+result[5]);
      }
      else {
          console.err(error);
      }
});

var event = myContractInstance.ClaimAdded({},function(error, result) {
    if (!error) {
        //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
            var msg = "Claim added successfully with these details. \n Claim ID= " +result.args.claimId+
            ", Requester= "+result.args.claimee+ ", ClaimType="+result.args._claimType +
            " ,Issuer="+ result.args.issuer+", Signature="+result.args.signature+
            ", Data="+result.args.data+ ", URI="+result.args.uri;
            document.getElementById('addClaimEvent').innerHTML = ""+msg;
            console.log(msg);
    }
    else {
        console.error(error);
    }
});


}


function ApproveClaim(){
    var claimIdForApproval = document.getElementById('claimIdForApproval').value;
    
	var fetchList = myContractInstance.ApproveClaim(claimIdForApproval,function(err,result){
		if(!err){
			console.log("Approve claim request submitted successfully" + result);
		  }
		  else {
			  console.err(error);
		  }
    });
    
    var event = myContractInstance.ClaimApprovedByIssuer({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
                var msg = "Claim approved successfully with these details. \n Claim ID= " +result.args.claimId+
                ", Requester= "+result.args.claimee+ ", ClaimType="+result.args._claimType +
                " ,Issuer="+ result.args.issuer+", Signature="+result.args.signature+
                ", Data="+result.args.data+ ", URI="+result.args.uri;
                document.getElementById('approveClaimEvent').innerHTML = ""+msg;
                console.log(msg);
        }
        else {
            console.error(error);
        }
    });
}



function RemoveSelfClaim(){
    var claimIdForSelfRemoval = document.getElementById('claimIdForSelfRemoval').value;
    
	var claimIdForRemoval = myContractInstance.removeSelfClaim(claimIdForSelfRemoval,function(err,result){
		if(!err){
			console.log("Self Remove claim request submitted successfully" + result);
		  }
		  else {
			  console.err(error);
		  }
    });
    
    var event = myContractInstance.ClaimRemovedByClaimee({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
                var msg = "You removed your own claim successfully. These were the details for the removed claim. \n Claim ID= " +result.args.claimId+
                ", Requester= "+result.args.claimee+ ", ClaimType="+result.args._claimType +
                " ,Issuer="+ result.args.issuer+", Signature="+result.args.signature+
                ", Data="+result.args.data+ ", URI="+result.args.uri;
                document.getElementById('removeSelfClaimEvent').innerHTML = ""+msg;
                console.log(msg);
        }
        else {
            console.error(error);
        }
    });
}




function RemoveClaimByIssuer(){
    var claimIdForRemovalByIssuer = document.getElementById('claimIdForRemovalByIssuer').value;
    
	var claimIdForRemovalByIssuer = myContractInstance.removeClaimByIssuer(claimIdForRemovalByIssuer,function(err,result){
		if(!err){
			console.log("Issuer have successfully submitted the remove claim request" + result);
		  }
		  else {
			  console.err(error);
		  }
    });
    
    var event = myContractInstance.ClaimRemovedByIssuer({},function(error, result) {
        if (!error) {
            //address indexed patientAddress, address indexed providerAddress, uint indexed claimID, uint indexed amount, uint indexed visitID
                var msg = "Issuer have removed the claim successfully. These were the details for the removed claim. \n Claim ID= " +result.args.claimId+
                ", Requester= "+result.args.claimee+ ", ClaimType="+result.args._claimType +
                " ,Issuer="+ result.args.issuer+", Signature="+result.args.signature+
                ", Data="+result.args.data+ ", URI="+result.args.uri;
                document.getElementById('removeClaimByIssuer').innerHTML = ""+msg;
                console.log(msg);
        }
        else {
            console.error(error);
        }
    });
}

function fetchPendingClaimsBetweenPair(){
    var requesterAdd = document.getElementById('requesterAdd').value ;
    var issuerAddress = document.getElementById('issuerAddress').value ;
    var claimTypeForPendingClaimsBetweenPair = document.getElementById('claimTypeForPendingClaimsBetweenPair').value ;
    var isOrg = myContractInstance.pairPendingClaimPerType.call(requesterAdd,issuerAddress,claimTypeForPendingClaimsBetweenPair,function(err,result){
		if(!err){
            var msg = "Pending Claim Id =>" + result;
            console.log(msg);
            document.getElementById('pendingClaimId').innerHTML = result;
		  }
		  else {
			  console.err(error);
		  }
    });
}

function fetchPendingClaimsBetweenPair(){
    var requesterAddForApprovedClaim = document.getElementById('requesterAddForApprovedClaim').value ;
    var issuerAddressForApprovedClaim = document.getElementById('issuerAddressForApprovedClaim').value ;
    var claimTypeForApprovedClaimsBetweenPair = document.getElementById('claimTypeForApprovedClaimsBetweenPair').value ;
    var isOrg = myContractInstance.pairApprovedClaimPerType.call(requesterAddForApprovedClaim,issuerAddressForApprovedClaim,claimTypeForApprovedClaimsBetweenPair,function(err,result){
		if(!err){
            var msg = "Approved Claim Id =>" + result;
            console.log(msg);
            document.getElementById('ApprovedClaimId').innerHTML = result;
		  }
		  else {
			  console.err(error);
		  }
    });
}


function fetchPendingClaim(){
    var fetchPendingClaimAdd = document.getElementById('fetchPendingClaimAdd').value ;
    var isOrg = myContractInstance.individualPendingClaims.call(fetchPendingClaimAdd,function(err,result){
		if(!err){
            var msg ="";
            for (var i = 0; i< result.length; i++){
                msg += result[i]+", ";
            }
            var msg = "Pending Claim Ids for this individual are =>" + msg;
            console.log(msg);
            document.getElementById('pendingClaimIdList').innerHTML = result;
		  }
		  else {
			  console.err(error);
		  }
    });
}

function fetchApprovedClaim(){
    var fetchApprovedClaimAdd = document.getElementById('fetchApprovedClaimAdd').value ;
    var isOrg = myContractInstance.individualApprovedClaims.call(fetchApprovedClaimAdd,function(err,result){
		if(!err){
            var msg ="";
            for (var i = 0; i< result.length; i++){
                msg += result[i]+", ";
            }
            var msg = "Approved Claim Ids for this individual are =>" + msg;
            console.log(msg);
            document.getElementById('ApprovedClaimIdList').innerHTML = result;
		  }
		  else {
			  console.err(error);
		  }
    });
}

function fetchPendingClaimForIssuer(){
    var fetchPendingClaimsForThisIssuer = document.getElementById('fetchPendingClaimsForThisIssuer').value ;
    var isOrg = myContractInstance.getAllPendingClaimIdsForThisIssuer.call(fetchPendingClaimsForThisIssuer,function(err,result){
		if(!err){
            var msg ="";
            for (var i = 0; i< result.length; i++){
                msg += result[i]+", ";
            }
            var msg = "Pending Claim Ids are =>" + msg;
            console.log(msg);
            document.getElementById('pendingClaimIdForIssuer').innerHTML = msg;
		  }
		  else {
			  console.err(error);
		  }
    });
}

function fetchApprovedClaimsByIssuer(){
    var fetchApprovedClaimIdsByIssuer = document.getElementById('fetchApprovedClaimIdsByIssuer').value ;
    var isOrg = myContractInstance.getAllApprovedClaimIdsForThisIssuer.call(fetchApprovedClaimIdsByIssuer,function(err,result){
		if(!err){
            var msg ="";
            for (var i = 0; i< result.length; i++){
                msg += result[i]+", ";
            }
            var msg = "Approved Claim Ids are =>" + msg;
            console.log(msg);
            document.getElementById('ApprovedClaimIdByIssuer').innerHTML = msg;
		  }
		  else {
			  console.err(error);
		  }
    });
}


function fetchDetail(){
    var claim = document.getElementById('claim').value ;
    var isOrg = myContractInstance.claims.call(claim,function(err,result){
		if(!err){
            var msg ="ClaimType="+result[0] +
            " ,Issuer="+ result[1]+", Requester="+result[2]+", Signature="+result[3]+
            ", Data="+result[4]+ ", URI="+result[5] + ", isApproved="+result[6];
            
            document.getElementById('FetchDetail').innerHTML = msg;
		  }
		  else {
			  console.err(error);
		  }
    });
}