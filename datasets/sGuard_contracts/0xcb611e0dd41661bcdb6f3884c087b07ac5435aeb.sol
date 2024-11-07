pragma solidity >=0.4.26;

contract UniswapExchangeInterface {
    
    function tokenAddress() external view returns (address token);
    
    function factoryAddress() external view returns (address factory);
    
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    
    function setup(address token_addr) external;
}

interface ERC20 {
    function totalSupply() view external returns (uint supply);
    function balanceOf(address _owner)  view external returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender)  view external returns (uint remaining);
    function decimals()  view external returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}






interface KyberNetworkProxyInterface {
    function maxGasPrice() external view returns(uint);
    function getUserCapInWei(address user) external view returns(uint);
    function getUserCapInTokenWei(address user, ERC20 token) external view returns(uint);
    function enabled() external view returns(bool);
    function info(bytes32 id) external view returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes hint) external payable returns(uint);

    function swapEtherToToken(ERC20 token, uint minRate) external payable returns (uint);

    function swapTokenToEther(ERC20 token, uint tokenQty, uint minRate) external returns (uint);


}

interface OrFeedInterface {
  function getExchangeRate ( string fromSymbol, string toSymbol, string venue, uint256 amount ) external view returns ( uint256 );
  function getTokenDecimalCount ( address tokenAddress ) external view returns ( uint256 );
  function getTokenAddress ( string symbol ) external view returns ( address );
  function getSynthBytes32 ( string symbol ) external view returns ( bytes32 );
  function getForexAddress ( string symbol ) external view returns ( address );
}





contract GetPrices{

    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    OrFeedInterface orfeed= OrFeedInterface(0x8316B082621CFedAB95bf4a44a1d4B64a6ffc336);
    address daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address owner;



    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }


    constructor(){
     owner = msg.sender;
    }

    function withdrawETHAndTokens() public onlyOwner{

        msg.sender.transfer(address(this).balance);
         ERC20 daiToken = ERC20(daiAddress);
        uint256 currentTokenBalance = daiToken.balanceOf(this);
        daiToken.transfer(msg.sender, currentTokenBalance);

    }



    function getUSDCKyberBuyPrice() constant external returns (uint256){
       uint256 currentPriceKyber =  orfeed.getExchangeRate("WETH", "USDC", "KYBERBYSYMBOLV1", 1000000000000000000);
        return currentPriceKyber;
    }
    
     function getUSDCUniswapSellPrice() constant external returns (uint256){
       uint256 currentPriceUniswap =  orfeed.getExchangeRate("WETH", "USDC", "BUY-UNISWAP-EXCHANGE", 1000000000000000000);
        return currentPriceUniswap;
    }
    
    
    
    
    function getWBTCKyberBuyPrice() constant external returns (uint256){
       uint256 currentPriceKyber =  orfeed.getExchangeRate("WETH", "WBTC", "KYBERBYSYMBOLV1", 1000000000000000000);
        return currentPriceKyber;
    }
    
    function getWBTCUniswapSellPrice() constant external returns (uint256){
       uint256 currentPriceUniswap =  orfeed.getExchangeRate("WETH", "WBTC", "BUY-UNISWAP-EXCHANGE", 1000000000000000000);
        return currentPriceUniswap;
    }



    function getPAXKyberBuyPrice() constant external returns (uint256){
       uint256 currentPriceKyber =  orfeed.getExchangeRate("WETH", "PAX", "KYBERBYSYMBOLV1", 1000000000000000000);
        return currentPriceKyber;
    }
    
    function getPAXUniswapSellPrice() constant external returns (uint256){
       uint256 currentPriceUniswap =  orfeed.getExchangeRate("WETH", "PAX", "BUY-UNISWAP-EXCHANGE", 1000000000000000000);
        return currentPriceUniswap;
    }


    function getLINKKyberBuyPrice() constant external returns (uint256){
       uint256 currentPriceKyber =  orfeed.getExchangeRate("WETH", "LINK", "KYBERBYSYMBOLV1", 1000000000000000000);
        return currentPriceKyber;
    }
    
    function getLINKUniswapSellPrice() constant external returns (uint256){
       uint256 currentPriceUniswap =  orfeed.getExchangeRate("WETH", "LINK", "BUY-UNISWAP-EXCHANGE", 1000000000000000000);
        return currentPriceUniswap;
    }
    
    
    function getBATKyberBuyPrice() constant external returns (uint256){
       uint256 currentPriceKyber =  orfeed.getExchangeRate("WETH", "BAT", "KYBERBYSYMBOLV1", 1000000000000000000);
        return currentPriceKyber;
    }
    
    function getBATUniswapSellPrice() constant external returns (uint256){
       uint256 currentPriceUniswap =  orfeed.getExchangeRate("WETH", "BAT", "BUY-UNISWAP-EXCHANGE", 1000000000000000000);
        return currentPriceUniswap;
    }



}