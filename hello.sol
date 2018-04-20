pragma solidity ^0.4.13;

contract Hello {
  function sum(uint _a, uint _b) returns (uint o_sum, string o_author) {
    o_sum = _a + _b;
    o_author = "freewolf";
  }
}
