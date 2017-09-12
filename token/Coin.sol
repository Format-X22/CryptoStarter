pragma solidity ^0.4.15;

import './BasicCoin.sol';

/**
 * @notice IdeaCoin (IDEA) - непосредственно сама монета.
 * Также яляется единым центром управления проектами и их продуктами.
 * Исключением является только функциональность продуктов (саб-монет)
 * как непосредственно монет - они являются полноценными монетами стандарта ERC20
 * и могут работать автономно.
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
        uint supply = 100000000; // 100 000 000 IDEA
        totalSupply = supply ** decimals;

        owner = msg.sender;
        balances[owner] = totalSupply;
        tryCreateAccount(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // ===             ===
    // === ICO SECTION ===
    // ===             ===

    /**
     * @notice Максимальное количество монет, разрешенных к продаже на PreICO.
     * Не проданное будет сожжено в двойном размере от общего количества монет.
     **/
    uint constant public maxCoinsForPreIco = 2500000; // 2 500 000 IDEA

    /**
     * @notice Максимальное количество монет, разрешенных к продаже на ICO.
     * Не проданное будет сожжено в двойном размере от общего количества монет.
     **/
    uint constant public maxCoinsForIco = 35000000; // 35 000 000 IDEA

    /**
     * @notice Максимальное количество монет, разрешенных к продаже на PostICO.
     * Не проданное будет сожжено в двойном размере от общего количества монет.
     **/
    uint constant public maxCoinsForPostIco = 12000000; // 12 000 000 IDEA

    /**
     * @notice Минимальное количество монет ETH за которое производится продажа
     * монет IDEA на PreICO.
     **/
    uint constant public minEtherForPreIcoBuy = 20;

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
    IsoStates icoState = IcoStates.Coming;

    /**
     * @notice Время старта основного этапа ICO.
     **/
    uint icoStartTimestamp;

    /**
     * @notice Произведена покупка монет IDEA за монеты ETH.
     * @param _account Аккаунт покупателя.
     * @param _eth Количество монет ETH.
     * @param _idea Количество монет IDEA.
     **/
    event Buy(address indexed _account, uint _eth, uint _idea);

    /**
     * @notice Сожжено некоторое количество монет IDEA.
     * Происходит после завершения очередного этапа ICO.
     * @param _amount Количество.
     **/
    event Burned(uint _amount);

    /**
     * @notice Функция продажи монет, работающая в момент пересылки монет на адрес контракта.
     * Отправить ETH можно только в процессе проведения ICO, в иных случаях монеты будут
     * возвращены автоматически.
     **/
    function() payable {
        uint tokens;
        bool moreThenPreIcoMin = msg.value > minEtherForPreIcoBuy * 1 ether;

        if (icoState == IcoStates.PreIco && moreThenPreIcoMin && soldIdeaWeiPreIco <= maxCoinsForPreIco ** decimals) {

            tokens = msg.value * 1500;                              // bonus +50% (PRE ICO)
            balances[msg.sender] += tokens;
            soldIdeaWeiPreIco += tokens;

        } else if (icoState == IcoStates.Ico && soldIdeaWeiIco <= maxCoinsForIco ** decimals) {
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

            soldIdeaWeiIco += tokens;

        } else if (icoState == IcoStates.PostIco && soldIdeaWeiPostIco <= maxCoinsForPostIco ** decimals) {

            tokens = msg.value * 500;                              // bonus -50% (POST ICO PRICE)
            balances[msg.sender] = tokens;
            soldIdeaWeiPostIco += tokens;

        } else {
            revert();
        }

        earnedEthWei += msg.value;
        soldIdeaWei += tokens;

        Buy(msg.sender, msg.value, tokens);
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
            (maxCoinsForPreIco ** decimals - soldIdeaWeiPreIco) * 2
        );
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
            (maxCoinsForIco ** decimals - soldIdeaWeiIco) * 2
        );
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
            (maxCoinsForPostIco ** decimals - soldIdeaWeiPostIco) * 2
        );
    }

    /**
     * @notice Остановка любого этапа ICO продаж и сжигание указанного количества монет.
     * Универсальная функция, вызываемая другими функциями.
     * @param _burn Количество монет для сжигания.
     **/
    function stopAnyIcoAndBurn(uint _burn) internal onlyOwner {
        icoState = IcoStates.Waiting;

        balances[owner] = balances[owner].sub(_burn);
        totalSupply = totalSupply.sub(_burn);

        Burn(_burn);
    }

    /**
     * @notice Вывод собранных монет.
     **/
    function withdrawEther() public onlyOwner {
        this.transfer(owner);
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

    address[] public projects;

    modifier onlyProjectOwner(address _project) {
        require(msg.sender == IdeaProject(_project).owner());
        _;
    }

    modifier onlyProductOwner(address _product) {
        require(msg.sender == IdeaSubCoin(_product).owner());
        _;
    }

    function makeProject() public {
        //
    }

    function getAllProjects() constant public returns (address[] _result) {
        return projects;
    }

    function getAllMyProjects() constant public {
        //
    }

    function getAllProducts(address _project) constant public {
        //
    }

    function getAllMyProducts(address _project) constant public {
        //
    }

    // ===                         ===
    // === CONTROL PROJECT SECTION ===
    // ===                         ===

    /**
     * @notice Установка имени проекта.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _project Проект.
     * @param _name Новое имя.
     **/
    function setProjectName(address _project, string _name) public onlyProjectOwner(_project) {
        IdeaProject(_project).setName(_name);
    }

    /**
     * @notice Установка значения неоходимых инвестиций.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _project Проект.
     * @param _required Значение.
     **/
    function setProjectRequired(address _project, uint _required) public onlyProjectOwner(_project) {
        IdeaProject(_project).setRequired(_required);
    }

    /**
     * @notice Установка значения времени сбора средств.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _project Проект.
     * @param _requiredDays Количество дней.
     **/
    function setProjectRequiredDays(address _project, uint _requiredDays) public onlyProjectOwner(_project) {
        IdeaProject(_project).setRequiredDays(_requiredDays);
    }

    /**
     * @notice Перевести проект в состояние 'Coming'
     * и заблокировать возможность внесения изменений.
     * @param _project Проект.
     **/
    function markProjectAsComingAndFreeze(address _project) public onlyProjectOwner(_project) {
        IdeaProject(_project).markAsComingAndFreeze();
    }

    /**
     * @notice Запустить сбор средств.
     * Остановить сбор будет нельзя. При успешном сборе проект перейдет
     * в состояние начала работ и будут начислены средства за первый этап.
     * В случае не сбора средств за необходимое время - проект будет закрыт,
     * а средства вернуться на счета инвесторов.
     * @param _project Проект.
     **/
    function startProjectFunding(address _project) public onlyProjectOwner(_project) {
        IdeaProject(_project).startFunding();
    }

    /**
     * @notice Пометить проект как завершенный. Проект должен находится
     * на последнем этапе работ. Также это означает что стартует доставка
     * готовой продукции.
     * @param _project Проект.
     **/
    function projectDone(address _project) public onlyProjectOwner(_project) {
        IdeaProject(_project).projectDone();
    }

    /**
     * @notice Создать этап работы.
     * Суммарно должно быть не более 10 этапов (`maxWorkStages`),
     * а также сумма процентов всех этапов должна быть равна 100%.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _project Проект.
     * @param _name Имя этапа.
     * @param _percent Процент средств от общего бюджета.
     * @param _stageDays Количество дней выполнения этапа.
     * Количество должно быть не менее 10 и не более 100 дней.
     **/
    function makeProjectWorkStage(
        address _project,
        string _name,
        uint8 _percent,
        uint8 _stageDays
    ) public onlyProjectOwner(_project) {
        IdeaProject(_project).makeProjectWorkStage(_name, _percent, _stageDays);
    }

    /**
     * @notice Уничтожить последний созданный этап.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _project Проект.
     **/
    function destroyProjectLastWorkStage(address _project) public onlyProjectOwner(_project) {
        IdeaProject(_project).destroyLastWorkStage();
    }

    /**
     * @notice Уничтожить все этапы.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _project Проект.
     **/
    function destroyAllProjectWorkStages(address _project) public onlyProjectOwner(_project) {
        IdeaProject(_project).destroyAllWorkStages();
    }

    /**
     * @notice Создания продукта, предлагаемого проектом.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _project Проект.
     * @param _name Имя продукта.
     * @param _symbol Символ продукта.
     * @param _price Цена продукта в IDEA токенах в размерности WEI.
     * @param _limit Лимит количества продуктов, 0 установит безлимитный режим.
     * @return _productAddress Адрес экземпляра контракта продукта.
     **/
    function makeProjectProduct(
        address _project,
        string _name,
        string _symbol,
        uint _price,
        uint _limit
    ) public onlyProjectOwner(_project) returns (address _productAddress) {
        return IdeaProject(_project).makeProduct(_name, _symbol, _price, _limit);
    }

    /**
     * @notice Получение всех адресов продуктов.
     * @param _project Проект.
     * @return _result Результат.
     **/
    function getAllProjectProductsAddresses(
        address _project
    ) constant public onlyProjectOwner(_project) returns (address[] _result) {
        return IdeaProject(_project).getAllProductsAddresses();
    }

    /**
     * @notice Уничтожить последний созданный продукт.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _project Проект.
     **/
    function destroyProjectLastProduct(address _project) public onlyProjectOwner(_project) {
        IdeaProject(_project).destroyLastProduct();
    }

    /**
     * @notice Уничтожить все продукты.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _project Проект.
     **/
    function destroyAllProjectProducts(address _project) public onlyProjectOwner(_project) {
        IdeaProject(_project).destroyAllProducts();
    }

    /**
     * @notice Отдать голос за прекращение проекта и возврат средств.
     * Голосовать можно в любой момент, также можно отменить голос воспользовавшись
     * методом 'cancelVoteForCashBack'. Вес голоса зависит от количества вложенных средств.
     * Перед началом нового этапа работ и выдачей очередного транша создателю проекта -
     * происходит проверка на голоса за возврат. Если голосов, с учетом их веса, суммарно
     * оказалось больше 50% общего веса голосов - проект помечается как провальный,
     * владелец проекта не получает транш, а инвесторы могут забрать оставшиеся средства
     * пропорционально вложениям.
     * @param _project Проект.
     **/
    function voteForCashBack(address _project) public {
        IdeaProject(_project).voteForCashBack(msg.sender);
    }

    /**
     * @notice Отменить голос за возврат средст.
     * Смотри подробности в описании метода 'voteForCashBack'.
     * @param _project Проект.
     **/
    function cancelVoteForCashBack(address _project) public {
        IdeaProject(_project).cancelVoteForCashBack(msg.sender);
    }

    /**
     * @notice Аналог метода 'voteForCashBack', но позволяющий
     * голосовать не всем весом. Подобное может использоваться для
     * фондов, хранящих средства нескольких клиентов.
     * Вызов этого метода повторно с другим значением процента
     * редактирует вес голоса, установка значения на 0 эквивалентна
     * вызову метода 'cancelVoteForCashBack'.
     * @param _project Проект.
     * @param _percent Необходимый процент от 0 до 100.
     **/
    function voteForCashBackInPercentOfWeight(address _project, uint8 _percent) public {
        IdeaProject(_project).voteForCashBackInPercentOfWeight(msg.sender);
    }

    // TODO Разрешать вызов кешбека и виздрава только в случае соответствующих состояний проекта

    /**
     * @notice Вывести средства, полученные на текущий этап работы.
     * Средства поступят на счет владельца проекта.
     * @param _project Проект.
     **/
    function withdrawFromProject(address _project) public onlyProjectOwner(_project) {
        require(
            state == States.Funding ||
            state == States.Workflow ||
            state == States.SuccessDone
        );

        if (state == States.Funding) {
            // TODO State to workflow or funding fail
        }

        if (state == States.Workflow || state == States.SuccessDone) {
            // TODO
        }
    }

    /**
     * @notice Вывести средства назад в случае провала проекта.
     * Если проект был провален на одном из этапов - средства вернуться
     * в соответствии с оставшимся процентом.
     * @param _project Проект.
     **/
    function cashBackFromProject(address _project) public {
        require(
                state == States.Funding ||
                state == States.Workflow ||
                state == States.FundingFail ||
                state == States.WorkFail
        );

        if (state == States.Funding || state == States.Workflow) {
            // TODO State to funding fail or work fail
        }

        if (state == States.FundingFail) {
            // TODO
        }

        if (state == States.WorkFail) {
            // TODO
        }
    }

    // ===                                    ===
    // === CONTROL PRODUCT (SUB-COIN) SECTION ===
    // ===                                    ===

    /**
     * @notice Увеличение максимального лимита количества продуктов, доступных к продаже.
     * @param _product Продукт.
     * @param _amount Колчество, на которое необходимо увеличить лимит.
     **/
    function incProductLimit(address _product, uint _amount) public onlyProductOwner(_product) {
        IdeaProject(
            IdeaSubCoin(_product).project()
        ).incProductLimit(_product, _amount);
    }

    /**
     * @notice Уменьшение максимального лимита количества продуктов, доступных к продаже.
     * @param _product Продукт.
     * @param _amount Количество, на которое необходимо уменьшить лимит.
     **/
    function decProductLimit(address _product, uint _amount) public onlyProductOwner(_product) {
        IdeaProject(
            IdeaSubCoin(_product).project()
        ).decProductLimit(_product, _amount);
    }

    /**
     * @notice Делает количество продуктов безлимитным.
     * @param _product Продукт.
     **/
    function makeProductUnlimited(address _product) public onlyProductOwner(_product) {
        IdeaProject(
            IdeaSubCoin(_product).project()
        ).makeProductUnlimited(_product);
    }

    /**
     * @notice Производит покупку токенов продукта.
     * @param _product Продукт.
     * @param _amount Количество токенов.
     **/
    function buyProduct(address _product, uint _amount) public {
        IdeaSubCoin coin = IdeaSubCoin(_product);
        IdeaProject project = coin.project();
        uint newBalance = balances[msg.sender].sub(_amount * coin.price());

        project.buyProduct(_product, msg.sender, _amount);
        balances[msg.sender] = newBalance();
    }

    /**
     * @notice Устанавливает адрес физической доставки товара.
     * @param _product Продукт.
     * @param _shipping Адрес физической доставки.
     **/
    function setProductShipping(address _product, string _shipping) public {
        IdeaProject(
            IdeaSubCoin(_product).project()
        ).setProductShipping(_product, msg.sender, _shipping);
    }

}