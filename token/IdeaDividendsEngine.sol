pragma solidity ^0.4.16;

/**
 * @notice Механизм распределения дивидендов.
 **/
contract IdeaDividendsEngine {

    /**
     * @notice Минимальное количество IDEA токенов на паевом
     * аккаунте для получения дивидендов.
     **/
    uint16 public constant minAmountForDividends = 10000; // 10 000 IDEA

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
    uint nextRoundReserve;

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
    function pieBalanceOf(address _owner) public constant returns (uint balance) {
        return pieBalances[_owner];
    }

    /**
     * @notice Получить общее количество токенов в паевом фонде. 
     * @return supply Количество.
     **/
    function pieCurrentSupply() public constant returns (uint supply) {
        // TODO
    }

    /**
     * @notice Перевод средств с основного аккаунта на паевой.
     * Для получения дивидендов баланс паевого аккаунта должен быть
     * больше чем 10 000 токенов. Дивиденды будут начисляться на
     * паевой аккаунт.
     * @param _amount Количество.
     * @return success Результат.
     **/
    function transferToPie(_amount) public returns (bool success) {
        // TODO
    }

    /**
     * @notice Перевод всех средств с основного аккаунта на паевой.
     * Для получения дивидендов баланс паевого аккаунта должен быть
     * больше чем 10 000 токенов. Дивиденды будут начисляться на
     * паевой аккаунт.
     * @return success Результат.
     **/
    function transferToPieAll() public returns (bool success) {
        // TODO
    }

    /**
     * @notice Перевод средств с паевого аккаунта на основной.
     * Для получения дивидендов баланс паевого аккаунта должен быть
     * больше чем 10 000 токенов. Дивиденды будут начисляться на
     * паевой аккаунт.
     * @param _amount Количество.
     * @return success Результат.
     **/
    function transferFromPie(_amount) public returns (bool success) {
        // TODO
    }

    /**
     * @notice Перевод всех средств с паевого аккаунта на основной.
     * Для получения дивидендов баланс паевого аккаунта должен быть
     * больше чем 10 000 токенов. Дивиденды будут начисляться на
     * паевой аккаунт.
     * @return success Результат.
     **/
    function transferFromPieAll() public returns (bool success) {
        // TODO
    }

    /**
     * @notice Распределение дивидендов участникам паевого фонда.
     * @param _amount Количество.
     **/
    function receiveDividends(uint _amount) internal {
        // TODO
    }
}