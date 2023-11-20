
pragma solidity 0.8.18;



struct WarpMessage {
    bytes32 sourceChainID;
    address originSenderAddress;
    bytes32 destinationChainID;
    address destinationAddress;
    bytes payload;
}

struct WarpBlockHash {
    bytes32 sourceChainID;
    bytes32 blockHash;
}

interface WarpMessenger {
    event SendWarpMessage(
        bytes32 indexed destinationChainID,
        address indexed destinationAddress,
        address indexed sender,
        bytes message
    );

    // sendWarpMessage emits a request for the subnet to send a warp message from [msg.sender]
    // with the specified parameters.
    // This emits a SendWarpMessage log from the precompile. When the corresponding block is accepted
    // the Accept hook of the Warp precompile is invoked with all accepted logs emitted by the Warp
    // precompile.
    // Each validator then adds the UnsignedWarpMessage encoded in the log to the set of messages
    // it is willing to sign for an off-chain relayer to aggregate Warp signatures.
    function sendWarpMessage(
        bytes32 destinationChainID,
        address destinationAddress,
        bytes calldata payload
    ) external;

    // getVerifiedWarpMessage parses the pre-verified warp message in the
    // predicate storage slots as a WarpMessage and returns it to the caller.
    // If the message exists and passes verification, returns the verified message
    // and true.
    // Otherwise, returns false and the empty value for the message.
    function getVerifiedWarpMessage(uint32 index)
        external view
        returns (WarpMessage calldata message, bool valid);

    // getVerifiedWarpBlockHash parses the pre-verified WarpBlockHash message in the
    // predicate storage slots as a WarpBlockHash message and returns it to the caller.
    // If the message exists and passes verification, returns the verified message
    // and true.
    // Otherwise, returns false and the empty value for the message.
    function getVerifiedWarpBlockHash(uint32 index)
        external view
        returns (WarpBlockHash calldata warpBlockHash, bool valid);

    // getBlockchainID returns the snow.Context BlockchainID of this chain.
    // This blockchainID is the hash of the transaction that created this blockchain on the P-Chain
    // and is not related to the Ethereum ChainID.
    function getBlockchainID() external view returns (bytes32 blockchainID);
}

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

/**
 * @dev Registry entry that represents a mapping between protocolAddress and version.
 */
struct ProtocolRegistryEntry {
    uint256 version;
    address protocolAddress;
}

/**
 * @dev Implementation of an abstract `WarpProtocolRegistry` contract.
 *
 * This implementation is a contract that can be used as a base contract for protocols that are
 * built on top of Warp. It allows the protocol to be upgraded through a Warp out-of-band message.
 */
