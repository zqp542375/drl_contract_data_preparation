pragma solidity ^0.5.15;


library SafeMath 
{
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
}






contract nerveShares {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public totalDividends;

    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => uint256) internal lastDividends;
    mapping (address => bool) public lockedAccounts;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Claim(address indexed _from, uint256 value);
    event Locked(address indexed _from, bool state);

    using SafeMath for uint256;

    constructor() public
    {
        decimals = 18;                              
        totalSupply = 1000000*10**18;               
        name = "Nerve";                             
        symbol = "NRV";                             

        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    
    function dividendBalanceOf(address account) public view returns (uint256) 
    {
        uint256 newDividends = totalDividends.sub(lastDividends[account]);
        uint256 product = balanceOf[account].mul(newDividends);
        return product.div(totalSupply);
    }   

    
    function internalDividendBalanceOf(address account, uint256 tempLastDividends) internal view returns (uint256) 
    {
        uint256 newDividends = totalDividends.sub(tempLastDividends);
        uint256 product = balanceOf[account].mul(newDividends);
        return product.div(totalSupply);
    }   

    
    function claimDividend() external 
    {
        uint256 tempLastDividends = lastDividends[msg.sender];
        lastDividends[msg.sender] = totalDividends;
        uint256 owing = internalDividendBalanceOf(msg.sender, tempLastDividends);

        require(owing > 0, "No dividends to claim.");

        msg.sender.transfer(owing);
        
        emit Claim(msg.sender, owing);
    }

    
    function lockToken(bool lock) external
    {
        lockedAccounts[msg.sender] = lock;
        
        emit Locked(msg.sender, lock);
    }

    
    function transfer(address payable to, uint256 value) external returns(bool success)
    {
        _transfer(msg.sender, to, value);
        return true;
    }

    
    function _transfer(address payable from, address payable to, uint256 value) internal
    {   
        require(value > 0, "Transferred value has to be grater than 0.");
        require(to != address(0), "0x00 address not allowed.");
        require(lockedAccounts[to] == false, "Target address is locked.");
        require(lockedAccounts[from] == false, "Sending address is locked.");
        require(value <= balanceOf[from], "Not enough funds on sender address.");
        require(balanceOf[to] + value >= balanceOf[to], "Overflow protection.");
 
        uint256 fromOwing = dividendBalanceOf(from);
        uint256 toOwing = dividendBalanceOf(to);

        lastDividends[to] = totalDividends;
        lastDividends[from] = totalDividends;

        totalDividends = totalDividends.add(fromOwing);
        totalDividends = totalDividends.add(toOwing);

        balanceOf[from] -= value;
        balanceOf[to] += value;
 
        emit Transfer(from, to, value);
    }

    
    function transferFrom(address payable from, address payable to, uint value) external returns (bool success)
    {     
        require(allowance[from][msg.sender] >= value, "Funds not approved."); 
        require(balanceOf[from] >= value, "Not enough funds on sender address.");
        require(balanceOf[to] + value >= balanceOf[to], "Overflow protection.");

        allowance[from][msg.sender] -= value;
  
        _transfer(from, to, value);

        return true;
    }

    
    function approve(address spender, uint value) external returns (bool) 
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
   
     
    function contractBalance() external view returns(uint256 amount)
    {
        return (address(this).balance);
    }
    
    
    function receiveETH() external payable
    {
        totalDividends = totalDividends.add(msg.value);
    }
    
    
    function () external payable 
    {
        totalDividends = totalDividends.add(msg.value);
    }
    
}