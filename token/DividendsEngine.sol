pragma solidity ^0.4.16;

contract DividendsEngine {

    mapping(address => uint) internal balances;

    uint constant minInvest = 10000;
    struct Deposit {
        address person;
        uint amount;
    }
    Deposit[] internal investors;
    mapping(address => uint) internal investorsMap;

    /**
     * @notice Fire on transfer IDEA tokens to personal dividends account.
     * @param target Account address
     * @param amount Amount of tokens
     **/
    event TransferToDividendsAccount(address target, uint amount);

    /**
     * @notice Fire on transfer IDEA tokens from personal dividends account.
     * @param target Account address
     * @param amount Amount of tokens
     **/
    event TransferFromDividendsAccount(address target, uint amount);

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
     * @notice Transfer `amount` IDEA tokens to personal dividends account.
     * When amount of dividends account will be `minInvest` or more IDEA
     * tokens - you start earn dividends from CryptoStarter platform.
     * On receive dividends your profit will be add to dividends account.
     * You can transfer your tokens with dividends from dividends
     * account to main account in any time in any amount.
     * @param amount IDEA tokens amount
     **/
    function transferToDividendsAccount(uint amount) {
        require(balances[msg.sender] >= amount);
        require(amount > 0);

        if (investorsMap[msg.sender]) {
            balances[msg.sender] -= amount;
            investors[investorsMap[msg.sender] - 1].amount += amount;
        } else {
            var deposit = new Deposit(msg.sender, amount);

            investors.push(deposit);
            investorsMap[msg.sender] = investors.length; // No bug, just avoid 0.
        }

        TransferToDividendsAccount(msg.sender, amount);
    }

    /**
     * @notice Transfer all your IDEA tokens to personal dividends account.
     * When amount of dividends account will be `minInvest` or more IDEA
     * tokens - you start earn dividends from CryptoStarter platform.
     * On receive dividends your profit will be add to dividends account.
     * You can transfer your tokens with dividends from dividends
     * account to main account in any time in any amount.
     * @param amount IDEA tokens amount
     **/
    function transferAllToDividendsAccount() {
        transferToDividendsAccount(balances[msg.sender]);
    }

    /**
     * @notice Transfer `amount` IDEA tokens from your personal dividends account.
     * See 'transferToDividendsAccount' hint.
     * @param amount IDEA tokens amount
     **/
    function transferFromDividendsAccount(uint amount) {
        require(balanceOfDividendsAccount() >= amount);

        investors[investorsMap[msg.sender] - 1].amount -= amount;
        balances[msg.sender] += amount;

        TransferFromDividendsAccount(msg.sender, amount);
    }

    /**
     * @notice Transfer all your IDEA tokens from your personal dividends account.
     * See 'transferAllToDividendsAccount' hint.
     **/
    function transferAllFromDividendsAccount() {
        transferFromDividendsAccount(balanceOfDividendsAccount());
    }

    /**
     * @notice Get balance of your personal dividends account.
     * See 'transferToDividendsAccount' hint.
     * @return amount IDEA tokens amount
     **/
    function balanceOfDividendsAccount() returns (uint) {
        return balanceOfDividendsAccountBy(msg.sender);
    }

    /**
     * @notice Get balance of `target` dividends account.
     * See 'transferToDividendsAccount' hint.
     * @return amount IDEA tokens amount
     **/
    function balanceOfDividendsAccountBy(address target) returns (uint) {
        require(investorsMap[target]);
    
        return investors[investorsMap[target] - 1].amount;
    }

    /**
     * @notice Receive dividends for investors.
     * @return amount IDEA tokens amount
     **/
    function receiveDividends(uint amount) internal {
        // TODO
    }
}