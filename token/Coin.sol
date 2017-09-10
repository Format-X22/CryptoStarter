pragma solidity ^0.4.15;

import './BasicCoin.sol';

/**
 * @notice IdeaCoin (IDEA) - непосредственно сама монета.
 **/
contract IdeaCoin is IdeaBasicCoin {

    /**
     * @notice Владелец IdeaCoin.
     **/
    address public owner;

    /**
     * @notice Конструктор.
     **/
    function IdeaCoin() {
        name = 'IdeaCoin';
        symbol = 'IDEA';
        decimals = 18;
        uint supply = 600000000; // 600 000 000 IDEA
        totalSupply = supply ** decimals;

        owner = msg.sender;
        balances[owner] = totalSupply;
        tryCreateAccount(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // ===                          ===
    // === DIVIDENDS ENGINE SECTION ===
    // ===                          ===

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
     * @param _account Аккаунт.
     * @param _value Количество.
     **/
    event TransferToPie(address indexed _account, uint _value);

    /**
     * @notice Совершен перевод с паевого аккаунта на основной.
     * @param _account Аккаунт.
     * @param _value Количество.
     **/
    event TransferFromPie(address indexed _account, uint _value);

    /**
     * @notice Начислены дивиденды на паевой аккаунт.
     * @param _to Аккаунт.
     * @param _value Количество.
     **/
    event DividendsReceived(address indexed _to, uint _value);

    /**
     * @notice Сумма всех дивидендов в этом раунде.
     * @param _value Количество.
     **/
    event TotalDividendsReceived(uint _value);

    /**
     * @notice Сумма, что будет распределена в следующем раунде раздачи дивидендов.
     * @param _value Количество.
     **/
    event DividendsToNextRound(uint _value);

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
        uint minBalance = minBalanceForDividends ** decimals;
        uint pieSize = nextRoundReserve + calcPieSize(minBalance);

        accrueDividends(minBalance, pieSize, _amount);

        TotalDividendsReceived(_amount - nextRoundReserve);
        DividendsToNextRound(nextRoundReserve);
    }

    /**
     * @notice Вычисление размера средств паевого фонда.
     * @param _minBalance Минимальный баланс для учета средств.
     * @return _pieSize Размер.
     **/
    function calcPieSize(uint _minBalance) internal returns (uint _pieSize) {
        for (uint i = 0; i < pieAccounts.length; i += 1) {
            var balance = pieBalances[pieAccounts[i]];

            if (balance >= _minBalance) {
                _pieSize = _pieSize.add(balance);
            }
        }
    }

    /**
     * @notice Непосредственно начисление дивидендов.
     * @param _minBalance Минимальный баланс для учета средств.
     * @param _pieSize Размер паевого фонда.
     * @param _amount Количество дивидендов суммарно.
     **/
    function accrueDividends(uint _minBalance, uint _pieSize, uint _amount) internal {
        for (uint i = 0; i < pieAccounts.length; i += 1) {
            address account = pieAccounts[i];
            uint balance = pieBalances[account];

            if (balance >= _minBalance) {
                uint reserve = (_amount * balance) % _pieSize;
                uint dividends = (_amount - reserve) * balance / _pieSize;

                nextRoundReserve = nextRoundReserve.add(reserve);
                pieBalances[account] = balance.add(dividends);

                DividendsReceived(account, dividends);
            }
        }
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

    // ===                         ===
    // === PROJECTS ENGINE SECTION ===
    // ===                         ===

    // TODO

    // ===             ===
    // === ICO SECTION ===
    // ===             ===

    /**
     * @notice TODO
     **/
    uint public earnedEthWei;

    /**
     * @notice TODO
     **/
    uint public earnedIdeaWei;

    /**
     * @notice TODO
     **/
    uint public maxCoinsForPreIco = 20000; // 20 000 IDEA

    /**
     * @notice TODO
     **/
    uint public maxCoinsForIco = 200000; // 200 000 IDEA

    /**
     * @notice TODO
     **/
    uint public maxCoinsForPostIco = 80000; // 80 000 IDEA

    /**
     * @notice TODO
     **/
    uint public minEtherForPreIcoBuy = 20;

    /**
     * @notice TODO
     **/
    enum IcoStates {
        Coming,
        PreIco,
        Ico,
        PostIco,
        Done,
        Waiting
    }

    /**
     * @notice TODO
     **/
    IsoStates icoState = IcoStates.Coming;

    /**
     * @notice TODO
     **/
    uint icoStartTimestamp;

    /**
     * @notice TODO
     **/
    function() payable {
        uint tokens;
        bool moreThenPreIcoMin = msg.value > minEtherForPreIcoBuy * 1 ether;

        if (icoState == IcoStates.PreIco && moreThenPreIcoMin) {

            tokens = msg.value * 1500;                              // bonus +50% (PRE ICO)
            balances[msg.sender] += tokens;

        } else if (icoState == IcoStates.Ico) {
            uint elapsed = now - icoStartTimestamp;

            if (elapsed <= 1 days) {

                tokens = msg.value * 1250;                          // bonus +25% (ICO FIRST DAY)
                balances[msg.sender] = tokens;

            } else if (elapsed <= 6 days && elapsed > 1 days) {

                tokens = msg.value * 1150;                          // bonus +15% (ICO TIER 1)
                balances[msg.sender] = tokens;

            } else if (elapsed <= 11 days && elapsed > 6 days) {

                tokens = msg.value * 1100;                          // bonus +10% (ICO TIER 2)
                balances[msg.sender] = tokens;

            } else if (elapsed <= 16 days && elapsed > 11 days) {

                tokens = msg.value * 1050;                          // bonus +5%  (ICO TIER 3)
                balances[msg.sender] = tokens;

            } else {

                tokens = msg.value * 1000;                          // bonus +0%  (ICO OTHER DAYS)
                balances[msg.sender] = tokens;

            }

        } else if (icoState == IcoStates.PostIco) {

            tokens = msg.value * 500;                              // bonus -50% (POST ICO PRICE)
            balances[msg.sender] = tokens;

        } else {
            revert();
        }

        earnedEthWei += msg.value;
        earnedIdeaWei += tokens;
    }

    /**
     * @notice Перевод контракта в режим PreICO.
     **/
    function startPreIco() public onlyOwner {
        icoState = IcoStates.PreIco;
    }

    /**
     * @notice TODO
     **/
    function stopPreIco() public onlyOwner {
        // TODO burn
    }

    /**
     * @notice Перевод контракта в режим ICO.
     **/
    function startIco() public onlyOwner {
        icoState = IcoStates.Ico;
        icoStartTimestamp = now;
    }

    /**
     * @notice TODO
     **/
    function stopIco() public onlyOwner {
        // TODO burn
    }

    /**
     * @notice Перевод контракта в режим PostICO.
     **/
    function startPostIco() public onlyOwner {
        icoState = IcoStates.PostIco;
    }

    /**
     * @notice TODO
     **/
    function stopPostIco() public onlyOwner {
        // TODO burn
    }

    /**
     * @notice Вывод собранных монет.
     **/
    function withdrawEther() public onlyOwner {
        this.transfer(owner);
    }
}