pragma solidity ^0.4.16;

contract DividendsEngine {

    struct Deposit {
        address person;
        uint count;
    }
    Deposit[] internal investors;
    mapping(address => uint) internal investorsMap;

    /**
     * @notice Fire on receive dividends to person.
     * @param to Account of person, activated dividends engine.
     * @param value Amount of dividends.
     **/
    event ReceiveDividends(address indexed to, uint value);

    /**
     * @notice Fire on receive dividends to all.
     * @param value Amount of total dividends.
     **/
    event TotalReceiveDividends(uint value);

    /**
     * @notice Activate receive dividends on `amount` tokens amount
     * and hold this amount of your account. Minimal amount is
     * 10 000 IDEA tokens. If you already activate this -
     * your tokens will be add to current hold and increase your profit.
     * Earned dividends will be combines with you hold tokens and increase
     * your profit automatic. You can get back your hold tokens with
     * dividends in any time in any amount.
     * @param amount IDEA tokens amount
     **/
    function startReceiveDividends(uint amount) {
        // TODO
    }

    /**
     * @notice Activate receive dividends on all your tokens amount
     * and hold this amount of your account. Minimal amount is
     * 10 000 IDEA tokens. If you already activate this -
     * your tokens will be add to current hold and increase your profit.
     * Earned dividends will be combines with you hold tokens and increase
     * your profit automatic. You can get back your hold tokens with
     * dividends in any time in any amount.
     * @param amount IDEA tokens amount
     **/
    function startReceiveDividendsOnAll() {
        // TODO
    }

    /**
     * @notice Stop receive dividends for `amount` hold tokens amount
     * and get back it in your account.
     * @param amount IDEA tokens amount
     **/
    function stopReceiveDividends(uint amount) {
        // TODO
    }

    /**
     * @notice Stop receive dividends for all your hold tokens amount
     * and get back it in your account.
     * @param amount IDEA tokens amount
     **/
    function stopReceiveDividendsOnAll() {
        // TODO
    }

    /**
     * @notice Get hold tokens amount used for receive dividends.
     * @return amount IDEA tokens amount
     **/
    function balanceOfHoldOnDividends() returns (uint) {
        // TODO
    }

    /**
     * @notice Get hold tokens amount used for receive dividends by account address.
     * @return amount IDEA tokens amount
     **/
    function balanceOfHoldOnDividendsBy(address target) returns (uint) {
        // TODO
    }

    /**
     * @notice Receive dividends for investors.
     * @return amount IDEA tokens amount
     **/
    function receiveDividends(uint amount) internal {
        // TODO
    }
}