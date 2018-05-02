pragma solidity 0.4.23;

import "./ERC20.sol";


contract TimeLock  {
    
    
    
    
    
    // beneficiary of tokens after they are released
    address public beneficiary;

    // timestamp when token release is enabled
    uint256 public releaseTime;
    
    
    //The token contract we are using.
    ERC20 tokenContract;
    
    address admin;  // Admin of the contract, (HIT tokens admin)
    
    
    //Constructor method which will accept token contract address.
    function TimeLock(address _tokenContractAddress) public {
        admin = msg.sender;
        tokenContract = ERC20(_tokenContractAddress);
    }
    
    
    //To make sure that lock tokens can only be called by the admin.
    modifier onlyOwner() {
        require(msg.sender==admin);
        _;
    }
    
    
    //To make sure that only beneficiary can call the release tokens method.
    modifier onlyBeneficiary() {
        require(msg.sender==beneficiary);
        _;
    }
    
    
    //Admin will call this method to lock the tokens. 
    //Before calling this method, admin should give allowance to this contract from the HIT ERC20 token balance.
    //It takes beneficiary, releaseTime, and amount as inputs.
    function LockTokens(address _beneficiary,uint _releaseTime,uint256 _amount)  public onlyOwner {
        
        require(_releaseTime > 0);
        require(_amount <= tokenContract.allowance(msg.sender, address(this)));
        require(tokenContract.transferFrom(msg.sender, address(this), _amount));
       
        beneficiary = _beneficiary;
        releaseTime = _releaseTime+block.timestamp;
        
    }
    
    
    //This method will be called by beneficiary to release tokens.
    //This method wont work, if you call before the release timestamp
    //This method can only be called by beneficiary
    //Once the above conditions are met, this method will transfer the tokens to the beneficiary
    
    function release() public onlyBeneficiary {
        
        require(block.timestamp >= releaseTime);

        uint256 amount = tokenContract.balanceOf(this);
        require(amount > 0);

        assert(tokenContract.transfer(beneficiary,amount));
    }
    
     
    
    
    
    
    
    
    
}