abstract contract WarpProtocolRegistry {
    // Address that the out-of-band Warp message sets as the "source" address.
    // The address is not owned by any EOA or smart contract account, so it
    // cannot possibly be the source address of any other Warp message emitted by the VM.
    address public constant VALIDATORS_SOURCE_ADDRESS = address(0);

    WarpMessenger public constant WARP_MESSENGER =
        WarpMessenger(0x0200000000000000000000000000000000000005);

    bytes32 internal immutable _blockchainID=0x28ffdaca17dc3d5bda04a3abfd165660831eb25d62a182294a3b9e38c47d29bd;

    // The latest protocol version. 0 means no protocol version has been added, and isn't a valid version.
    uint256 internal _latestVersion;

    // Mappings that keep track of the protocol version and corresponding contract address.
    mapping(uint256 => address) internal _versionToAddress;
    mapping(address => uint256) internal _addressToVersion;

    /**
     * @dev Emitted when a new protocol version is added to the registry.
     */
    event AddProtocolVersion(
        uint256 indexed version,
        address indexed protocolAddress
    );

    /**
     * @dev Initializes the contract by setting `_blockchainID` and `_latestVersion`.
     * Also adds the initial protocol versions to the registry.
     */
    constructor(ProtocolRegistryEntry[] memory initialEntries) {
        _latestVersion = 0;

        for (uint256 i = 0; i < initialEntries.length; i++) {
            _addToRegistry(initialEntries[i]);
        }
    }

    /**
     * @dev Gets and verifies a warp out-of-band message, and adds the new protocol version
     * address to the registry.
     * If a version is greater than the current latest version, it will be set as the latest version.
     * If a version is less than the current latest version, it is added to the registry, but
     * doesn't change the latest version.
     *
     * Emits a {AddProtocolVersion} event when successful.
     * Requirements:
     *
     * - a valid Warp out-of-band message must be provided.
     * - source chain ID must be the same as the blockchain ID of the registry.
     * - origin sender address must be the same as the `VALIDATORS_SOURCE_ADDRESS`.
     * - destination chain ID must be the same as the blockchain ID of the registry.
     * - destination address must be the same as the address of the registry.
     * - version must not be zero.
     * - version must not already be registered.
     * - protocol address must not be zero address.
     */
    function addProtocolVersion(uint32 messageIndex) external virtual {
        // Get and validate for a warp out-of-band message.
        (WarpMessage memory message, bool success) = WARP_MESSENGER
            .getVerifiedWarpMessage(messageIndex);
        require(success, "WarpProtocolRegistry: invalid warp message");
        require(
            message.sourceChainID == _blockchainID,
            "WarpProtocolRegistry: invalid source chain ID"
        );
        // Check that the message is sent through a warp out of band message.
        require(
            message.originSenderAddress == VALIDATORS_SOURCE_ADDRESS,
            "WarpProtocolRegistry: invalid origin sender address"
        );
        require(
            message.destinationChainID == _blockchainID,
            "WarpProtocolRegistry: invalid destination chain ID"
        );
        require(
            message.destinationAddress == address(this),
            "WarpProtocolRegistry: invalid destination address"
        );

        ProtocolRegistryEntry memory entry = abi.decode(
            message.payload,
            (ProtocolRegistryEntry)
        );

        _addToRegistry(entry);
    }

    /**
     * @dev Gets the address of a protocol version.
     * Requirements:
     *
     * - the version must be a valid version.
     */
    function getAddressFromVersion(
        uint256 version
    ) external view virtual returns (address) {
        return _getAddressFromVersion(version);
    }

    /**
     * @dev Gets the version of the given `protocolAddress`.
     * If `protocolAddress` is not a registered protocol address, returns 0, which is an invalid version.
     */
    function getVersionFromAddress(
        address protocolAddress
    ) external view virtual returns (uint256) {
        return _addressToVersion[protocolAddress];
    }

    /**
     * @dev Gets the latest protocol version.
     * If the registry has no versions, we return 0, which is an invalid version.
     */
    function getLatestVersion() external view virtual returns (uint256) {
        return _latestVersion;
    }

    /**
     * @dev Adds the new protocol version address to the registry.
     * Updates latest version if the version is greater than the current latest version.
     *
     * Emits a {AddProtocolVersion} event when successful.
     * Note: `protocolAddress` doesn't have to be a contract address, this is primarily
     * to support the case we want to register a new protocol address meant for a security patch
     * before the contract is deployed, to prevent the vulnerabilitiy from being exposed before registry update.
     * Requirements:
     *
     * - `version` is not zero
     * - `version` is not already registered
     * - `protocolAddress` is not zero address
     */
    function _addToRegistry(
        ProtocolRegistryEntry memory entry
    ) internal virtual {
        require(entry.version != 0, "WarpProtocolRegistry: zero version");
        // Check that the version has not previously been registered.
        require(
            _versionToAddress[entry.version] == address(0),
            "WarpProtocolRegistry: version already exists"
        );
        require(
            entry.protocolAddress != address(0),
            "WarpProtocolRegistry: zero protocol address"
        );

        _versionToAddress[entry.version] = entry.protocolAddress;
        _addressToVersion[entry.protocolAddress] = entry.version;
        emit AddProtocolVersion(entry.version, entry.protocolAddress);

        // Set latest version if the version is greater than the current latest version.
        if (entry.version > _latestVersion) {
            _latestVersion = entry.version;
        }
    }

    /**
     * @dev Gets the corresponding address of a protocol version.
     * Requirements:
     *
     * - `version` must be a valid version, i.e. greater than 0 and not greater than the latest version.
     */
    function _getAddressFromVersion(
        uint256 version
    ) internal view virtual returns (address) {
        require(version != 0, "WarpProtocolRegistry: zero version");
        require(
            version <= _latestVersion,
            "WarpProtocolRegistry: invalid version"
        );
        return _versionToAddress[version];
    }
}

