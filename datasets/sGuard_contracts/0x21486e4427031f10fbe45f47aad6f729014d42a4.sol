pragma solidity 0.5.12;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}




contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}




library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        
        
        
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}




library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        
        

        
        
        
        
        
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}





pragma solidity 0.5.12;


contract BalanceChecker is Ownable {
  using SafeERC20 for IERC20;
  using Address for address;

  
  function walletBalances(
    address userAddress,
    address[] calldata tokenAddresses
  ) external view returns (uint256[] memory) {
    require(tokenAddresses.length > 0);
    uint256[] memory balances = new uint256[](tokenAddresses.length);

    for(uint256 i = 0; i < tokenAddresses.length; i++){
      if (tokenAddresses[i] != address(0x0)) {
        balances[i] = tokenBalance(userAddress, tokenAddresses[i]);
      } else {
        balances[i] = userAddress.balance;
      }
    }
    return balances;
  }

  
  function walletAllowances(
    address userAddress,
    address spenderAddress,
    address[] calldata tokenAddresses
  ) external view returns (uint256[] memory) {
    require(tokenAddresses.length > 0);
    uint256[] memory allowances = new uint256[](tokenAddresses.length);

    for(uint256 i = 0; i < tokenAddresses.length; i++) {
      allowances[i] = tokenAllowance(userAddress, spenderAddress, tokenAddresses[i]);
    }
    return allowances;
  }

  
  function allAllowancesForManyAccounts(
    address[] calldata userAddresses,
    address spenderAddress,
    address[] calldata tokenAddresses
  ) external view returns (uint256[] memory) {
    uint256[] memory allowances = new uint256[](
      tokenAddresses.length * userAddresses.length);

    for(uint256 user = 0; user < userAddresses.length; user++){
      for(uint256 token = 0; token < tokenAddresses.length; token++) {
        allowances[(user * tokenAddresses.length) + token] = tokenAllowance(
          userAddresses[user], spenderAddress, tokenAddresses[token]);
      }
    }
    return allowances;
  }

  
  function allBalancesForManyAccounts(
    address[] calldata userAddresses,
    address[] calldata tokenAddresses
  ) external view returns (uint256[] memory) {
    uint256[] memory balances = new uint256[](tokenAddresses.length * userAddresses.length);
    for(uint256 user = 0; user < userAddresses.length; user++){
      for(uint256 token = 0; token < tokenAddresses.length; token++){
        if( tokenAddresses[token] != address(0x0) ) { 
          balances[(user * tokenAddresses.length) + token] = tokenBalance(userAddresses[user], tokenAddresses[token]);
        } else {
          balances[(user * tokenAddresses.length) + token] =  userAddresses[user].balance;
        }
      }
    }
    return balances;
  }

  
  function destruct(address payable recipientAddress) public onlyOwner {
    selfdestruct(recipientAddress);
  }

  
  function withdraw() public onlyOwner {
    (bool success, ) = address(owner()).call.value(address(this).balance)("");
    require(success, "ETH_WITHDRAW_FAILED");
  }

  
  function withdrawToken(
    address tokenAddress,
    uint256 amount
  ) public onlyOwner {
    require(tokenAddress != address(0x0)); 
    IERC20(tokenAddress).safeTransfer(msg.sender, amount);
  }

  
  function tokenAllowance(
    address userAddress,
    address spenderAddress,
    address tokenAddress
  ) public view returns (uint256) {
    if (tokenAddress.isContract()) {
      IERC20 token = IERC20(tokenAddress);
      
      (bool success, ) = address(token).staticcall(abi.encodeWithSelector(
        token.allowance.selector, userAddress, spenderAddress));
      if (success) {
        return token.allowance(userAddress, spenderAddress);
      }
      return 0;
    }
    return 0;
  }

  
  function tokenBalance(
    address userAddress,
    address tokenAddress
  ) public view returns (uint256) {
    if (tokenAddress.isContract()) {
      IERC20 token = IERC20(tokenAddress);
      
      (bool success, ) = address(token).staticcall(abi.encodeWithSelector(
        token.balanceOf.selector, userAddress));
      if (success) {
        return token.balanceOf(userAddress);
      }
      return 0;
    }
    return 0;
  }
}