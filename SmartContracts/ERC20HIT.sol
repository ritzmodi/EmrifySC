pragma solidity 0.4.23;

import "./Hodler.sol";
import "./library.sol";


/*
This is the interface of the HIT token contract(just below). It gives the basic idea 
of the functions we are using in the HIT contract.
*/

interface TokenInterface {	
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*
The Main HIT token contract, it is a standard ERC20 contract with a small addition.
The addition is that this contract will notify another contract whenever token transfer
happens.
*/


contract HIT is TokenInterface,Ownable {    
    using SafeMath for uint256;
    string public constant name = "Health Information Token";
    string public constant symbol = "HIT";
    uint8 public constant decimals = 18;
    uint256 public constant  totalSupply = 1000000000 * 10 ** uint256(decimals);
    mapping (address => uint256)  balances;
    mapping (address => mapping (address => uint256))  allowed;
    Hodler public hodlerContract;

    // The constructor method which will initialize the token supply.	    
    constructor() public {
        emit Transfer(0x0,msg.sender,totalSupply);
        balances[msg.sender] = totalSupply;	
    }
    
    // To set the HODL contract address, This contract will notify HODL on token transfer. Check `transfer()` method
    function setHolderContractAddress(address _holderContractAddress) public onlyOwner {
        require(hodlerContract==address(0));
        hodlerContract = Hodler(_holderContractAddress);
    }

    /* 
    Transfer amount from one account to another (may require approval). This function trigger the action to 
    invalidate the participant's right to get the HODL rewards if they make any transation within the hodl period.
    Getting into the HODL club is optional by not moving their tokens after reveiving tokens in their wallet for 
    pre-defined period like 3,6,9 or 12 months.
    More details are here about the HODL T&C : https://medium.com/@Vikas1188/lets-hodl-with-emrify-bc5620a14237
    */
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        require(hodlerContract.invalidate(_from));
        emit Transfer(_from, _to, _value);
        return true;
    }
	
    // Standard token transfer method.
    function transfer(address _to, uint256 _value) public returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    /*
    This method will allow a 3rd person to spend tokens (requires `approval()` 
    to be called before with that 3rd person's address)
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        return _transfer(_from, _to, _value);
    }

    // Approve `_spender` to move `_value` tokens from owner's account
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Returns balance
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    // Returns whether the `_spender` address is allowed to move the coins of the `_owner` 
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
}

