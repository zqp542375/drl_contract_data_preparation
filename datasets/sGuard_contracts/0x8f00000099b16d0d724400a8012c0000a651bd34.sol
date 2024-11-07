pragma solidity 0.5.11; 


interface TimelockerModifiersInterface {
  function initiateModifyTimelockInterval(
    bytes4 functionSelector, uint256 newTimelockInterval, uint256 extraTime
  ) external;

  function modifyTimelockInterval(
    bytes4 functionSelector, uint256 newTimelockInterval
  ) external;

  function initiateModifyTimelockExpiration(
    bytes4 functionSelector, uint256 newTimelockExpiration, uint256 extraTime
  ) external;

  function modifyTimelockExpiration(
    bytes4 functionSelector, uint256 newTimelockExpiration
  ) external;
}


library SafeMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
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
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}



contract TwoStepOwnable {
  address private _owner;

  address private _newPotentialOwner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  
  constructor() internal {
    _owner = tx.origin;
    emit OwnershipTransferred(address(0), _owner);
  }

  
  function owner() public view returns (address) {
    return _owner;
  }

  
  modifier onlyOwner() {
    require(isOwner(), "TwoStepOwnable: caller is not the owner.");
    _;
  }

  
  function isOwner() public view returns (bool) {
    return msg.sender == _owner;
  }

  
  function transferOwnership(address newOwner) public onlyOwner {
    require(
      newOwner != address(0),
      "TwoStepOwnable: new potential owner is the zero address."
    );

    _newPotentialOwner = newOwner;
  }

  
  function cancelOwnershipTransfer() public onlyOwner {
    delete _newPotentialOwner;
  }

  
  function acceptOwnership() public {
    require(
      msg.sender == _newPotentialOwner,
      "TwoStepOwnable: current owner must set caller as new potential owner."
    );

    delete _newPotentialOwner;

    emit OwnershipTransferred(_owner, msg.sender);

    _owner = msg.sender;
  }
}