// (c) 2023, Ava Labs, Inc. All rights reserved.
// See the file LICENSE for licensing terms.

// SPDX-License-Identifier: Ecosystem

struct TeleporterMessageReceipt {
    uint256 receivedMessageID;
    address relayerRewardAddress;
}

struct TeleporterMessageInput {
    bytes32 destinationChainID;
    address destinationAddress;
    TeleporterFeeInfo feeInfo;
    uint256 requiredGasLimit;
    address[] allowedRelayerAddresses;
    bytes message;
}

struct TeleporterMessage {
    uint256 messageID;
    address senderAddress;
    address destinationAddress;
    uint256 requiredGasLimit;
    address[] allowedRelayerAddresses;
    TeleporterMessageReceipt[] receipts;
    bytes message;
}

struct TeleporterFeeInfo {
    address contractAddress;
    uint256 amount;
}

/**
 * @dev Interface that describes functionalities for a cross-chain messenger implementing the Teleporter protcol.
 */
interface ITeleporterMessenger {
    /**
     * @dev Emitted when sending a Teleporter message cross-chain.
     */
    event SendCrossChainMessage(
        bytes32 indexed destinationChainID,
        uint256 indexed messageID,
        TeleporterMessage message,
        TeleporterFeeInfo feeInfo
    );

    /**
     * @dev Emitted when an additional fee amount is added to a Teleporter message that had previously
     * been sent, but not yet delivered to the destination chain.
     */
    event AddFeeAmount(
        bytes32 indexed destinationChainID,
        uint256 indexed messageID,
        TeleporterFeeInfo updatedFeeInfo
    );

    /**
     * @dev Emitted when a Teleporter message is being delivered on the destination chain to an address,
     * but message execution fails. Failed messages can then be retried with `retryMessageExecution`
     */
    event MessageExecutionFailed(
        bytes32 indexed originChainID,
        uint256 indexed messageID,
        TeleporterMessage message
    );

    /**
     * @dev Emitted when a Teleporter message is successfully executed with the
     * specified destination address and message call data. This can occur either when
     * the message is initially received, or on a retry attempt.
     *
     * Each message received can be executed successfully at most once.
     */
    event MessageExecuted(
        bytes32 indexed originChainID,
        uint256 indexed messageID
    );

    /**
     * @dev Emitted when a TeleporterMessage is successfully received.
     */
    event ReceiveCrossChainMessage(
        bytes32 indexed originChainID,
        uint256 indexed messageID,
        address indexed deliverer,
        address rewardRedeemer,
        TeleporterMessage message
    );

    /**
     * @dev Emitted when an account redeems accumulated relayer rewards.
     */
    event RelayerRewardsRedeemed(
        address indexed redeemer,
        address indexed asset,
        uint256 amount
    );

    /**
     * @dev Called by transactions to initiate the sending of a cross-chain message.
     */
    function sendCrossChainMessage(
        TeleporterMessageInput calldata messageInput
    ) external returns (uint256 messageID);

    /**
     * @dev Called by transactions to retry the sending of a cross-chain message.
     *
     * Retriggers the sending of a message previously emitted by sendCrossChainMessage that has not yet been acknowledged
     * with a receipt from the destination chain. This may be necessary in the unlikely event that less than the required
     * threshold of stake weight successfully inserted the message in their messages DB at the time of the first submission.
     * The message is checked to have already been previously submitted by comparing its message hash against those kept in
     * state until a receipt is received for the message.
     */
    function retrySendCrossChainMessage(
        bytes32 destinationChainID,
        TeleporterMessage calldata message
    ) external;

    /**
     * @dev Adds the additional fee amount to the amount to be paid to the relayer that delivers
     * the given message ID to the destination chain.
     *
     * The fee contract address must be the same asset type as the fee asset specified in the original
     * call to sendCrossChainMessage. Returns a failure if the message doesn't exist or there is already
     * receipt of delivery of the message.
     */
    function addFeeAmount(
        bytes32 destinationChainID,
        uint256 messageID,
        address feeContractAddress,
        uint256 additionalFeeAmount
    ) external;

