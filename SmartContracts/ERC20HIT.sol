pragma solidity 0.4.25;

import "./Hodler.sol";
import "./library.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./ERC20.sol";


/*
* The HITT token contract, it is a standard ERC20 contract with a small updates to accomodate 
* our conditions of adding, validating the stakes.
* 
* Author : Vikas
* Auditor : Darryl Morris
*/
contract HITT is ERC20,Ownable {    
    using SafeMath for uint256;
    string public constant name = "Health Information Transfer Token";
    string public constant symbol = "HITT";
    uint8 public constant decimals = 18;
    uint256 private constant totalSupply1 = 1000000000 * 10 ** uint256(decimals);
    address[] public founders = [
        0x89Aa30ca3572eB725e5CCdcf39d44BAeD5179560, 
        0x1c61461794df20b0Ed8C8D6424Fd7B312722181f];
    address[] public advisors = [
        0xc83eDeC2a4b6A992d8fcC92484A82bC312E885B5, 
        0x9346e8A0C76825Cd95BC3679ab83882Fd66448Ab, 
        0x3AA2958c7799faAEEbE446EE5a5D90057fB5552d, 
        0xF90f4D2B389D499669f62F3a6F5E0701DFC202aF, 
        0x45fF9053b44914Eedc90432c3B6674acDD400Cf1, 
        0x663070ab83fEA900CB7DCE7c92fb44bA9E0748DE];
    mapping (address => uint256)  balances;
    mapping (address => mapping (address => uint256))  allowed;
    mapping (address => uint64) lockTimes;
    
    /*
    * 31104000 = 360 Days in seconds. We're not using whole 365 days for `tokenLockTime` 
    * because we have used multiple of 90 for 3M, 6M, 9M and 12M in the Hodler Smart contract's time calculation as well.
    * We shall use it to lock the tokens of Advisors and Founders. 
    */
    uint64 public constant tokenLockTime = 31104000;
    
    /*
    * Need to update the actual value during deployement. update needed.
    * This is HODL pool. It shall be distributed for the whole year as a 
    * HODL bonus among the people who shall not move their ICO tokens for 
    * 3,6,9 and 12 months respectively. 
    * Setting it 200 Million Temporarily. 
    * We shall know the exact value when we shall be done with the ICO period.
    */
    uint256 public constant hodlerPoolTokens = 200000000 * 10 ** uint256(decimals) ; 
    Hodler public hodlerContract;

    /*
    * The constructor method which will initialize the token supply.
    * We've multiple `Transfer` events emitting from the Constructor so that Etherscan can pick 
    * it as the contributor's address and can show correct informtaion on the site.
    * We're deliberately choosing the manual transfer of the tokens to the advisors and the founders over the 
    * internal `_transfer()` because the admin might use the same account for deploying this Contract and as an founder address.
    * which will have `locktime`.
    */
    constructor() public {
        uint8 i=0 ;
        balances[msg.sender] = totalSupply1;
        emit Transfer(0x0,msg.sender,totalSupply1);
        uint256 length = founders.length ;
        for( ; i < length ; i++ ){
            /*
            * These 45 days shall be used to distribute the tokens to the contributors of the ICO.
            */
            lockTimes[founders[i]] = uint64(block.timestamp + 45 days + tokenLockTime );
        }
        length = advisors.length ;
        for( i=0 ; i < length ; i++ ){
            lockTimes[advisors[i]] = uint64(block.timestamp +  45 days + tokenLockTime); 
            balances[msg.sender] = balances[msg.sender].sub(40000 * 10 ** uint256(decimals));
            balances[advisors[i]] = 40000 * 10 ** uint256(decimals) ;
            emit Transfer( msg.sender, advisors[i], 40000 * 10 ** uint256(decimals) );
        }
        balances[msg.sender] = balances[msg.sender].sub(200000000 * 10 ** uint256(decimals));
        balances[founders[0]] = 170000000 * 10 ** uint256(decimals) ;
        balances[founders[1]] =  30000000 * 10 ** uint256(decimals) ; 
        emit Transfer( msg.sender, founders[0], 170000000 * 10 ** uint256(decimals) );
        emit Transfer( msg.sender, founders[1],  30000000 * 10 ** uint256(decimals) );
        hodlerContract = new Hodler(hodlerPoolTokens, msg.sender); 
        balances[msg.sender] = balances[msg.sender].sub(hodlerPoolTokens);
        balances[address(hodlerContract)] = hodlerPoolTokens; // giving the total hodler bonus to the HODLER contract to distribute.        
        emit Transfer( msg.sender, address(hodlerContract), hodlerPoolTokens );
    }
    

    /*
    * Constant function to return the total supply of the HITT contract
    */
    function totalSupply() public view returns(uint256) {
        return totalSupply1;
    }

    /* 
    * Transfer amount from one account to another. The code takes care that it doesn't transfer the tokens to contracts. 
    * This function trigger the action to invalidate the participant's right to get the
    *  HODL rewards if they make any transaction within the hodl period.
    * Getting into the HODL club is optional by not moving their tokens after receiving tokens in their wallet for 
    * pre-defined period like 3,6,9 or 12 months.
    * More details are here about the HODL T&C : https://medium.com/@Vikas1188/lets-hodl-with-emrify-bc5620a14237
    */
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(!isContract(_to));
        require(block.timestamp > lockTimes[_from]);
        uint256 prevBalTo = balances[_to] ;
        uint256 prevBalFrom = balances[_from];
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(hodlerContract.isValid(_from)) {
            require(hodlerContract.invalidate(_from));
        }
        emit Transfer(_from, _to, _value);
        assert(_value == balances[_to].sub(prevBalTo) );
        assert(_value == prevBalFrom.sub(balances[_from]));
        return true;
    }
	
    /*
    * Standard token transfer method.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    /*
    * This method will allow a 3rd person to spend tokens (requires `approval()` 
    * to be called before with that 3rd person's address)
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowed[_from][msg.sender]); 
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        return _transfer(_from, _to, _value);
    }

    /*
    * Approve `_spender` to move `_value` tokens from owner's account
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(block.timestamp>lockTimes[msg.sender]);
        allowed[msg.sender][_spender] = _value; 
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
    * Returns balance
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /*
    * Returns whether the `_spender` address is allowed to move the coins of the `_owner` 
    */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    /*
    * This method will be used by the admin to allocate tokens to multiple contributors in a single shot.
    */
    function saleDistributionMultiAddress(address[] _addresses,uint256[] _values) public onlyOwner returns (bool) {    
        require( _addresses.length > 0 && _addresses.length == _values.length); 
        uint256 length = _addresses.length ;
        for(uint8 i=0 ; i < length ; i++ )
        {
            if(_addresses[i] != address(0) && _addresses[i] != owner) {
                require(hodlerContract.addHodlerStake(_addresses[i], _values[i]));
                _transfer( msg.sender, _addresses[i], _values[i]) ;
            }
        }
        return true;
    }
     
    /*
    * This method will be used to send tokens to multiple addresses.
    */
    function batchTransfer(address[] _addresses,uint256[] _values) public  returns (bool) {    
        require(_addresses.length > 0 && _addresses.length == _values.length);
        uint256 length = _addresses.length ;
        for( uint8 i = 0 ; i < length ; i++ ){
            
            if(_addresses[i] != address(0)) {
                _transfer(msg.sender, _addresses[i], _values[i]);
            }
        }
        return true;
    }   
    
    /*
    * This method checks whether the address is a contract or not. 
    */
    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
    
}