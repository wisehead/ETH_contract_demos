pragma solidity ^0.4.11;

contract Token {
    function transfer(address to, uint256 value) public returns (bool success);
    function transferFrom(address from, address to, uint256 value) public returns (bool success);
    function approve(address spender, uint256 value) public returns (bool success);

    function totalSupply() public pure returns (uint256) {}
    function balanceOf(address owner) public constant returns (uint256 balance);
    function allowance(address owner, address spender) public constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Owned {
    address public owner;
    address newOwner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;
    }

    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}

contract StandardToken is Owned, Token {
    event Burn(address indexed _burner, uint _value);
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    function transfer(address _to, uint256 _value)
        public
        returns (bool)
    {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool)
    {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        require(_to != address(0));
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        constant
        public
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    function balanceOf(address _owner)
        constant
        public
        returns (uint256)
    {
        return balances[_owner];
    }

    function burn(uint256 wad) onlyOwner returns (bool) {
        require (balances[msg.sender] >= wad);
        require (totalSupply >= wad);
        balances[msg.sender] = balances[msg.sender] - wad;
        totalSupply = totalSupply - wad;
        Burn(msg.sender, wad);
        Transfer(msg.sender, address(0x0), wad);
        return true;
    }

    // save some gas by making only one contract call
    function burnFrom(address _from, uint256 _value) onlyOwner returns (bool) 
    {
        assert( transferFrom( _from, msg.sender, _value ) );
        return burn(_value);
    }

}

contract XiaoshiTokenB is StandardToken {

    string constant public name = "XiaoshiB Token";
    string constant public symbol = "XSHB";
    uint8 constant public decimals = 18;

    function XiaoshiTokenB()
        public
    {
        totalSupply = 10 * 100000000 * 10**18; // will not change
        balances[msg.sender] = totalSupply;
    }
}