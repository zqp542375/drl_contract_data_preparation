pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external view returns (uint);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface yVault {
    function balance() external view returns (uint);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function depositAll() external;
    function withdraw(uint _shares) external;
    function withdrawAll() external;
}

interface Controller {
    function vaults(address) external view returns (address);
    function strategies(address) external view returns (address);
    function rewards() external view returns (address);
}

interface Strategy {
    function withdrawalFee() external view returns (uint);
}



interface GemLike {
    function approve(address, uint) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
}

interface ManagerLike {
    function cdpCan(address, uint, address) external view returns (uint);
    function ilks(uint) external view returns (bytes32);
    function owns(uint) external view returns (address);
    function urns(uint) external view returns (address);
    function vat() external view returns (address);
    function open(bytes32, address) external returns (uint);
    function give(uint, address) external;
    function cdpAllow(uint, address, uint) external;
    function urnAllow(address, uint) external;
    function frob(uint, int, int) external;
    function flux(uint, address, uint) external;
    function move(uint, address, uint) external;
    function exit(address, uint, address, uint) external;
    function quit(uint, address) external;
    function enter(address, uint) external;
    function shift(uint, uint) external;
}

interface VatLike {
    function can(address, address) external view returns (uint);
    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);
    function dai(address) external view returns (uint);
    function urns(bytes32, address) external view returns (uint, uint);
    function frob(bytes32, address, address, address, int, int) external;
    function hope(address) external;
    function move(address, address, uint) external;
}

