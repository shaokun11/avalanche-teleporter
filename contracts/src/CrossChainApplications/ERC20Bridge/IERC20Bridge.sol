// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: BSD-3-Clause

pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev Interface that describes functionalities for a cross-chain ERC20 bridge.
 */
interface IERC20Bridge {
    /**
     * @dev Enum representing the action to take on receiving a Teleporter message.
     */
    enum BridgeAction {
        Create,
        Mint,
        Transfer
    }

    /**
     * @dev Emitted when tokens are locked in this bridge contract to be bridged to another chain.
     */
    event BridgeTokens(
        address indexed tokenContractAddress,
        bytes32 indexed destinationChainID,
        uint256 indexed teleporterMessageID,
        address destinationBridgeAddress,
        address recipient,
        uint256 amount
    );

    /**
     * @dev Emitted when submitting a request to create a new bridge token on another chain.
     */
    event SubmitCreateBridgeToken(
        bytes32 indexed destinationChainID,
        address indexed destinationBridgeAddress,
        address indexed nativeContractAddress,
        uint256 teleporterMessageID
    );

    /**
     * @dev Emitted when creating a new bridge token.
     */
    event CreateBridgeToken(
        bytes32 indexed nativeChainID,
        address indexed nativeBridgeAddress,
        address indexed nativeContractAddress,
        address bridgeTokenAddress
    );

    /**
     * @dev Emitted when minting bridge tokens.
     */
    event MintBridgeTokens(
        address indexed contractAddress,
        address recipient,
        uint256 amount
    );

    /**
     * @dev Transfers ERC20 tokens to another chain.
     *
     * This can be wrapping, unwrapping, and transferring a wrapped token between two non-native chains.
     */
    function bridgeTokens(
        bytes32 destinationChainID,
        address destinationBridgeAddress,
        address tokenContractAddress,
        address recipient,
        uint256 totalAmount,
        uint256 primaryFeeAmount,
        uint256 secondaryFeeAmount
    ) external;

    /**
     * @dev Creates a new bridge token on another chain.
     */
    function submitCreateBridgeToken(
        bytes32 destinationChainID,
        address destinationBridgeAddress,
        ERC20 nativeToken,
        address messageFeeAsset,
        uint256 messageFeeAmount
    ) external;
}