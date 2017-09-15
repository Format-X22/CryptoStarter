pragma solidity ^0.4.16;

contract IdeaStorage {

    // ===             ===
    // === ICO SECTION ===
    // ===             ===

    /**
     * @notice Количество собранного на всех этапах ICO монет ETH в размерности WEI.
     **/
    uint public earnedEthWei;

    /**
     * @notice Количество проданных на всех этапах ICO монет IDEA в размерности WEI.
     **/
    uint public soldIdeaWei;

    /**
     * @notice Количество проданных на этапе PreICO монет IDEA в размерности WEI.
     **/
    uint public soldIdeaWeiPreIco;

    /**
     * @notice Количество проданных на этапе ICO монет IDEA в размерности WEI.
     **/
    uint public soldIdeaWeiIco;

    /**
     * @notice Количество проданных на этапе PostICO монет IDEA в размерности WEI.
     **/
    uint public soldIdeaWeiPostIco;

    /**
     * @notice Состояния ICO.
     **/
    enum IcoStates {
        Coming,        // Продажи ещё не начинались.
        PreIco,        // Идет процесс предварительной продажи с высоким бонусом, но высоким порогов входа.
        Ico,           // Идет основной процесс продажи.
        PostIco,       // Продажи закончились и идет временная продажа монет с сайта сервиса.
        Done,          // Все продажи успешно завершились.
        Waiting        // Один из этапов продаж завершился и идет ожидание следующего.
    }

    /**
     * @notice Текущее состояние ICO.
     **/
    IcoStates icoState = IcoStates.Coming;

    /**
     * @notice Время старта основного этапа ICO.
     **/
    uint icoStartTimestamp;

    // ===                          ===
    // === DIVIDENDS ENGINE SECTION ===
    // ===                          ===

    /**
     * @notice Получить общее количество токенов в паевом фонде.
     **/
    uint public pieSupply;


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

    // ===                         ===
    // === PROJECTS ENGINE SECTION ===
    // ===                         ===

    /**
     * @notice Список всех проектов в системе IdeaCoin.
     **/
    address[] public projects;

    

}