interface GemJoinLike {
    function dec() external returns (uint);
    function gem() external returns (GemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface GNTJoinLike {
    function bags(address) external view returns (address);
    function make(address) external returns (address);
}

interface DaiJoinLike {
    function vat() external returns (VatLike);
    function dai() external returns (GemLike);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface HopeLike {
    function hope(address) external;
    function nope(address) external;
}

interface EndLike {
    function fix(bytes32) external view returns (uint);
    function cash(bytes32, uint) external;
    function free(bytes32) external;
    function pack(uint) external;
    function skim(bytes32, address) external;
}

interface JugLike {
    function drip(bytes32) external returns (uint);
}

interface PotLike {
    function pie(address) external view returns (uint);
    function drip() external returns (uint);
    function join(uint) external;
    function exit(uint) external;
}

interface SpotLike {
    function ilks(bytes32) external view returns (address, uint);
}

interface Medianizer {
    function read() external view returns (bytes32);
}

interface Uni {
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external;
}

contract Structs {
    struct Val {
        uint256 value;
    }

    enum ActionType {
        Deposit,   
        Withdraw,  
        Transfer,  
        Buy,       
        Sell,      
        Trade,     
        Liquidate, 
        Vaporize,  
        Call       
    }

    enum AssetDenomination {
        Wei 
    }

    enum AssetReference {
        Delta 
    }

    struct AssetAmount {
        bool sign; 
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct Info {
        address owner;  
        uint256 number; 
    }

    struct Wei {
        bool sign; 
        uint256 value;
    }
}

contract DyDx is Structs {
    function operate(Info[] memory, ActionArgs[] memory) public;
}



contract StrategyMKRVaultDAIDelegate is Structs {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address constant public token = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant public want = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    address public cdp_manager = address(0x5ef30b9986345249bc32d8928B7ee64DE9435E39);
    address public vat = address(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);
    address public mcd_join_eth_a = address(0x2F0b23f53734252Bda2277357e97e1517d6B042A);
    address public mcd_join_dai = address(0x9759A6Ac90977b93B58547b4A71c78317f391A28);
    address public mcd_spot = address(0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3);
    address public jug = address(0x19c0976f590D67707E62397C87829d896Dc0f1F1);

    address constant public eth_price_oracle = address(0x729D19f657BD0614b4985Cf1D82531c67569197B);
    address constant public yVaultDAI = address(0xACd43E627e64355f1861cEC6d3a6688B31a6F952);

    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public dydx = address(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);

    uint public c = 20000;
    uint public c_safe = 40000;
    uint constant public c_base = 10000;

    uint public performanceFee = 5000;
    uint constant public performanceMax = 10000;

    uint public withdrawalFee = 50;
    uint constant public withdrawalMax = 10000;

    bytes32 constant public ilk = "ETH-A";

    address public governance;
    address public controller;
    address public strategist;
    address public harvester;

    uint public cdpId;

    constructor(address _controller, address _governance) public {
        governance = _governance;
        strategist = msg.sender;
        controller = _controller;
        cdpId = ManagerLike(cdp_manager).open(ilk, address(this));
        _approveAll();
    }

    function getName() external pure returns (string memory) {
        return "StrategyMKRVaultDAIDelegate";
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setHarvester(address _harvester) external {
        require(msg.sender == harvester || msg.sender == governance, "!allowed");
        harvester = _harvester;
    }

    function setWithdrawalFee(uint _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        withdrawalFee = _withdrawalFee;
    }

    function setPerformanceFee(uint _performanceFee) external {
        require(msg.sender == governance, "!governance");
        performanceFee = _performanceFee;
    }

    function setBorrowCollateralizationRatio(uint _c) external {
        require(msg.sender == governance, "!governance");
        c = _c;
    }

    function setWithdrawCollateralizationRatio(uint _c_safe) external {
        require(msg.sender == governance, "!governance");
        c_safe = _c_safe;
    }

    
    function setMCDValue(
        address _manager,
        address _ethAdapter,
        address _daiAdapter,
        address _spot,
        address _jug
    ) external {
        require(msg.sender == governance, "!governance");
        cdp_manager = _manager;
        vat = ManagerLike(_manager).vat();
        mcd_join_eth_a = _ethAdapter;
        mcd_join_dai = _daiAdapter;
        mcd_spot = _spot;
        jug = _jug;
    }

    function _approveAll() internal {
        IERC20(token).approve(mcd_join_eth_a, uint(-1));
        IERC20(dai).approve(mcd_join_dai, uint(-1));
        IERC20(dai).approve(yVaultDAI, uint(-1));
        IERC20(dai).approve(unirouter, uint(-1));
        IERC20(dai).approve(dydx, uint(-1));
    }

    function deposit() public {
        uint _token = IERC20(token).balanceOf(address(this));
        if (_token > 0) {
            uint p = uint(Medianizer(eth_price_oracle).read());
            uint _draw = _token.mul(p).mul(c_base).div(c).div(1e18);
            
            _lockWETHAndDrawDAI(_token, _draw);

            
            yVault(yVaultDAI).depositAll();
        }
    }

    function _lockWETHAndDrawDAI(uint wad, uint wadD) internal {
        address urn = ManagerLike(cdp_manager).urns(cdpId);

        
        GemJoinLike(mcd_join_eth_a).join(urn, wad);
        ManagerLike(cdp_manager).frob(cdpId, toInt(wad), _getDrawDart(urn, wadD));
        ManagerLike(cdp_manager).move(cdpId, address(this), wadD.mul(1e27));
        if (VatLike(vat).can(address(this), address(mcd_join_dai)) == 0) {
            VatLike(vat).hope(mcd_join_dai);
        }
        DaiJoinLike(mcd_join_dai).exit(address(this), wadD);
    }

    function _getDrawDart(address urn, uint wad) internal returns (int dart) {
        uint rate = JugLike(jug).drip(ilk);
        uint _dai = VatLike(vat).dai(urn);

        
        if (_dai < wad.mul(1e27)) {
            dart = toInt(wad.mul(1e27).sub(_dai).div(rate));
            dart = uint(dart).mul(rate) < wad.mul(1e27) ? dart + 1 : dart;
        }
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        require(dai != address(_asset), "dai");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        uint _fee = _amount.mul(withdrawalFee).div(withdrawalMax);

        IERC20(want).safeTransfer(strategist, _fee);
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); 

        IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
    }

    function _withdrawSome(uint256 _amount) internal returns (uint) {
        
        _freeWETH(_amount);

        if (getmVaultRatio() < c_safe.mul(1e2)) {
            uint p = uint(Medianizer(eth_price_oracle).read());
            _wipe(_withdrawDai(_amount.mul(p).div(1e18)));
        }
        
        return _amount;
    }

    function _freeWETH(uint wad) internal {
        ManagerLike(cdp_manager).frob(cdpId, -toInt(wad), 0);
        ManagerLike(cdp_manager).flux(cdpId, address(this), wad);
        GemJoinLike(mcd_join_eth_a).exit(address(this), wad);
    }

    function _wipe(uint wad) internal {
        
        address urn = ManagerLike(cdp_manager).urns(cdpId);

        DaiJoinLike(mcd_join_dai).join(urn, wad);
        ManagerLike(cdp_manager).frob(cdpId, 0, _getWipeDart(VatLike(vat).dai(urn), urn));
    }

    function _getWipeDart(
        uint _dai,
        address urn
    ) internal view returns (int dart) {
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        (, uint art) = VatLike(vat).urns(ilk, urn);

        dart = toInt(_dai / rate);
        dart = uint(dart) <= art ? - dart : - toInt(art);
    }

    
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();

        _swap(IERC20(dai).balanceOf(address(this)));
        balance = IERC20(want).balanceOf(address(this));

        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); 
        IERC20(want).safeTransfer(_vault, balance);
    }

    function _withdrawAll() internal {
        yVault(yVaultDAI).withdrawAll(); 
        _wipe(getTotalDebtAmount().add(1));
        _freeWETH(balanceOfmVault());
    }

    function balanceOf() public view returns (uint) {
        return balanceOfWant()
               .add(balanceOfmVault());
    }

    function balanceOfWant() public view returns (uint) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfmVault() public view returns (uint) {
        uint ink;
        address urnHandler = ManagerLike(cdp_manager).urns(cdpId);
        (ink,) = VatLike(vat).urns(ilk, urnHandler);
        return ink;
    }

    function harvest() public {
        require(msg.sender == strategist || msg.sender == harvester || msg.sender == governance, "!authorized");
        
        uint v = getUnderlyingDai(yVault(yVaultDAI).balanceOf(address(this)));
        uint d = getTotalDebtAmount();
        require(v > d, "profit is not realized yet!");
        uint profit = v.sub(d);

        initFlashLoan(dai, 3, profit);
    }

    function initFlashLoan(
        address _token,
        uint256 _marketId,
        uint256 _amount
    ) internal {
        uint256 _flash_amount = IERC20(_token).balanceOf(dydx);
        require(_amount <= _flash_amount, "flash amount is not enough");

        Info[] memory infos = new Info[](1);
        infos[0] = Info(address(this), 0);

        ActionArgs[] memory args = new ActionArgs[](3);

        ActionArgs memory _wtoken;

        _wtoken.actionType = ActionType.Withdraw;
        _wtoken.accountId = 0;
        _wtoken.amount = AssetAmount(
            false,
            AssetDenomination.Wei,
            AssetReference.Delta,
            _amount
        );
        _wtoken.primaryMarketId = _marketId;
        _wtoken.secondaryMarketId = 0;
        _wtoken.otherAddress = address(this);

        args[0] = _wtoken;

        ActionArgs memory call;

        call.actionType = ActionType.Call;
        call.accountId = 0;
        call.otherAddress = address(this);

        args[1] = call;

        ActionArgs memory _dtoken;

        _dtoken.actionType = ActionType.Deposit;
        _dtoken.accountId = 0;
        _dtoken.amount = AssetAmount(
            true,
            AssetDenomination.Wei,
            AssetReference.Delta,
            _amount.add(1)
        );
        _dtoken.primaryMarketId = _marketId;
        _dtoken.secondaryMarketId = 0;
        _dtoken.otherAddress = address(this);

        args[2] = _dtoken;

        DyDx(dydx).operate(infos, args);
    }

    function callFunction(
        address sender,
        Info memory accountInfo,
        bytes memory data
    ) public {
        require(sender == dydx, "need to be dydx!");
        uint _borrow = IERC20(dai).balanceOf(address(this));
        _swap(_borrow.sub(1));

        uint _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            uint _fee = _want.mul(performanceFee).div(performanceMax);
            IERC20(want).safeTransfer(strategist, _fee);
            _want = _want.sub(_fee);
        }

        uint p = uint(Medianizer(eth_price_oracle).read());
        uint _draw = _want.mul(p).mul(c_base).div(c).div(1e18);
        
        _lockWETHAndDrawDAI(_want, _draw);
        _withdrawDai(_borrow.sub(_draw));
    }

    function payback(uint _amount) public {
        
        _wipe(_withdrawDai(_amount));
    }

    function getTotalDebtAmount() public view returns (uint) {
        uint art;
        uint rate;
        address urnHandler = ManagerLike(cdp_manager).urns(cdpId);
        (,art) = VatLike(vat).urns(ilk, urnHandler);
        (,rate,,,) = VatLike(vat).ilks(ilk);
        return art.mul(rate).div(1e27);
    }

    function getmVaultRatio() public view returns (uint) {
        uint spot; 
        uint liquidationRatio; 
        uint denominator = getTotalDebtAmount();
        (,,spot,,) = VatLike(vat).ilks(ilk);
        (,liquidationRatio) = SpotLike(mcd_spot).ilks(ilk);
        uint delayedCPrice = spot.mul(liquidationRatio).div(1e27); 
        uint numerator = balanceOfmVault().mul(delayedCPrice).div(1e18); 
        return numerator.div(denominator).div(1e3);
    }

    function getUnderlyingWithdrawalFee() public view returns (uint) {
        address _strategy = Controller(controller).strategies(dai);
        return Strategy(_strategy).withdrawalFee();
    }

    function getUnderlyingDai(uint _shares) public view returns (uint) {
        return (yVault(yVaultDAI).balance())
                .mul(_shares).div(yVault(yVaultDAI).totalSupply())
                .mul(withdrawalMax.sub(getUnderlyingWithdrawalFee()))
                .div(withdrawalMax);
    }

    function _withdrawDai(uint _amount) internal returns (uint) {
        uint _shares = _amount
                        .mul(yVault(yVaultDAI).totalSupply())
                        .div(yVault(yVaultDAI).balance())
                        .mul(withdrawalMax)
                        .div(withdrawalMax.sub(getUnderlyingWithdrawalFee()));
        yVault(yVaultDAI).withdraw(_shares);
        return IERC20(dai).balanceOf(address(this));
    }

    function _swap(uint _amountIn) internal {
        address[] memory path = new address[](2);
        path[0] = address(dai);
        path[1] = address(want);

        
        Uni(unirouter).swapExactTokensForTokens(_amountIn, 0, path, address(this), now.add(1 days));
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}