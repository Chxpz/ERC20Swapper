// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

/**
 * @title UniSwapMarket
 * @author Rafa Carvalho
 * @notice This library is a wrapper to interact with the Uniswap V3 Router contract.
 * It allows swapping Ether to ERC20 tokens.
 * @notice For sake of simplicity, the fee, the swapRouter address and the sqrtPriceLimitX96 are hardcoded as constants.
 */

library UniswapMarket {
    address public constant swapRouter =
        0xE592427A0AEce92De3Edee1F18E0157C05861564;
    uint24 public constant FEE = 3000;
    uint160 public constant SQRT_PRICE_LIMIT = 0;

    /**
    @notice This struct is used to pass the parameters to the swapRouter contract.
    It is defined as per the Uniswap V3 Router contract.
    */

    struct SwapParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadLine;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /**
    @notice This function swaps Ether to a token using the Uniswap V3 Router contract.
    It uses the exactInputSingle function from the swapRouter contract.
    @param weth The address of the WETH contract
    @param token The address of the token the caller wants to swap Ether for
    @param minAmount The minimum amount of token the caller wants to receive
    @param msgValue The amount of Ether the caller wants to swap
    @return success A boolean indicating if the swap was successful
    @return returnData The return data from the swapRouter contract
    */

    function swapEtherToToken(
        address weth,
        address token,
        uint256 minAmount,
        uint256 msgValue
    ) external returns (bool success, bytes memory returnData) {
        TransferHelper.safeApprove(weth, swapRouter, msgValue);

        (success, returnData) = _swapToken(weth, token, minAmount, msgValue);
    }

    function _swapToken(
        address weth,
        address token,
        uint256 minAmount,
        uint256 msgValue
    ) internal returns (bool success, bytes memory returnData) {
        SwapParams memory swapParams = SwapParams({
            tokenIn: weth,
            tokenOut: token,
            fee: FEE,
            recipient: msg.sender,
            deadLine: block.timestamp,
            amountIn: msgValue,
            amountOutMinimum: minAmount,
            sqrtPriceLimitX96: SQRT_PRICE_LIMIT
        });

        bytes memory data = abi.encodeWithSelector(
            ISwapRouter.exactInputSingle.selector,
            swapParams
        );

        (success, returnData) = swapRouter.call(data);
        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }
}
