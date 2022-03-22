// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;


import { IBosonAccountHandler } from "../../interfaces/IBosonAccountHandler.sol";
import { DiamondLib } from "../../diamond/DiamondLib.sol";
import { ProtocolBase } from "../ProtocolBase.sol";
import { ProtocolLib } from "../ProtocolLib.sol";

contract AccountHandlerFacet is IBosonAccountHandler, ProtocolBase {

    /**
     * @dev Modifier to protect initializer function from being invoked twice.
     */
    modifier onlyUnInitialized()
    {
        ProtocolLib.ProtocolInitializers storage pi = ProtocolLib.protocolInitializers();
        require(!pi.accountHandler, ALREADY_INITIALIZED);
        pi.accountHandler = true;
        _;
    }

    /**
     * @notice Facet Initializer
     */
    function initialize()
    public
    onlyUnInitialized
    {
        DiamondLib.addSupportedInterface(type(IBosonAccountHandler).interfaceId);
    }

    /**
     * @notice Creates a seller
     *
     * Emits a SellerCreated event if successful.
     *
     * Reverts if:
     * - Address values are zero address
     *
     * @param _seller - the fully populated struct with seller id set to 0x0
     */
    function createSeller(Seller calldata _seller)
    external
    override
    {
        //Check for zero address
        require(_seller.admin != address(0) &&  _seller.operator != address(0) && _seller.clerk != address(0) && _seller.treasury != address(0), INVALID_ADDRESS);

        // Get the next account Id and increment the counter
        uint256 sellerId = protocolStorage().nextAccountId++;

        // Get storage location for seller
        Seller storage seller = ProtocolLib.getSeller(sellerId);

        // Set seller props individually since memory structs can't be copied to storage
        seller.id = sellerId;
        seller.operator = _seller.operator;
        seller.admin = _seller.admin;
        seller.clerk = _seller.clerk;
        seller.treasury = _seller.treasury;
        seller.active = _seller.active;

        //Map the seller's addresses to the sellerId. It's not necessary to map the treasury address, as it only receives funds
        protocolStorage().operatorsToSellers[_seller.operator] = sellerId;
        protocolStorage().adminsToSellers[_seller.admin] = sellerId;
        protocolStorage().cerksToSellers[_seller.clerk] = sellerId;

        // Notify watchers of state change
        emit SellerCreated(sellerId, _seller);
    }
  


    /**
     * @notice Gets the next account Id that can be assigned to an account.
     *
     * @return nextAccountId - the account Id
     */
    function getNextAccountId()
    external
    override
    view 
    returns(uint256 nextAccountId) {
        nextAccountId = ProtocolLib.protocolStorage().nextAccountId;
    }

}