// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import {BosonTypes} from "../../domain/BosonTypes.sol";
import {IBosonExchangeEvents} from "../events/IBosonExchangeEvents.sol";
import {IBosonFundsLibEvents} from "../events/IBosonFundsEvents.sol";

/**
 * @title IBosonExchangeHandler
 *
 * @notice Handles exchanges associated with offers within the protocol.
 *
 * The ERC-165 identifier for this interface is: 0x028ba007
 */
interface IBosonExchangeHandler is IBosonExchangeEvents, IBosonFundsLibEvents {

    /**
     * @notice Commit to an offer (first step of an exchange)
     *
     * Emits an BuyerCommitted event if successful.
     * Issues a voucher to the buyer address.
     *
     * Reverts if:
     * - offerId is invalid
     * - offer has been voided
     * - offer has expired
     * - offer is not yet available for commits
     * - offer's quantity available is zero
     * - buyer address is zero
     * - buyer account is inactive
     * - offer price is in native token and buyer caller does not send enough
     * - offer price is in some ERC20 token and caller also send native currency
     * - if contract at token address does not support erc20 function transferFrom
     * - if calling transferFrom on token fails for some reason (e.g. protocol is not approved to transfer)
     * - if seller has less funds available than sellerDeposit
     *
     * @param _buyer - the buyer's address (caller can commit on behalf of a buyer)
     * @param _offerId - the id of the offer to commit to
     */
    function commitToOffer(address payable _buyer, uint256 _offerId) external payable;

    /**
     * @notice Complete an exchange.
     *
     * Reverts if
     * - Exchange does not exist
     * - Exchange is not in redeemed state
     * - Caller is not buyer or seller's operator
     * - Caller is seller's operator and offer fulfillment period has not elapsed
     *
     * Emits
     * - ExchangeCompleted
     *
     * @param _exchangeId - the id of the exchange to complete
     */
    function completeExchange(uint256 _exchangeId) external;

    /**
     * @notice Revoke a voucher.
     *
     * Reverts if
     * - Exchange does not exist
     * - Exchange is not in committed state
     * - Caller is not seller's operator
     *
     * Emits
     * - VoucherRevoked
     *
     * @param _exchangeId - the id of the exchange to complete
     */
    function revokeVoucher(uint256 _exchangeId) external;

    /**
     * @notice Cancel a voucher.
     *
     * Reverts if
     * - Exchange does not exist
     * - Exchange is not in committed state
     * - Caller does not own voucher
     *
     * Emits
     * - VoucherCanceled
     *
     * @param _exchangeId - the id of the exchange
     */
    function cancelVoucher(uint256 _exchangeId) external;

    /**
     * @notice Redeem a voucher.
     *
     * Reverts if
     * - Exchange does not exist
     * - Exchange is not in committed state
     * - Caller does not own voucher
     *
     * Emits
     * - VoucherRedeemed
     *
     * @param _exchangeId - the id of the exchange
     */
    function redeemVoucher(uint256 _exchangeId) external;

    /**
     * @notice Is the given exchange in a finalized state?
     *
     * Returns true if
     * - Exchange state is Revoked, Canceled, or Completed
     * - Exchange is disputed and dispute state is Retracted, Resolved, or Decided
     *
     * @param _exchangeId - the id of the exchange to check
     * @return exists - true if the exchange exists
     * @return isFinalized - true if the exchange is finalized
     */
    function isExchangeFinalized(uint256 _exchangeId)
    external
    view
    returns(bool exists, bool isFinalized);

    /**
     * @notice Gets the details about a given exchange.
     *
     * @param _exchangeId - the id of the exchange to check
     * @return exists - the exchange was found
     * @return exchange - the exchange details. See {BosonTypes.Exchange}
     */
    function getExchange(uint256 _exchangeId) external view returns (bool exists, BosonTypes.Exchange memory exchange);

    /**
     * @notice Gets the state of a given exchange.
     *
     * @param _exchangeId - the id of the exchange to check
     * @return exists - true if the exchange exists
     * @return state - the exchange state. See {BosonTypes.ExchangeStates}
     */
    function getExchangeState(uint256 _exchangeId) external view returns (bool exists, BosonTypes.ExchangeState state);

    /**
     * @notice Gets the Id that will be assigned to the next exchange.
     *
     *  Does not increment the counter.
     *
     * @return nextExchangeId - the next exchange Id
     */
    function getNextExchangeId() external view returns (uint256 nextExchangeId);
}
