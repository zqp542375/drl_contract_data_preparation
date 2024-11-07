pragma solidity ^0.5.0;


contract IAKAP {
    enum ClaimCase {RECLAIM, NEW, TRANSFER}
    enum NodeAttribute {EXPIRY, SEE_ALSO, SEE_ADDRESS, NODE_BODY, TOKEN_URI}

    event Claim(address indexed sender, uint indexed nodeId, uint indexed parentId, bytes label, ClaimCase claimCase);
    event AttributeChanged(address indexed sender, uint indexed nodeId, NodeAttribute attribute);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function hashOf(uint parentId, bytes memory label) public pure returns (uint id);

    
    function claim(uint parentId, bytes calldata label) external returns (uint status);

    
    function exists(uint nodeId) external view returns (bool);

    
    function isApprovedOrOwner(uint nodeId) external view returns (bool);

    
    function ownerOf(uint256 tokenId) public view returns (address);

    
    function parentOf(uint nodeId) external view returns (uint);

    
    function expiryOf(uint nodeId) external view returns (uint);

    
    function seeAlso(uint nodeId) external view returns (uint);

    
    function seeAddress(uint nodeId) external view returns (address);

    
    function nodeBody(uint nodeId) external view returns (bytes memory);

    
    function tokenURI(uint256 tokenId) external view returns (string memory);

    
    function expireNode(uint nodeId) external;

    
    function setSeeAlso(uint nodeId, uint value) external;

    
    function setSeeAddress(uint nodeId, address value) external;

    
    function setNodeBody(uint nodeId, bytes calldata value) external;

    
    function setTokenURI(uint nodeId, string calldata uri) external;

    
    function approve(address to, uint256 tokenId) public;

    
    function getApproved(uint256 tokenId) public view returns (address);

    
    function setApprovalForAll(address to, bool approved) public;

    
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    
    function transferFrom(address from, address to, uint256 tokenId) public;

    
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public;
}



pragma solidity ^0.5.0;


interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}



pragma solidity ^0.5.0;



contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) public view returns (uint256 balance);

    
    function ownerOf(uint256 tokenId) public view returns (address owner);

    
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}



pragma solidity ^0.5.0;


contract IERC721Receiver {
    
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}



pragma solidity ^0.5.0;


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



pragma solidity ^0.5.0;


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}



pragma solidity ^0.5.0;



library Counters {
    using SafeMath for uint256;

    struct Counter {
        
        
        
        uint256 _value; 
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}



pragma solidity ^0.5.0;



contract ERC165 is IERC165 {
    
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        
        
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}



pragma solidity ^0.5.0;








contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    
    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    
    mapping (uint256 => address) private _tokenOwner;

    
    mapping (uint256 => address) private _tokenApprovals;

    
    mapping (address => Counters.Counter) private _ownedTokensCount;

    
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    
    function transferFrom(address from, address to, uint256 tokenId) public {
        
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}



pragma solidity ^0.5.0;



contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}



pragma solidity ^0.5.0;





contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {
    
    mapping(address => uint256[]) private _ownedTokens;

    
    mapping(uint256 => uint256) private _ownedTokensIndex;

    
    uint256[] private _allTokens;

    
    mapping(uint256 => uint256) private _allTokensIndex;

    
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    
    constructor () public {
        
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    
    function _mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

    
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        
        

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; 
            _ownedTokensIndex[lastTokenId] = tokenIndex; 
        }

        
        _ownedTokens[from].length--;

        
        
    }

    
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        
        

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        
        
        
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; 
        _allTokensIndex[lastTokenId] = tokenIndex; 

        
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}



pragma solidity ^0.5.0;



contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}



pragma solidity ^0.5.0;




contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
    
    string private _name;

    
    string private _symbol;

    
    mapping(uint256 => string) private _tokenURIs;

    
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    
    function name() external view returns (string memory) {
        return _name;
    }

    
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}



pragma solidity ^0.5.0;





contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        
    }
}


















pragma solidity ^0.5.0;



