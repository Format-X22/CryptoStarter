pragma solidity ^0.4.16;

import './BasicCoin.sol';
import './Project.sol';

/**
 * @notice IdeaCoin (IDEA) - непосредственно сама монета.
 **/
contract IdeaCoin is IdeaBasicCoin {

    /**
     * @notice Конструктор.
     **/
    function IdeaCoin() {
        name = 'IdeaCoin';
        symbol = 'IDEA';
        decimals = 18;
        totalSupply = 100000000 ether; // 100 000 000 IDEA

        owner = msg.sender;
        balances[owner] = totalSupply;
        tryCreateAccount(msg.sender);
    }

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
        Coming,        // Продажи ещё не начинались или ожидается следующий этап.
        PreIco,        // Идет процесс предварительной продажи с высоким бонусом, но высоким порогов входа.
        Ico,           // Идет основной процесс продажи.
        PostIco,       // Продажи закончились и идет временная продажа монет с сайта сервиса.
        Done          // Все продажи успешно завершились.
    }

    /**
     * @notice Текущее состояние ICO.
     **/
    IcoStates public icoState;

    /**
     * @notice Время старта основного этапа ICO.
     **/
    uint public icoStartTimestamp;

    /**
     * @notice Функция продажи монет, работающая в момент пересылки монет на адрес контракта.
     * Отправить ETH можно только в процессе проведения ICO, в иных случаях монеты будут
     * возвращены автоматически.
     **/
    function() payable {
        uint tokens;
        bool moreThenPreIcoMin = msg.value >= 20 ether;

        if (icoState == IcoStates.PreIco && moreThenPreIcoMin && soldIdeaWeiPreIco <= 2500000 ether) {

            tokens = msg.value * 1500;                              // bonus +50% (PRE ICO)
            balances[msg.sender] += tokens;
            soldIdeaWeiPreIco += tokens;

        } else if (icoState == IcoStates.Ico && soldIdeaWeiIco <= 35000000 ether) {
            uint elapsed = now - icoStartTimestamp;

            if (elapsed <= 1 days) {

                tokens = msg.value * 1250;                          // bonus +25% (ICO FIRST DAY)
                balances[msg.sender] += tokens;

            } else if (elapsed <= 6 days && elapsed > 1 days) {

                tokens = msg.value * 1150;                          // bonus +15% (ICO TIER 1)
                balances[msg.sender] += tokens;

            } else if (elapsed <= 11 days && elapsed > 6 days) {

                tokens = msg.value * 1100;                          // bonus +10% (ICO TIER 2)
                balances[msg.sender] += tokens;

            } else if (elapsed <= 16 days && elapsed > 11 days) {

                tokens = msg.value * 1050;                          // bonus +5%  (ICO TIER 3)
                balances[msg.sender] += tokens;

            } else {

                tokens = msg.value * 1000;                          // bonus +0%  (ICO OTHER DAYS)
                balances[msg.sender] += tokens;

            }

            soldIdeaWeiIco += tokens;

        } else if (icoState == IcoStates.PostIco && soldIdeaWeiPostIco <= 12000000 ether) {

            tokens = msg.value * 500;                              // bonus -50% (POST ICO PRICE)
            balances[msg.sender] += tokens;
            soldIdeaWeiPostIco += tokens;

        } else {
            revert();
        }

        earnedEthWei += msg.value;
        soldIdeaWei += tokens;
    }

    /**
     * @notice Перевод контракта в режим PreICO.
     **/
    function startPreIco() public onlyOwner {
        icoState = IcoStates.PreIco;
    }

    /**
     * @notice Остановка PreICO продаж и сжигание не проданных
     * монет в двойном объеме.
     **/
    function stopPreIcoAndBurn() public onlyOwner {
        stopAnyIcoAndBurn(
            (2500000 ether - soldIdeaWeiPreIco) * 2
        );
        balances[owner] = balances[owner].sub(soldIdeaWeiPreIco);
    }

    /**
     * @notice Перевод контракта в режим ICO.
     **/
    function startIco() public onlyOwner {
        icoState = IcoStates.Ico;
        icoStartTimestamp = now;
    }

    /**
     * @notice Остановка ICO продаж и сжигание не проданных
     * монет в двойном объеме.
     **/
    function stopIcoAndBurn() public onlyOwner {
        stopAnyIcoAndBurn(
            (35000000 ether - soldIdeaWeiIco) * 2
        );
        balances[owner] = balances[owner].sub(soldIdeaWeiIco);
    }

    /**
     * @notice Перевод контракта в режим PostICO.
     **/
    function startPostIco() public onlyOwner {
        icoState = IcoStates.PostIco;
    }

    /**
     * @notice Остановка PostICO продаж и сжигание не проданных
     * монет в двойном объеме.
     **/
    function stopPostIcoAndBurn() public onlyOwner {
        stopAnyIcoAndBurn(
            (12000000 ether - soldIdeaWeiPostIco) * 2
        );
        balances[owner] = balances[owner].sub(soldIdeaWeiPostIco);
    }

    /**
     * @notice Остановка любого этапа ICO продаж и сжигание указанного количества монет.
     * Универсальная функция, вызываемая другими функциями.
     * @param _burn Количество монет для сжигания.
     **/
    function stopAnyIcoAndBurn(uint _burn) internal {
        icoState = IcoStates.Coming;

        balances[owner] = balances[owner].sub(_burn);
        totalSupply = totalSupply.sub(_burn);
    }

    /**
     * @notice Вывод собранных монет.
     **/
    function withdrawEther() public onlyOwner {
        owner.transfer(this.balance);
    }

    // ===                          ===
    // === DIVIDENDS ENGINE SECTION ===
    // ===                          ===

    /**
     * @notice Балансы паевых аккаунтов.
     **/
    mapping(address => uint) public pieBalances;

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

        return true;
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

        return true;
    }

    /**
     * @notice Распределение дивидендов участникам паевого фонда.
     * @param _amount Количество.
     **/
    function receiveDividends(uint _amount) internal {
        uint minBalance = 10000 ether;
        uint pieSize = nextRoundReserve + calcPieSize(minBalance);

        accrueDividends(minBalance, pieSize, _amount);
    }

    /**
     * @notice Вычисление размера средств паевого фонда.
     * @param _minBalance Минимальный баланс для учета средств.
     * @return _pieSize Размер.
     **/
    function calcPieSize(uint _minBalance) constant internal returns (uint _pieSize) {
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
            }
        }
    }

    /**
     * @notice Создание паевого аккаунта в случае если такой адрес ещё не зарегистрирован.
     * @param _account Адрес.
     **/
    function tryCreatePieAccount(address _account) internal {
        if (!pieAccountsMap[_account]) {
            pieAccounts.push(_account);
            pieAccountsMap[_account] = true;
        }
    }

    // ===                         ===
    // === PROJECTS ENGINE SECTION ===
    // ===                         ===

    /**
     * @notice Список всех проектов в системе IdeaCoin.
     **/
    address[] public projects;

    /**
     * @notice Создание проекта в системе IdeaCoin.
     * @param _name Имя проекта.
     * @param _required Необходимое количество инвестиций в IDEA.
     * @param _requiredDays Количество дней сбора инвестиций.
     * Должно быть в диапазоне от 10 до 100.
     **/
    function makeProject(string _name, uint _required, uint _requiredDays) public returns (address _address) {
        IdeaProject project = new IdeaProject(
            msg.sender,
            _name,
            _required,
            _requiredDays
        );
        _address = address(project);
        
        projects.push(address(project));
    }


    // ===                         ===
    // === CONTROL PROJECT SECTION ===
    // ===                         ===

    /**
     * @notice Вывести средства, полученные на текущий этап работы.
     * Средства поступят на счет владельца проекта.
     * @param _project Проект.
     **/
    function withdrawFromProject(address _project, uint8 _stage) public returns (bool _success) {
        require(msg.sender == IdeaProject(_project).owner());

        IdeaProject project = IdeaProject(_project);
        uint sum;

        updateFundingStateIfNeed(_project);

        if (project.isWorkflowState() || project.isSuccessDoneState()) {
            sum = project.withdraw(_stage);

            if (sum > 0) {

                receiveTrancheAndDividends(sum);

                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }

    /**
     * @notice Начисление транша автору проекта и дивидендов участникам паевого фонда.
     * Двивиденды равны 3,5% от суммы транша.
     * @param _sum Общая сумма.
     **/
    function receiveTrancheAndDividends(uint _sum) internal {
        uint raw = _sum * 965;
        uint reserve = raw % 1000;
        uint tranche = (raw - reserve) / 1000;

        balances[msg.sender] = balances[msg.sender].add(tranche);
        receiveDividends(_sum - tranche);
    }

    /**
     * @notice Вывести средства назад в случае провала проекта.
     * Если проект был провален на одном из этапов - средства вернуться
     * в соответствии с оставшимся процентом.
     * @param _project Проект.
     * @return _success Успешность запроса.
     **/
    function cashBackFromProject(address _project) public returns (bool _success) {
        IdeaProject project = IdeaProject(_project);

        updateFundingStateIfNeed(_project);

        if (
            project.isFundingFailState() ||
            project.isWorkFailState()
        ) {
            balances[msg.sender] = balances[msg.sender].add(project.calcInvesting(msg.sender));

            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice При необходимости обновить состояние проекта относительно сбора инвестиций.
     * @param _project Проект.
     **/
    function updateFundingStateIfNeed(address _project) internal {
        IdeaProject project = IdeaProject(_project);

        if (
            project.isFundingState() &&
            now > project.fundingEndTime()
        ) {
            if (project.earned() >= project.required()) {
                project.projectWorkStarted();
            } else {
                project.projectFundingFail();
            }
        }
    }
}