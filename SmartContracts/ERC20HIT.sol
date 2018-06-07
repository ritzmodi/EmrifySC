pragma solidity 0.4.23;

import "./Hodler.sol";
import "./library.sol";


interface TokenInterface {	
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract HIT is TokenInterface,Ownable {    
    using SafeMath for uint256;
    string public constant name = "Health Information Token";
    string public constant symbol = "HIT";
    uint8 public constant decimals = 18;
    uint256 public constant  totalSupply = 1000000000 * 10 ** uint256(decimals);
    mapping (address => uint256)  balances;
    mapping (address => mapping (address => uint256))  allowed;
    Hodler public hodlerContract;
    
    constructor() public {
        emit Transfer(0x0,msg.sender,totalSupply);
	balances[msg.sender] = totalSupply;	
    }
    
    function setHolderContractAddress(address _holderContractAddress) public onlyOwner {
        require(hodlerContract==address(0));
        hodlerContract = Hodler(_holderContractAddress);
    }

    // Transfer amount from one account to another (may require approval)
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
	require(balances[_from] >= _value);
	balances[_from] = balances[_from].sub(_value);
	balances[_to] = balances[_to].add(_value);
	require(hodlerContract.invalidate(_from));
	emit Transfer(_from, _to, _value);
	return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
	return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
	require(_value <= allowed[_from][msg.sender]);
    	allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
	return _transfer(_from, _to, _value);
    }

    // Approve spender from owner's account
    function approve(address _spender, uint256 _value) public returns (bool) {
	allowed[msg.sender][_spender] = _value;
	emit Approval(msg.sender, _spender, _value);
	return true;
    }

    // Return balance
    function balanceOf(address _owner) public view returns (uint256) {
	return balances[_owner];
    }

    // Return allowance
    function allowance(address _owner, address _spender) public view returns (uint256) {
	return allowed[_owner][_spender];
    }
}

