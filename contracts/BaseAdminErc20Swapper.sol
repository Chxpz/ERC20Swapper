// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IWETH9} from "./interfaces/IWETH.sol";

/**
 * @title BaseAdminErc20Swapper
 * @author Rafa Carvalho
 *
 * @notice This contract implements admin functions, custom errors and modifiers to be used by the ERC20Swapper contract.
 *
 */

contract BaseAdminErc20Swapper {
    /////////////////////////////////
    //     Custom Errors           //
    /////////////////////////////////

    error ZeroAddress();
    error NotOwner();
    error MinAmountZero();

    /////////////////////////////////
    //     State Variables         //
    /////////////////////////////////

    IWETH9 internal s_weth;

    address internal s_owner;

    address internal s_exchangeLogicLib;

    /////////////////////////////////
    //         Modifiers           //
    /////////////////////////////////

    modifier onlyOwner() {
        if (msg.sender != s_owner) {
            revert NotOwner();
        }
        _;
    }

    modifier nonZeroAddress(address addr) {
        if (addr == address(0)) {
            revert ZeroAddress();
        }
        _;
    }

    /////////////////////////////////
    //          Funtions           //
    /////////////////////////////////

    constructor(address owner, address wethAddress, address exchangeLib) {
        if (
            owner == address(0) ||
            wethAddress == address(0) ||
            exchangeLib == address(0)
        ) {
            revert ZeroAddress();
        }
        s_owner = owner;
        s_weth = IWETH9(payable(wethAddress));
        s_exchangeLogicLib = exchangeLib;
    }

    /////////////////////////////////
    //      External Functions     //
    /////////////////////////////////

    /**
     * @notice Transfer the ownership of the contract to a new address
     * @param newOwner The address of the new owner
     */

    function transferOwnership(
        address newOwner
    ) external onlyOwner nonZeroAddress(newOwner) {
        s_owner = newOwner;
    }

    /**
     * @notice Set the address of the exchangeLogicLib
     * @param newExchangeLogicLib The address of the new exchangeLogicLib
     */

    function setExchangeLogicLib(
        address newExchangeLogicLib
    ) external onlyOwner nonZeroAddress(newExchangeLogicLib) {
        s_exchangeLogicLib = newExchangeLogicLib;
    }

    /**
     * @notice Set the address of the WETH contract
     * @param newWethAddress The address of the new WETH contract
     */

    function setWethAddress(
        address newWethAddress
    ) external onlyOwner nonZeroAddress(newWethAddress) {
        s_weth = IWETH9(payable(newWethAddress));
    }

    /////////////////////////////////
    //        View Functions       //
    /////////////////////////////////

    /**
     * @notice Get the address of the WETH contract
     * @return The address of the WETH contract
     */

    function getWethAddress() external view returns (address) {
        return address(s_weth);
    }

    /**
     * @notice Get the address of the owner
     * @return The address of the owner
     */

    function getOwner() external view returns (address) {
        return s_owner;
    }

    /**
     * @notice Get the address of the exchangeLogicLib
     * @return The address of the exchangeLogicLib
     */

    function getExchangeLogicLib() external view returns (address) {
        return s_exchangeLogicLib;
    }
}