contract Timelocker {
  using SafeMath for uint256;

  
  event TimelockInitiated(
    bytes4 functionSelector, 
    uint256 timeComplete,    
    bytes arguments,         
    uint256 timeExpired      
  );

  
  event TimelockIntervalModified(
    bytes4 functionSelector, 
    uint256 oldInterval,     
    uint256 newInterval      
  );

  
  event TimelockExpirationModified(
    bytes4 functionSelector, 
    uint256 oldExpiration,   
    uint256 newExpiration    
  );

  
  struct Timelock {
    uint128 complete;
    uint128 expires;
  }

  
  struct TimelockDefaults {
    uint128 interval;
    uint128 expiration;
  }

  
  mapping(bytes4 => mapping(bytes32 => Timelock)) private _timelocks;

  
  mapping(bytes4 => TimelockDefaults) private _timelockDefaults;

  
  mapping(bytes4 => mapping(bytes4 => bytes32)) private _protectedTimelockIDs;

  
  bytes4 private constant _MODIFY_TIMELOCK_INTERVAL_SELECTOR = bytes4(
    0xe950c085
  );

  
  bytes4 private constant _MODIFY_TIMELOCK_EXPIRATION_SELECTOR = bytes4(
    0xd7ce3c6f
  );

  
  uint256 private constant _A_TRILLION_YEARS = 365000000000000 days;

  
  constructor() internal {
    TimelockerModifiersInterface modifiers;

    bytes4 targetModifyInterval = modifiers.modifyTimelockInterval.selector;
    require(
      _MODIFY_TIMELOCK_INTERVAL_SELECTOR == targetModifyInterval,
      "Incorrect modify timelock interval selector supplied."
    );

    bytes4 targetModifyExpiration = modifiers.modifyTimelockExpiration.selector;
    require(
      _MODIFY_TIMELOCK_EXPIRATION_SELECTOR == targetModifyExpiration,
      "Incorrect modify timelock expiration selector supplied."
    );
  }

  
  function getTimelock(
    bytes4 functionSelector, bytes memory arguments
  ) public view returns (
    bool exists,
    bool completed,
    bool expired,
    uint256 completionTime,
    uint256 expirationTime
  ) {
    
    bytes32 timelockID = keccak256(abi.encodePacked(arguments));

    
    completionTime = uint256(_timelocks[functionSelector][timelockID].complete);
    exists = completionTime != 0;
    expirationTime = uint256(_timelocks[functionSelector][timelockID].expires);
    completed = exists && now > completionTime;
    expired = exists && now > expirationTime;
  }

  
  function getDefaultTimelockInterval(
    bytes4 functionSelector
  ) public view returns (uint256 defaultTimelockInterval) {
    defaultTimelockInterval = uint256(
      _timelockDefaults[functionSelector].interval
    );
  }

  
  function getDefaultTimelockExpiration(
    bytes4 functionSelector
  ) public view returns (uint256 defaultTimelockExpiration) {
    defaultTimelockExpiration = uint256(
      _timelockDefaults[functionSelector].expiration
    );
  }

  
  function _setTimelock(
    bytes4 functionSelector, bytes memory arguments, uint256 extraTime
  ) internal {
    
    require(extraTime < _A_TRILLION_YEARS, "Supplied extra time is too large.");

    
    bytes32 timelockID = keccak256(abi.encodePacked(arguments));

    
    
    if (
      functionSelector == _MODIFY_TIMELOCK_INTERVAL_SELECTOR ||
      functionSelector == _MODIFY_TIMELOCK_EXPIRATION_SELECTOR
    ) {
      
      (bytes4 modifiedFunction, uint256 duration) = abi.decode(
        arguments, (bytes4, uint256)
      );

      
      require(
        duration < _A_TRILLION_YEARS,
        "Supplied default timelock duration to modify is too large."
      );

      
      bytes32 currentTimelockID = (
        _protectedTimelockIDs[functionSelector][modifiedFunction]
      );

      
      if (currentTimelockID != timelockID) {
        
        if (currentTimelockID != bytes32(0)) {
          delete _timelocks[functionSelector][currentTimelockID];
        }

        
        _protectedTimelockIDs[functionSelector][modifiedFunction] = timelockID;
      }
    }

    
    uint256 timelock = uint256(
      _timelockDefaults[functionSelector].interval
    ).add(now).add(extraTime);

    
    uint256 expiration = timelock.add(
      uint256(_timelockDefaults[functionSelector].expiration)
    );

    
    Timelock storage timelockStorage = _timelocks[functionSelector][timelockID];

    
    uint256 currentTimelock = uint256(timelockStorage.complete);

    
    
    
    
    
    
    require(
      currentTimelock == 0 || timelock > currentTimelock,
      "Existing timelocks may only be extended."
    );

    
    timelockStorage.complete = uint128(timelock);
    timelockStorage.expires = uint128(expiration);

    
    emit TimelockInitiated(functionSelector, timelock, arguments, expiration);
  }

  
  function _modifyTimelockInterval(
    bytes4 functionSelector, uint256 newTimelockInterval
  ) internal {
    
    _enforceTimelockPrivate(
      _MODIFY_TIMELOCK_INTERVAL_SELECTOR,
      abi.encode(functionSelector, newTimelockInterval)
    );

    
    delete _protectedTimelockIDs[
      _MODIFY_TIMELOCK_INTERVAL_SELECTOR
    ][functionSelector];

    
    _setTimelockIntervalPrivate(functionSelector, newTimelockInterval);
  }

  
  function _modifyTimelockExpiration(
    bytes4 functionSelector, uint256 newTimelockExpiration
  ) internal {
    
    _enforceTimelockPrivate(
      _MODIFY_TIMELOCK_EXPIRATION_SELECTOR,
      abi.encode(functionSelector, newTimelockExpiration)
    );

    
    delete _protectedTimelockIDs[
      _MODIFY_TIMELOCK_EXPIRATION_SELECTOR
    ][functionSelector];

    
    _setTimelockExpirationPrivate(functionSelector, newTimelockExpiration);
  }

  
  function _setInitialTimelockInterval(
    bytes4 functionSelector, uint256 newTimelockInterval
  ) internal {
    
    assembly { if extcodesize(address) { revert(0, 0) } }

    
    _setTimelockIntervalPrivate(functionSelector, newTimelockInterval);
  }

  
  function _setInitialTimelockExpiration(
    bytes4 functionSelector, uint256 newTimelockExpiration
  ) internal {
    
    assembly { if extcodesize(address) { revert(0, 0) } }

    
    _setTimelockExpirationPrivate(functionSelector, newTimelockExpiration);
  }

  
  function _enforceTimelock(bytes memory arguments) internal {
    
    _enforceTimelockPrivate(msg.sig, arguments);
  }

  
  function _enforceTimelockPrivate(
    bytes4 functionSelector, bytes memory arguments
  ) private {
    
    bytes32 timelockID = keccak256(abi.encodePacked(arguments));

    
    Timelock memory timelock = _timelocks[functionSelector][timelockID];

    uint256 currentTimelock = uint256(timelock.complete);
    uint256 expiration = uint256(timelock.expires);

    
    require(
      currentTimelock != 0 && currentTimelock <= now, "Timelock is incomplete."
    );

    
    require(expiration > now, "Timelock has expired.");

    
    delete _timelocks[functionSelector][timelockID];
  }

  
  function _setTimelockIntervalPrivate(
    bytes4 functionSelector, uint256 newTimelockInterval
  ) private {
    
    require(
      newTimelockInterval < _A_TRILLION_YEARS,
      "Supplied minimum timelock interval is too large."
    );

    
    uint256 oldTimelockInterval = uint256(
      _timelockDefaults[functionSelector].interval
    );

    
    _timelockDefaults[functionSelector].interval = uint128(newTimelockInterval);

    
    emit TimelockIntervalModified(
      functionSelector, oldTimelockInterval, newTimelockInterval
    );
  }

  
  function _setTimelockExpirationPrivate(
    bytes4 functionSelector, uint256 newTimelockExpiration
  ) private {
    
    require(
      newTimelockExpiration < _A_TRILLION_YEARS,
      "Supplied default timelock expiration is too large."
    );

    
    require(
      newTimelockExpiration > 1 minutes,
      "New timelock expiration is too short."
    );

    
    uint256 oldTimelockExpiration = uint256(
      _timelockDefaults[functionSelector].expiration
    );

    
    _timelockDefaults[functionSelector].expiration = uint128(
      newTimelockExpiration
    );

    
    emit TimelockExpirationModified(
      functionSelector, oldTimelockExpiration, newTimelockExpiration
    );
  }
}



contract TimelockTwoStepOwnableTestContract is TwoStepOwnable, Timelocker {
  
  event Test(address addressTest);

  
  constructor() public {
    
    _setInitialTimelockInterval(this.test.selector, 5); 

    
    _setInitialTimelockExpiration(this.test.selector, 30 minutes);
  }

  
  function initiateTest(
    address addressTest, uint256 extraTime
  ) external onlyOwner {
    require(addressTest != address(0), "No test address provided.");

    
    _setTimelock(this.test.selector, abi.encode(addressTest), extraTime);
  }

  
  function test(address addressTest) external onlyOwner {
    require(addressTest != address(0), "No test address provided.");

    
    _enforceTimelock(abi.encode(addressTest));

    
    emit Test(addressTest);
  }
}