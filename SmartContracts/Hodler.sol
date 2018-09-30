pragma solidity 0.4.25;

import "./library.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./ERC20.sol";

/*
* This Contract deals with the HODL strategy of HITT ICO.
* We are having four different HODL periods, 3 months( 90 days), 6 months(180 days), 
* 9 months(270 days) and 12 months(360 days). 
*
* The HODL contract shall be inititalized by Token distribution contract.
* Life of tokens in this Hodler contract shall be only 450 days.
*
* After 450 days:
* 1. Users won't be able to make any transaction related to claiming bonus after this. 
* 2. Admin shall call `claimHodlRewardsForMultipleAddresses()` before finalizing this  
* contract with all the valid addresses to provide them the bonus.
* 3. Admin shall call finalize on it and collect all the remaining funds.( ideally no  
* funds shall be present in this HODL contract, as admin shall be responsible for calling 
* the `claimHodlRewardsForMultipleAddresses()` to distribute the Bonus. users can call it by 
* themselves as well. as mentioned in point 2.)
* 
* Author : Vikas
* Auditor : Darryl Morris
*/
contract Hodler is Ownable {
    using SafeMath for uint256;
    bool istransferringTokens = false;
    address public admin; // getting updated in constructor
    
    /* 
    * HODLER reward tracker
    * stake amount per address
    * Claim flags for 3,6,9 & 12 months respectiviely.
    * It shall be really useful to get the details whether a particular address got his claims.
    */
    struct HODL {
        uint256 stake;
        bool claimed3M;
        bool claimed6M;
        bool claimed9M;
        bool claimed12M;
    }

    mapping (address => HODL) public hodlerStakes;

    /* 
    * Total current staking value & count of hodler addresses.
    * hodlerTotalValue = ∑ all the valid distributed tokens. 
    * This shall be the reference in which we shall distribute the HODL bonus.
    * hodlerTotalCount = count of the different addresses who is still HODLing their intial distributed tokens.
    */
    uint256 public hodlerTotalValue;
    uint256 public hodlerTotalCount;

    /*
    * To keep the snapshot of the tokens for 3,6,9 & 12 months after token sale.
    * Since people shall invalidate their stakes during the HODL period, we shall keep 
    * decreasing their share from the `hodlerTotalValue`. it shall always have the 
    * user's ICO contribution who've not invalidated their stakes.
    */
    uint256 public hodlerTotalValue3M;
    uint256 public hodlerTotalValue6M;
    uint256 public hodlerTotalValue9M;
    uint256 public hodlerTotalValue12M;

    /*
    * This shall be set deterministically to 45 days in the constructor itself 
    * from the deployment date of the Token Contract. 
    */
    uint256 public hodlerTimeStart;
 
    /*
    * Reward HITT token amount for 3,6,9 & 12 months respectively, which shall be 
    * calculated deterministically in the contructor
    */
    uint256 public TOKEN_HODL_3M;
    uint256 public TOKEN_HODL_6M;
    uint256 public TOKEN_HODL_9M;
    uint256 public TOKEN_HODL_12M;

    /* 
    * Total amount of tokens claimed so far while the HODL period
    */
    uint256 public claimedTokens;
    
    event LogHodlSetStake(address indexed _beneficiary, uint256 _value);
    event LogHodlClaimed(address indexed _beneficiary, uint256 _value);

    ERC20 public tokenContract;
    
    /*
    * Modifier: before hodl is started
    */
    modifier beforeHodlStart() {
        require(block.timestamp < hodlerTimeStart);
        _;
    }

    /*
    * Constructor: It shall set values deterministically
    * It should be created by a token distribution contract
    * Because we cannot multiply rational with integer, 
    * we are using 75 instead of 7.5 and dividing with 1000 instaed of 100.
    */
    constructor(uint256 _stake, address _admin) public {
        TOKEN_HODL_3M = (_stake*75)/1000;
        TOKEN_HODL_6M = (_stake*15)/100;
        TOKEN_HODL_9M = (_stake*30)/100;
        TOKEN_HODL_12M = (_stake*475)/1000;
        tokenContract = ERC20(msg.sender);
        hodlerTimeStart = block.timestamp + 45 days ; // These 45 days shall be used to distribute the tokens to the contributors of the ICO
        admin = _admin;
    }
    
    /*
    * This method will only be called by the `saleDistributionMultiAddress()` 
    * from the Token Contract. 
    */
    function addHodlerStake(address _beneficiary, uint256 _stake) public onlyOwner beforeHodlStart returns (bool) {
        // real change and valid _beneficiary is needed
        if (_stake == 0 || _beneficiary == address(0))
            return false;
        
        // add stake and maintain count
        if (hodlerStakes[_beneficiary].stake == 0)
            hodlerTotalCount = hodlerTotalCount.add(1);
        hodlerStakes[_beneficiary].stake = hodlerStakes[_beneficiary].stake.add(_stake);
        hodlerTotalValue = hodlerTotalValue.add(_stake);
        emit LogHodlSetStake(_beneficiary, hodlerStakes[_beneficiary].stake);
        return true;
    }
   
    /* 
    * This method can only be called by HITT token contract.
    * This will return true: when we successfully invalidate a stake
    * false: When we try to invalidate the stake of either already
    * invalidated or not participated stake holder in Pre-ico
    */ 
    function invalidate(address _account) public onlyOwner returns (bool) {
        if (hodlerStakes[_account].stake > 0 ) {
            hodlerTotalValue = hodlerTotalValue.sub(hodlerStakes[_account].stake); 
            hodlerTotalCount = hodlerTotalCount.sub(1);
            updateAndGetHodlTotalValue();
            delete hodlerStakes[_account];
            return true;
        }
        return false;
    }

    /* 
    * This method will be used whether the particular user has HODL stake or not.   
    */
    function isValid(address _account) view public returns (bool) {
        if (hodlerStakes[_account].stake > 0) {
            return true;
        }
        return false;
    }
    
    /*
    * Claiming HODL reward for an address.
    * Ideally it shall be called by Admin. But it can be called by anyone 
    * by passing the beneficiery address.
    */
    function claimHodlRewardFor(address _beneficiary) public returns (bool) {
        require(block.timestamp-hodlerTimeStart<= 450 days ); 
        // only when the address has a valid stake
        require(hodlerStakes[_beneficiary].stake > 0);
        updateAndGetHodlTotalValue();
        uint256 _stake = calculateStake(_beneficiary);
        if (_stake > 0) {
            if (istransferringTokens == false) {
            // increasing claimed tokens
            claimedTokens = claimedTokens.add(_stake);
                istransferringTokens = true;
            // Transferring tokens
            require(tokenContract.transfer(_beneficiary, _stake));
                istransferringTokens = false ;
            emit LogHodlClaimed(_beneficiary, _stake);
            return true;
            }
        } 
        return false;
    }

    /* 
    * This method is to calculate the HODL stake for a particular user at a time.
    */
    function calculateStake(address _beneficiary) internal returns (uint256) {
        uint256 _stake = 0;
                
        HODL memory hodler = hodlerStakes[_beneficiary];
        
        if(( hodler.claimed3M == false ) && ( block.timestamp - hodlerTimeStart) >= 90 days){ 
            _stake = _stake.add(hodler.stake.mul(TOKEN_HODL_3M).div(hodlerTotalValue3M));
            hodler.claimed3M = true;
        }
        if(( hodler.claimed6M == false ) && ( block.timestamp - hodlerTimeStart) >= 180 days){ 
            _stake = _stake.add(hodler.stake.mul(TOKEN_HODL_6M).div(hodlerTotalValue6M));
            hodler.claimed6M = true;
        }
        if(( hodler.claimed9M == false ) && ( block.timestamp - hodlerTimeStart) >= 270 days ){ 
            _stake = _stake.add(hodler.stake.mul(TOKEN_HODL_9M).div(hodlerTotalValue9M));
            hodler.claimed9M = true;
        }
        if(( hodler.claimed12M == false ) && ( block.timestamp - hodlerTimeStart) >= 360 days){ 
            _stake = _stake.add(hodler.stake.mul(TOKEN_HODL_12M).div(hodlerTotalValue12M));
            hodler.claimed12M = true;
        }
        
        hodlerStakes[_beneficiary] = hodler;
        return _stake;
    }
    
    /*
    * This method is to complete HODL period. Any leftover tokens will 
    * return to admin and then will be added to the growth pool after 450 days .
    */
    function finalizeHodler() public returns (bool) {
        require(msg.sender == admin);
        require(block.timestamp >= hodlerTimeStart + 450 days ); 
        uint256 amount = tokenContract.balanceOf(this);
        require(amount > 0);
        if (istransferringTokens == false) {
            istransferringTokens = true;
            require(tokenContract.transfer(admin,amount));
            istransferringTokens = false;
            return true;
        }
        return false;
    }
    
    

    /*
    * `claimHodlRewardsForMultipleAddresses()` for multiple addresses.
    * Anyone can call this function and distribute hodl rewards.
    * `_beneficiaries` is the array of addresses for which we want to claim HODL rewards.
    */
    function claimHodlRewardsForMultipleAddresses(address[] _beneficiaries) external returns (bool) {
        require(block.timestamp - hodlerTimeStart <= 450 days ); 
        uint8 length = uint8(_beneficiaries.length);
        for (uint8 i = 0; i < length ; i++) {
            if(hodlerStakes[_beneficiaries[i]].stake > 0 && (hodlerStakes[_beneficiaries[i]].claimed3M == false || hodlerStakes[_beneficiaries[i]].claimed6M == false || hodlerStakes[_beneficiaries[i]].claimed9M == false || hodlerStakes[_beneficiaries[i]].claimed12M == false)) { 
                require(claimHodlRewardFor(_beneficiaries[i]));
            }
        }
        return true;
    }
    
    /* 
    * This method is used to set the amount of `hodlerTotalValue` remaining.
    * `hodlerTotalValue` will keep getting lower as the people shall be invalidating their stakes over the period of 12 months.
    * Setting 3, 6, 9 & 12 months total staked token value.
    */
    function updateAndGetHodlTotalValue() public returns (uint) {
        if (block.timestamp >= hodlerTimeStart+ 90 days && hodlerTotalValue3M == 0) {   
            hodlerTotalValue3M = hodlerTotalValue;
        }

        if (block.timestamp >= hodlerTimeStart+ 180 days && hodlerTotalValue6M == 0) { 
            hodlerTotalValue6M = hodlerTotalValue;
        }

        if (block.timestamp >= hodlerTimeStart+ 270 days && hodlerTotalValue9M == 0) { 
            hodlerTotalValue9M = hodlerTotalValue;
        }
        if (block.timestamp >= hodlerTimeStart+ 360 days && hodlerTotalValue12M == 0) { 
            hodlerTotalValue12M = hodlerTotalValue;
        }

        return hodlerTotalValue;
    }
}
