// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {BaseAdminErc20Swapper} from "./BaseAdminErc20Swapper.sol";
import {IERC20Swapper} from "./interfaces/IERC20Swapper.sol";

/**
 * @title ERC20Swapper
 * @author RPC
 *
 * This contract is a wrapper to interact with an external DEX contract defined as exchangeLogicLib.
 * It allows swapping Ether to ERC20 tokens.
 * It uses the WETH contract to wrap Ether.
 * It was built to implement the IERC20Swapper interface.
 *
 * @notice This contract is not upgradable, as its logic is in the exchange library to forward the call to the DEX.
 * If any business logic needs to be changed, a new exchangeLogicLib should be deployed and the address updated in this contract.
 * This allows for more secure and transparent code, and reduces the risk of storage collisions when upgrading the contract.
 *
 * @notice All the admin functions, as well as the modifiers and errors, are defined in the BaseAdminErc20Swapper contract.
 *
 * @notice This contract emits no events once it does not have any state update when performing the swap,
 * and there is no reasons to emit events when calling an external contract.
 *
 * @dev This contract does not have a receive or a fallback function implemented, considering the reasons and the spec on which it was built.
 * Do not send Ether directly to this contract; use the swapEtherToToken function.
 *
 */

contract ERC20Swapper is BaseAdminErc20Swapper, ReentrancyGuard, IERC20Swapper {
    /////////////////////////////////
    //          Functions          //
    /////////////////////////////////

    constructor(
        address owner,
        address wethAddress,
        address exchangeLib
    ) BaseAdminErc20Swapper(owner, wethAddress, exchangeLib) {}

    /**
     * @notice follows CEI - Checks-Effects-Interactions pattern
     * @param token The address of the token the caller wants to swap Ether for
     * @param minAmount The minimum amount of token the caller wants to receive
     * @return The amount of token received
     * @dev The delegate call to the exchangeLogicLib is used to forward the call to the DEX.
     * The exchangeLogicLib is set by the admin and should be a trusted contract,
     * by doing so, there is no risk to delegate the call to an unknown malicious contract.
     * @dev Once libraries does not handle Ether, the msg.value is wrapped into WETH and sent to the exchangeLogicLib.
     */

    function swapEtherToToken(
        address token,
        uint256 minAmount
    ) external payable nonReentrant nonZeroAddress(token) returns (uint) {
        if (minAmount == 0) {
            revert MinAmountZero();
        }

        uint256 msgValue = msg.value;

        s_weth.deposit{value: msgValue}();

        bytes memory initData = _getBytesData(
            address(s_weth),
            token,
            minAmount,
            msgValue
        );

        (bool success, bytes memory returnData) = s_exchangeLogicLib
            .delegatecall(initData);

        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        uint amountOut = abi.decode(returnData, (uint256));

        return amountOut;
    }

    ///////////////////////////////////
    //       internal functions      //
    ///////////////////////////////////

    /**
     * @notice Generate the bytes data to be used in the delegatecall to the exchangeLogicLib
     * To define this function as pure, the weth address was passed as a parameter
     * @param wethAddress The address of the WETH contract previously set by the admin
     * @param token The address of the token the caller wants to swap Ether for
     * @param minAmount The minimum amount of token the caller wants to receive
     * @param msgValue The amount of Ether sent by the caller
     * @return The bytes data to be used in the delegatecall
     */

    function _getBytesData(
        address wethAddress,
        address token,
        uint256 minAmount,
        uint256 msgValue
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSignature(
                "swapEtherToToken(address,address,uint256,uint256)",
                wethAddress,
                token,
                minAmount,
                msgValue
            );
    }
}
