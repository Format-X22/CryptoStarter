pragma solidity ^0.4.16;

/**
 * @notice Механизм распределения дивидендов.
 **/
contract IdeaDividendsEngine {

    /**
     * @notice Получить общее количество токенов в паевом фонде.
     **/
    uint public pieSupply;

    /**
     * @notice Минимальное количество IDEA токенов на паевом
     * аккаунте для получения дивидендов.
     **/
    uint16 public constant minBalanceForDividends = 10000; // 10 000 IDEA

    /**
     * @notice Балансы паевых аккаунтов.
     **/
    mapping(address => uint) pieBalances;

    /**
     * @notice Список адресов всех известных паевых аккаунтов.
     **/
    address[] public pieAccounts;

    /**
     * @notice Список адресов всех известных паевых аккаунтов в виде MAP.
     **/
    mapping(address => bool) internal pieAccountsMap;

    /**
     * @notice Токены, что не были розданы в качестве дивидендов в
     * прошлом раунде. Обычно очень маленькая сумма, которая не может
     * быть нацело поделена между всеми участниками паевого фонда.
     * Эта сумма суммируется со следующим распределением дивидендов.
     **/
    uint public nextRoundReserve;

    /**
     * @notice Совершен перевод с основного аккаунта на паевой.
     * @param account Аккаунт.
     * @param value Количество.
     **/
    event TransferToPie(address indexed account, uint value);

    /**
     * @notice Совершен перевод с паевого аккаунта на основной.
     * @param account Аккаунт.
     * @param value Количество.
     **/
    event TransferFromPie(address indexed account, uint value);

    /**
     * @notice Начислены дивиденды на паевой аккаунт.
     * @param to Аккаунт.
     * @param value Количество.
     **/
    event DividendsReceived(address indexed to, uint value);

    /**
     * @notice Сумма всех дивидендов в этом раунде.
     * @param value Количество.
     **/
    event TotalDividendsReceived(uint value);

    /**
     * @notice Сумма, что будет распределена в следующем раунде раздачи дивидендов.
     * @param value Количество.
     **/
    event DividendsToNextRound(uint value);

    /**
     * @notice Проверить баланс паевого аккаунта.
     * @param _owner Аккаунт.
     * @return balance Количество.
     **/
    function pieBalanceOf(address _owner) constant public returns (uint balance) {
        return pieBalances[_owner];
    }

    /**
     * @notice Перевод средств с основного аккаунта на паевой.
     * Для получения дивидендов баланс паевого аккаунта должен быть
     * больше чем 10 000 токенов. Дивиденды будут начисляться на
     * паевой аккаунт.
     * @param _amount Количество.
     * @return success Результат.
     **/
    function transferToPie(uint _amount) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        pieBalances[msg.sender] = pieBalances[msg.sender].add(_amount);
        tryCreatePieAccount(msg.sender);

        TransferToPie(msg.sender, _amount);

        return true;
    }

    /**
     * @notice Перевод всех средств с основного аккаунта на паевой.
     * Для получения дивидендов баланс паевого аккаунта должен быть
     * больше чем 10 000 токенов. Дивиденды будут начисляться на
     * паевой аккаунт.
     * @return success Результат.
     **/
    function transferToPieAll() public returns (bool success) {
        return transferToPie(balances[msg.sender]);
    }

    /**
     * @notice Перевод средств с паевого аккаунта на основной.
     * Для получения дивидендов баланс паевого аккаунта должен быть
     * больше чем 10 000 токенов. Дивиденды будут начисляться на
     * паевой аккаунт.
     * @param _amount Количество.
     * @return success Результат.
     **/
    function transferFromPie(uint _amount) public returns (bool success) {
        pieBalances[msg.sender] = pieBalances[msg.sender].sub(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);

        TransferFromPie(msg.sender, _amount);

        return true;
    }

    /**
     * @notice Перевод всех средств с паевого аккаунта на основной.
     * Для получения дивидендов баланс паевого аккаунта должен быть
     * больше чем 10 000 токенов. Дивиденды будут начисляться на
     * паевой аккаунт.
     * @return success Результат.
     **/
    function transferFromPieAll() public returns (bool success) {
        return transferFromPie(pieBalances[msg.sender]);
    }

    /**
     * @notice Распределение дивидендов участникам паевого фонда.
     * @param _amount Количество.
     **/
    function receiveDividends(uint _amount) internal {
        uint pieSize = nextRoundReserve;
        uint[0] activatedAccounts;

        nextRoundReserve = 0;

        for (uint i = 0; i < pieAccounts.length; i += 1) {
            var balance = pieBalances[pieAccounts[i]];

            if (balance >= minBalanceForDividends ** decimals) {
                pieSize = pieSize.add(balance);
                activatedAccounts.push(pieAccounts[i]);
            }
        }

        for (uint j = 0; j < activatedAccounts.length; j += 1) {
            uint account = activatedAccounts[j];
            uint reserve = (_amount * pieBalances[account]) % pieSize;
            uint dividends = (_amount - reserve) * pieBalances[account] / pieSize;

            nextRoundReserve = nextRoundReserve.add(reserve);
            pieBalances[account] = pieBalances[account].add(dividends);

            DividendsReceived(account, dividends);
        }

        TotalDividendsReceived(_amount - nextRoundReserve);
        DividendsToNextRound(nextRoundReserve);
    }

    /**
     * @notice Создание паевого аккаунта в случае если такой адрес ещё не зарегистрирован.
     * @param _account Адрес.
     **/
    function tryCreatePieAccount(address _account) internal {
        if (pieBalances[_account] == 0 && !pieAccountsMap[_account]) {
            pieAccounts.push(_account);
            pieAccountsMap[_account] = true;
        }
    }
}