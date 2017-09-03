pragma solidity ^0.4.16;

/**
 * @notice Механизм распределения дивидендов.
 **/
contract IdeaDividendsEngine {

    mapping(address => uint) internal balances;

    uint constant minInvest = 10000;
    struct Deposit {
        address person;
        uint amount;
    }
    Deposit[] internal investors;
    mapping(address => uint) internal investorsMap;
    uint private reserve = 0; // Save tokens for next dividends receive

    /**
     * @notice Токены переведены с основного аккаунта на паевой аккаунт.
     * @param target Аккаунт.
     * @param amount Количество.
     **/
    event TransferToPieAccount(address target, uint amount);

    /**
     * @notice Токены переведены с паевого аккаунта на основной аккаунт.
     * @param target Аккаунт.
     * @param amount Количество.
     **/
    event TransferFromPieAccount(address target, uint amount);

    /**
     * @notice Дивиденды начислены.
     * @param to Аккаунт.
     * @param value Количество.
     **/
    event ReceiveDividends(address indexed to, uint value);

    /**
     * @notice Дивиденды начислены всем.
     * @param value Количество.
     **/
    event TotalReceiveDividends(uint value);

    /**
     * @notice Перевод токенов с основного аккаунта на паевой аккаунт.
     * Для включения механизма начисления на счету паевого аккаунта
     * должно быть не менее 10 000 токенов. Чем больше сумма - тем больший
     * процент дивидендов будет начислен - по принципу паевого фонда.
     * Дивиденды будут начисляться на паевой аккаунт.
     * @param amount Количество.
     **/
    function transferToPieAccount(uint amount) {
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

        TransferToPieAccount(msg.sender, amount);
    }

    /**
     * Аналог transferToPieAccount, но в данном случае будут
     * переведены все средсва что есть на счету.
     **/
    function transferAllToPieAccount() {
        transferToPieAccount(balances[msg.sender]);
    }

    /**
     * @notice Перевод токенов с паевого аккаунта на основной аккаунт.
     * Если на счету паевого аккаунта останется меньше 10 000 токенов -
     * начисление дивидендов будет остановлено.
     * @param amount Количество.
     **/
    function transferFromPieAccount(uint amount) {
        require(balanceOfPieAccount() >= amount);

        investors[investorsMap[msg.sender] - 1].amount -= amount;
        balances[msg.sender] += amount;

        TransferFromPieAccount(msg.sender, amount);
    }

    /**
     * Аналог transferToPieAccount, но в данном случае будут
     * переведены все средсва что есть на счету.
     **/
    function transferFromPieAccount() {
        transferFromPieAccount(balanceOfPieAccount());
    }

    /**
     * @notice Получение текущего баланса паевого аккаунта.
     * @return amount Количество.
     **/
    function balanceOfPieAccount() returns (uint amount) {
        return balanceOfPieAccountBy(msg.sender);
    }

    /**
     * @notice Получение текущего баланса паевого аккаунта по указанному адресу.
     * @param target Целевой адрес.
     * @return amount Количество.
     **/
    function balanceOfPieAccountBy(address target) returns (uint amount) {
        require(investorsMap[target]);
    
        return investors[investorsMap[target] - 1].amount;
    }

    // TODO - fix bugs
    function receiveDividends(uint amount) internal {
        uint total = reserve;
        address[] currentInvestors;

        for(uint i = 0; i < investors.length; i++) {
            Deposit current = investors[i];

            if (current.amount > minInvest) {
                currentInvestors.push(current.person);
                total += current.amount;
            }
        }

        for(uint i = 0; i < currentInvestors.length; i++) {
            address person = currentInvestors[i];
            uint fullAmount = investorsMap[person].amount;
            uint forReserve = total % amount;
            uint amount = (total - forReserve) / fullAmount;

            reserve += forReserve;
            investorsMap[person].amount += amount;

            ReceiveDividends(person, amount);
        }

        TotalReceiveDividends(total - saved);
    }
}