    /**
     * @dev Receives a cross-chain message, and marks the `relayerRewardAddress` for fee reward for a successful delivery.
     *
     * The message specified by `messageIndex` must be provided at that index in the access list storage slots of the transaction,
     * and is verified in the precompile predicate.
     */
    function receiveCrossChainMessage(
        uint32 messageIndex,
        address relayerRewardAddress
    ) external;

    /**
     * @dev Retries the execution of a previously delivered message by verifying the payload matches
     * the hash of the payload originally delivered, and calling the destination address again.
     *
     * Intended to be used if message excution failed on initial delivery of the Teleporter message.
     * For example, this may occur if the original required gas limit was not sufficient for the message
     * execution, or if the destination address did not contain a contract, but a compatible contract
     * was later deployed to that address. Messages are ensured to be successfully executed at most once.
     */
    function retryMessageExecution(
        bytes32 originChainID,
        TeleporterMessage calldata message
    ) external;

    /**
     * @dev Sends the receipts for the given `messageIDs`.
     *
     * Sends the receipts of the specified messages in a new message (with an empty payload) back to the origin chain.
     * This is intended to be used if the message receipts were originally included in messages that were dropped
     * or otherwise not delivered in a timely manner.
     */
    function sendSpecifiedReceipts(
        bytes32 originChainID,
        uint256[] calldata messageIDs,
        TeleporterFeeInfo calldata feeInfo,
        address[] calldata allowedRelayerAddresses
    ) external returns (uint256 messageID);

    /**
     * @dev Sends any fee amount rewards for the given fee asset out to the caller.
     */
    function redeemRelayerRewards(address feeAsset) external;

    /**
     * @dev Gets the hash of a given message stored in the EVM state, if the message exists.
     */
    function getMessageHash(
        bytes32 destinationChainID,
        uint256 messageID
    ) external view returns (bytes32 messageHash);

    /**
     * @dev Checks whether or not the given message has been received by this chain.
     */
    function messageReceived(
        bytes32 originChainID,
        uint256 messageID
    ) external view returns (bool delivered);

    /**
     * @dev Returns the address the relayer reward should be sent to on the origin chain
     * for a given message, assuming that the message has already been delivered.
     */
    function getRelayerRewardAddress(
        bytes32 originChainID,
        uint256 messageID
    ) external view returns (address relayerRewardAddress);

    /**
     * Gets the current reward amount of a given fee asset that is redeemable by the given relayer.
     */
    function checkRelayerRewardAmount(
        address relayer,
        address feeAsset
    ) external view returns (uint256);

    /**
     * @dev Gets the fee asset and amount for a given message.
     */
    function getFeeInfo(
        bytes32 destinationChainID,
        uint256 messageID
    ) external view returns (address feeAsset, uint256 feeAmount);

    /**
     * @dev Gets the number of receipts that have been sent to the given destination chain ID.
     */
    function getReceiptQueueSize(
        bytes32 chainID
    ) external view returns (uint256 size);

    /**
     * @dev Gets the receipt at the given index in the queue for the given chain ID.
     * @param chainID The chain ID to get the receipt queue for.
     * @param index The index of the receipt to get, starting from 0.
     */
    function getReceiptAtIndex(
        bytes32 chainID,
        uint256 index
    ) external view returns (TeleporterMessageReceipt memory receipt);
}

/**
 * @dev TeleporterRegistry contract is a {WarpProtocolRegistry} and provides an upgrade
 * mechanism for {ITeleporterMessenger} contracts.
 */
contract TeleporterRegistry is WarpProtocolRegistry {
    constructor(
        ProtocolRegistryEntry[] memory initialEntries
    ) WarpProtocolRegistry(initialEntries) {}

    /**
     * @dev Gets the {ITeleporterMessenger} contract of the given `version`.
     * Requirements:
     *
     * - `version` must be a valid version, i.e. greater than 0 and not greater than the latest version.
     */
    function getTeleporterFromVersion(
        uint256 version
    ) external view returns (ITeleporterMessenger) {
        return ITeleporterMessenger(_getAddressFromVersion(version));
    }

    /**
     * @dev Gets the latest {ITeleporterMessenger} contract.
     */
    function getLatestTeleporter()
        external
        view
        returns (ITeleporterMessenger)
    {
        return ITeleporterMessenger(_getAddressFromVersion(_latestVersion));
    }
}
