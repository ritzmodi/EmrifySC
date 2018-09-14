pragma solidity 0.4.24;

contract Login {
  
    event LoginAttempt(address sender, string challenge);

    function login(string challenge_str) public {
        emit LoginAttempt(msg.sender, challenge_str);
    }

}
