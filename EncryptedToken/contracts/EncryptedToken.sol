pragma solidity ^0.4.17;

contract EncryptedToken {
  uint256 INITIAL_SUPPLY = 21000000;
  mapping (address => uint256) balances;
  function EncryptedToken() {
    balances[msg.sender] = INITIAL_SUPPLY;
  }

  //转帐到一个指定的地址
  function transfer(address _to, uint256 _amount) {
    assert(balances[msg.sender] >= _amount);
    balances[msg.sender] -= _amount;
    balances[_to] += _amount;
  }

  //查看指定地址的余额
  function balanceOf(address _owner) constant returns (uint256) {
    return balances[_owner];
  }
}
