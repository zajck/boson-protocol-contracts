/**
 * Reasons for Boson Protocol transactions to revert
 */
exports.RevertReasons = {

    //General
    INVALID_ADDRESS: "Invalid Address",

    // Facet initializer related
    ALREADY_INITIALIZED: "Already initialized",

    // Offer related
    NOT_OPERATOR: "Not seller's operator",
    NO_SUCH_OFFER: "No such offer",
    OFFER_ALREADY_VOIDED: "Offer already voided",
    OFFER_PERIOD_INVALID: "Offer period invalid"
}