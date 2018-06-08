pragma solidity 0.4.23;

/*
This contract is created to get the ABI of the ETHEREUM's standard ERC20 contract
in other contracts when we initialize the ERC20 object variable. We later implement the
functions of this contract and then we call those functions to full-fill the requirement.
We can do it with another way as well to implement a full-fledged ERC20 implementation &
then use that Smart Contract to initialize the objects to get the ABI of the ERC20 token.
But that approach will increase the cost of the transactions and in which we shall be passing
the address of the full-blown implementation of the ERC20 token.
So, the best way is to get create a lightweight ERC20 contract and use that contract to fetch 
its ABI whenever and wherever necessary. & Then call the implemented functions.
*/
contract ERC20 {
    uint public totalSupply;
    event Transfer(address indexed from, address indexed to, uint256 value);  
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function balanceOf(address who) public view returns (uint256);
    function allowance(address owner, address spender) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool ok);
    function transferFrom(address from, address to, uint256 value) public returns (bool ok);
    function approve(address spender, uint256 value) public returns (bool ok);  
}

