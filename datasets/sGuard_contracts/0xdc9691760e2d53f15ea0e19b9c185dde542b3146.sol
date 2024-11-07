pragma solidity 0.6.1;


contract Ownable {
    address private _owner;
    address public pendingOwner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    
    
  modifier onlyPendingOwner() {
    assert(msg.sender != address(0));
    require(msg.sender == pendingOwner);
    _;
  }

    
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    
  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0));
    pendingOwner = _newOwner;
  }
  
  
  function claimOwnership() onlyPendingOwner public {
    _transferOwnership(pendingOwner);
    pendingOwner = address(0);
  }

    
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface token {
    function transfer(address, uint) external returns (bool);
}

contract LockTokens is Ownable {
    
    address public constant beneficiaryAddr = 0x5bFF995C6cf0f83C7cefCdF0B13217965b2d93F6;

    uint public constant unlockTime = 1588723200;

    function canTransfer() public view returns (bool) {
        return now > unlockTime;
    }
    
    function claimTokens(address _tokenAddr, uint _amount) public onlyOwner {
        require(canTransfer());
        token(_tokenAddr).transfer(beneficiaryAddr, _amount);
    }
}