contract AKAP is IAKAP, ERC721Full {
    struct Node {
        uint parentId;
        uint expiry;
        uint seeAlso;
        address seeAddress;
        bytes nodeBody;
    }

    mapping(uint => Node) private nodes;

    constructor() ERC721Full("AKA Protocol Registry", "AKAP") public {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    modifier onlyExisting(uint nodeId) {
        require(_exists(nodeId), "AKAP: operator query for nonexistent node");

        _;
    }

    modifier onlyApproved(uint nodeId) {
        require(_exists(nodeId) && _isApprovedOrOwner(_msgSender(), nodeId), "AKAP: set value caller is not owner nor approved");

        _;
    }

    function hashOf(uint parentId, bytes memory label) public pure returns (uint id) {
        require(label.length >= 1 && label.length <= 32, "AKAP: Invalid label length");

        bytes32 labelHash = keccak256(label);
        bytes32 nodeId = keccak256(abi.encode(parentId, labelHash));

        require(nodeId > 0, "AKAP: Invalid node hash");

        return uint(nodeId);
    }

    function claim(uint parentId, bytes calldata label) external returns (uint status) {
        

        
        

        
        
        

        
        
        

        
        uint nodeId = hashOf(parentId, label);

        bool isParentOwner = parentId == 0x0 || _isApprovedOrOwner(_msgSender(), parentId);
        bool nodeExists = _exists(nodeId);

        if (nodeExists && _isApprovedOrOwner(_msgSender(), nodeId)) {
            require(parentId == nodes[nodeId].parentId, "AKAP: Invalid parent hash");

            
            nodes[nodeId].expiry = now + 52 weeks;
            emit Claim(_msgSender(), nodeId, parentId, label, ClaimCase.RECLAIM);

            return 1;
        } else if (!nodeExists && isParentOwner) {
            
            _mint(_msgSender(), nodeId);
            nodes[nodeId].parentId = parentId;
            nodes[nodeId].expiry = now + 52 weeks;
            emit Claim(_msgSender(), nodeId, parentId, label, ClaimCase.NEW);

            return 2;
        } else if (nodeExists && nodes[nodeId].expiry <= now && isParentOwner) {
            require(parentId == nodes[nodeId].parentId, "AKAP: Invalid parent hash");

            
            _transferFrom(ownerOf(nodeId), _msgSender(), nodeId);
            nodes[nodeId].expiry = now + 52 weeks;
            emit Claim(_msgSender(), nodeId, parentId, label, ClaimCase.TRANSFER);

            return 3;
        }

        
        return 0;
    }

    function exists(uint nodeId) external view returns (bool) {
        return _exists(nodeId);
    }

    function isApprovedOrOwner(uint nodeId) external view returns (bool) {
        return _isApprovedOrOwner(_msgSender(), nodeId);
    }

    function parentOf(uint nodeId) external view onlyExisting(nodeId) returns (uint) {
        return nodes[nodeId].parentId;
    }

    function expiryOf(uint nodeId) external view onlyExisting(nodeId) returns (uint) {
        return nodes[nodeId].expiry;
    }

    function seeAlso(uint nodeId) external view onlyExisting(nodeId) returns (uint) {
        return nodes[nodeId].seeAlso;
    }

    function seeAddress(uint nodeId) external view onlyExisting(nodeId) returns (address) {
        return nodes[nodeId].seeAddress;
    }

    function nodeBody(uint nodeId) external view onlyExisting(nodeId) returns (bytes memory) {
        return nodes[nodeId].nodeBody;
    }

    function expireNode(uint nodeId) external onlyApproved(nodeId) {
        nodes[nodeId].expiry = now;
        emit AttributeChanged(_msgSender(), nodeId, NodeAttribute.EXPIRY);
    }

    function setSeeAlso(uint nodeId, uint value) external onlyApproved(nodeId) {
        nodes[nodeId].seeAlso = value;
        emit AttributeChanged(_msgSender(), nodeId, NodeAttribute.SEE_ALSO);
    }

    function setSeeAddress(uint nodeId, address value) external onlyApproved(nodeId) {
        nodes[nodeId].seeAddress = value;
        emit AttributeChanged(_msgSender(), nodeId, NodeAttribute.SEE_ADDRESS);
    }

    function setNodeBody(uint nodeId, bytes calldata value) external onlyApproved(nodeId) {
        nodes[nodeId].nodeBody = value;
        emit AttributeChanged(_msgSender(), nodeId, NodeAttribute.NODE_BODY);
    }

    function setTokenURI(uint nodeId, string calldata uri) external onlyApproved(nodeId) {
        _setTokenURI(nodeId, uri);
        emit AttributeChanged(_msgSender(), nodeId, NodeAttribute.TOKEN_URI);
    }
}