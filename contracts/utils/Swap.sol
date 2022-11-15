// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.17;
pragma abicoder v2;
//swap router: 0xE592427A0AEce92De3Edee1F18E0157C05861564
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

contract Swap {

    ISwapRouter public immutable swapRouter;
    address public constant DAI = 0xCC70f801C1C73D9e699E874A434aab8E499005b7;    
    address public constant WETH9 = 0xCC70f801C1C73D9e699E874A434aab8E499005b7;    
    uint24 public constant poolFee = 500;

    constructor(address _swapRouter) {
        swapRouter = ISwapRouter(_swapRouter);
    }

    function swapExactInputSingle(uint256 amountIn, address to, address tokenIn,address tokenOut) internal returns (uint256 amountOut) {
        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: to,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }
    function swapExactInputSingleMatic(uint256 amountIn, address to, address tokenIn,address tokenOut) internal returns (uint256 amountOut) {
        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: 10000,
                recipient: to,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }
    
}