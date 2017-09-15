pragma solidity ^0.4.16;

import './type/TypeBind.sol';
import './SubCoin.sol';

/**
 * @notice Контракт краудфайндинг-проекта.
 **/
contract IdeaProject is IdeaTypeBind {

    /**
     * @notice Имя проекта.
     **/
    string public name;

    /**
     * @notice Адрес движка-инициатора.
     **/
    address public engine;

    /**
     * @notice Аккаунт владельца.
     **/
    address public owner;

    /**
     * @notice Количество необходимых инвестиций.
     **/
    uint public required;

    /**
     * @notice Количество дней сбора инвестиций.
     **/
    uint public requiredDays;


    /**
     * @notice Время окончания сбора инвестиций.
     **/
    uint public fundingEndTime;

    /**
     * @notice Количество собранных инвестиций.
     **/
    uint public earned;

    /**
     * @notice Соответствие аккаунта и факта того что деньги были возвращены.
     **/
    mapping(address => bool) public isCashBack;

    /**
     * @notice Количество собранных инвестиций увеличено.
     * Вызывается в момент покупки любого из продуктов проекта.
     * @param _idea Количество токенов в размерности WEI.
     **/
    event EarnIncreased(uint _idea);

    /**
     * @notice Конструктор.
     * @param _owner Владелец проекта.
     * @param _name Имя проекта.
     * @param _required Необходимое количество инвестиций в IDEA в размерности WEI.
     * @param _requiredDays Количество дней сбора инвестиций.
     * Должно быть в диапазоне от `minRequiredDays` до `maxRequiredDays`.
     **/
    function IdeaProject(
        address _owner,
        string _name,
        uint _required,
        uint _requiredDays
    ) {
        _owner.denyZero();
        _name.denyEmpty();
        _required.denyZero();

        require(_requiredDays >= minRequiredDays);
        require(_requiredDays <= maxRequiredDays);

        engine = msg.sender;
        owner = _owner;
        name = _name;
        required = _required;
        requiredDays = _requiredDays;
    }

    // Отключаем возможность пересылать эфир на адрес контракта.
    function() payable {
        revert();
    }

    /**
     * @notice Ограничивает возможность исполнения метода только контрактом-движком.
     **/
    modifier onlyEngine() {
        require(msg.sender == engine);
        _;
    }

    /**
     * @notice Установка имени проекта.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _name Новое имя.
     **/
    function setName(string _name) public onlyState(States.Initial) onlyEngine {
        _name.denyEmpty();

        name = _name;
    }

    /**
     * @notice Установка значения неоходимых инвестиций.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _required Значение.
     **/
    function setRequired(uint _required) public onlyState(States.Initial) onlyEngine {
        _required.denyZero();

        required = _required;
    }

    /**
     * @notice Установка значения времени сбора средств.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _requiredDays Количество дней.
     **/
    function setRequiredDays(uint _requiredDays) public onlyState(States.Initial) onlyEngine {
        _requiredDays.denyZero();

        requiredDays = _requiredDays;
    }

    // ===                ===
    // === STATES SECTION ===
    // ===                ===

    /**
     * @notice Варианты состояния проекта.
     **/
    enum States {

        // Изначальное состояние, проект ещё не активен,
        // проект может менять свои свойства, покупать продукты ещё нельзя.
        Initial,

        // Проект помечен как предстоящий, настройки проекта заморожены.
        Coming,

        // Проект в состоянии сбора инвестиций, переход на
        // следующее состояние автоматически по завершению указанного
        // количества дней (смотри 'requiredDays').
        Funding,

        // Проект собрал необходимые инвестиции и находится в процессе работы,
        // автор проекта получил деньги для реализации первого проекта и начал
        // реализовывать проект этап за этапом, получая соответствующие инвестиции,
        // инвесторы в праве голосовать за каждый следующий этап или возврат средств
        // (смотри также 'WorkStages').
        Workflow,

        // Проект завершен, в момент установки состояния замораживается список доставки
        // и владельцы находятся в ожидании получения готовой продукции.
        SuccessDone,

        // Проект не собрал необходимые инвестиции и деньги вернулись инвесторам
        FundingFail,

        // На одном из этапов проект был оценен инвесторами как провальный,
        // инвесторы получили оставшиеся деньги назад, проект закрылся
        WorkFail
    }

    /**
     * @notice Текущее состояние проекта.
     * Смена состояния происходит не мгновенно по причине особенностей
     * работы Ethereum, однако это не влияет на логику работы контракта.
     **/
    States public state = States.Initial;

    /**
     * @notice Проект помечен как скоро стартующий.
     **/
    event ProjectIsComing();

    /**
     * @notice Проект начал собирать инвестиции.
     * @param _end Время завершения сбора инвестиций в виде UNIX-таймштампа.
     **/
    event StartFunding(uint _end);

    /**
     * @notice Начата работа по реализации проекта.
     **/
    event StartWork();

    /**
     * @notice Проект успешно завершен.
     **/
    event ProjectSuccessDone();

    /**
     * @notice Проект провален на этапе сбора средств.
     * Эвент вызывается с запозданием относительно фактического события.
     **/
    event ProjectFundingFail();

    /**
     * @notice Проект провален на одном из этапов работы по реализации проекта.
     * Эвент вызывается с запозданием относительно фактического события.
     * @param _stage Номер этапа, на котором проект провалился.
     **/
    event ProjectWorkFail(uint8 _stage);

    /**
     * @notice Разрешаем исполнять метод только в указанном состоянии.
     * @param _state Состояние.
     **/
    modifier onlyState(States _state) {
        require(state == _state);
        _;
    }

    /**
     * @notice Находится ли проект в начально состоянии.
     * @param _result Результат проверки.
     **/
    function isInitialState() constant public returns (bool _result) {
        return state == States.Initial;
    }

    /**
     * @notice Находится ли проект в состоянии ожидания старта.
     * @param _result Результат проверки.
     **/
    function isComingState() constant public returns (bool _result) {
        return state == States.Coming;
    }

    /**
     * @notice Находится ли проект в состоянии сбора средств.
     * @param _result Результат проверки.
     **/
    function isFundingState() constant public returns (bool _result) {
        return state == States.Funding;
    }

    /**
     * @notice Находится ли проект в состоянии работы по реализации проекта.
     * @param _result Результат проверки.
     **/
    function isWorkflowState() constant public returns (bool _result) {
        return state == States.Workflow;
    }

    /**
     * @notice Находится ли проект в состоянии успешного завершения.
     * @param _result Результат проверки.
     **/
    function isSuccessDoneState() constant public returns (bool _result) {
        return state == States.SuccessDone;
    }

    /**
     * @notice Находится ли проект в состоянии не успешного сбора средств.
     * @param _result Результат проверки.
     **/
    function isFundingFailState() constant public returns (bool _result) {
        return state == States.FundingFail;
    }

    /**
     * @notice Находится ли проект в состоянии не успешной реализации.
     * @param _result Результат проверки.
     **/
    function isWorkFailState() constant public returns (bool _result) {
        return state == States.WorkFail;
    }

    /**
     * @notice Перевести проект в состояние 'Coming'
     * и заблокировать возможность внесения изменений.
     **/
    function markAsComingAndFreeze() public onlyState(States.Initial) onlyEngine {
        require(products.length > 0);
        require(currentWorkStagePercent == 100);

        uint raw;
        uint reserve;
        uint reserveTotal;

        state = States.Coming;

        for (uint8 i; i < workStages.length; i += 1) {
            raw = required.mul(workStages[i].percent);
            reserve = raw % 100;
            reserveTotal = reserveTotal.add(reserve);

            workStages[i].sum = raw.sub(reserve).div(100);
        }
    
        workStages[workStages.length - 1].sum = workStages[workStages.length - 1].sum.add(reserveTotal);

        ProjectIsComing();
    }

    /**
     * @notice Запустить сбор средств.
     * Остановить сбор будет нельзя. При успешном сборе проект перейдет
     * в состояние начала работ и будут начислены средства за первый этап.
     * В случае не сбора средств за необходимое время - проект будет закрыт,
     * а средства вернуться на счета инвесторов.
     **/
    function startFunding() public onlyState(States.Coming) onlyEngine {
        state = States.Funding;

        fundingEndTime = now + requiredDays * 1 days;
        calcLastWorkStageStart();

        StartFunding(fundingEndTime);
    }

    /**
     * @notice Установить состояние проекта на факт начала работ по его реализации.
     **/
    function projectWorkStarted() public onlyState(States.Funding) onlyEngine {
        state = States.Workflow;

        StartWork();
    }

    /**
     * @notice Пометить проект как завершенный. Проект должен находится
     * на последнем этапе работ. Также это означает что стартует доставка
     * готовой продукции.
     **/
    function projectDone() public onlyState(States.Workflow) onlyEngine {
        require(now > lastWorkStageStartTimestamp);

        ProjectSuccessDone();

        state = States.SuccessDone;
    }

    /**
     * @notice Пометить проект как провалившийся на этапе сбора средств.
     **/
    function projectFundingFail() public onlyState(States.Funding) onlyEngine {
        state = States.FundingFail;

        ProjectFundingFail();
    }

    /**
     * @notice Пометить проект как провалившийся на этапе работы над реализацией проекта.
     **/
    function projectWorkFail() internal {
        uint failTime = fundingEndTime;

        state = States.WorkFail;

        for (uint8 i; i < workStages.length; i += 1) {
            failTime = failTime.add(workStages[i].stageDays * 1 days);
            failInvestPercents = failInvestPercents.add(workStages[i].percent);

            if (failTime > now) {
                failStage = int8(i);
            }
        }

        ProjectWorkFail(uint8(failStage));
    }

    // ===                     ===
    // === WORK STAGES SECTION ===
    // ===                     ===

    /**
     * @notice Структура этапа работ.
     **/
    struct WorkStage {
        string name;        // Имя этапа.
        uint8 percent;      // Процент средств от общего бюджета.
        uint8 stageDays;    // Количество дней выполнения этапа.
        uint sum;           /* Сумма, доступная для вывода с момента
                               начала этапа в случае если проект
                               не был признан провалившимся. */
    }

    /**
     * @notice Список этапов работ.
     **/
    WorkStage[] public workStages;



    /**
     * @notice Текущее количество процентов всех этапов.
     **/
    uint public currentWorkStagePercent;

    /**
     * @notice Время старта последнего этапа работ.
     **/
    uint internal lastWorkStageStartTimestamp;

    /**
     * @notice Этап работ, который провалился, отсчет с 0.
     * Значение -1 указывает на отсутствие такого этапа.
     **/
    int8 failStage = -1;

    /**
     * @notice Количество потерянны инвестиций в процентах.
     **/
    uint failInvestPercents;

    /**
     * @notice Создать этап работы.
     * Суммарно должно быть не более 10 этапов (`maxWorkStages`),
     * а также сумма процентов всех этапов должна быть равна 100%.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _name Имя этапа.
     * @param _percent Процент средств от общего бюджета.
     * @param _stageDays Количество дней выполнения этапа.
     * Количество должно быть не менее 10 и не более 100 дней.
     **/
    function makeWorkStage(
        string _name,
        uint8 _percent,
        uint8 _stageDays
    ) public onlyState(States.Initial) {
        require(workStages.length <= maxWorkStages);
        _name.denyEmpty();
        require(_stageDays >= minWorkStageDays);
        require(_stageDays <= maxWorkStageDays);

        if (currentWorkStagePercent.add(_stageDays) > 100) {
            revert();
        } else {
            currentWorkStagePercent = currentWorkStagePercent.add(_stageDays);
        }

        workStages.push(WorkStage(
            _name,
            _percent,
            _stageDays,
            0
        ));
    }

    /**
     * @notice Уничтожить последний созданный этап.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     **/
    function destroyLastWorkStage() public onlyState(States.Initial) onlyEngine {
        require(workStages.length > 0);

        uint8 lastPercent = workStages[workStages.length - 1].percent;

        currentWorkStagePercent = currentWorkStagePercent.sub(lastPercent);
        workStages.length = workStages.length - 1;
    }

    /**
     * @notice Уничтожить все этапы.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     **/
    function destroyAllWorkStages() public onlyState(States.Initial) onlyEngine {
        currentWorkStagePercent = 0;
        delete workStages;
    }

    /**
     * @notice Вычисление начала последнего этапа работ.
     **/
    function calcLastWorkStageStart() internal {
        lastWorkStageStartTimestamp = fundingEndTime;

        // (length - 1) not a bug
        for (uint8 i; i < workStages.length - 1; i += 1) {
            lastWorkStageStartTimestamp += workStages[i].stageDays * 1 days;
        }
    }

    /**
     * @notice Вывести средства за указанный этап работ.
     * @param _stage Этап.
     * @return _sum Количество.
     **/
    function withdraw(uint8 _stage) public onlyEngine returns (uint _sum) {
        _sum = workStages[_stage].sum;

        workStages[_stage].sum = 0;
    }

    // ===                  ===
    // === PRODUCTS SECTION ===
    // ===                  ===

    /**
     * @notice Список продуктов проекта.
     **/
    address[] public products;

    /**
     * @notice Соотношение адреса продукта к идентификатору списка 'products'.
     **/
    mapping(address => uint8) public productsIdByAddress;



    /**
     * @notice Разрешить действие только от котракта продукта, принадлежащего этому проекту.
     **/
    modifier onlyProduct() {
        bool permissionGranted;

        for (uint8 i; i < products.length; i += 1) {
            if (msg.sender == products[i]) {
                permissionGranted = true;
            }
        }

        if (permissionGranted) {
            _;
        } else {
            revert();
        }
    }

    /**
     * @notice Создания продукта, предлагаемого проектом.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _name Имя продукта.
     * @param _symbol Символ продукта.
     * @param _price Цена продукта в IDEA токенах в размерности WEI.
     * @param _limit Лимит количества продуктов, 0 установит безлимитный режим.
     * @return _productAddress Адрес экземпляра контракта продукта.
     **/
    function makeProduct(
        string _name,
        string _symbol,
        uint _price,
        uint _limit
    ) public onlyState(States.Initial) onlyEngine returns (address _productAddress) {
        require(products.length <= maxProducts);

        IdeaSubCoin product = new IdeaSubCoin(this, _name, _symbol, _price, _limit);

        products.push(address(product));
        productsIdByAddress[address(product)] = uint8(products.length - 1);

        return address(product);
    }

    /**
     * @notice Получение всех адресов продуктов.
     * @return _result Результат.
     **/
    function getAllProductsAddresses() constant public onlyEngine returns (address[] _result) {
        return products;
    }

    /**
     * @notice Уничтожить последний созданный продукт.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     **/
    function destroyLastProduct() public onlyState(States.Initial) onlyEngine {
        require(products.length > 0);

        IdeaSubCoin(products[products.length - 1]).destroy();

        products.length = products.length - 1;
    }

    /**
     * @notice Уничтожить все продукты.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     **/
    function destroyAllProducts() public onlyState(States.Initial) onlyEngine {
        for (uint8 i = 0; i < products.length; i += 1) {
            IdeaSubCoin(products[i]).destroy();
        }

        delete products;
    }

    /**
     * @notice Вычисление неизрасходованных инвестиций, принидлежащих аккаунту.
     * @param _account Аккаунт.
     * @return _sum Сумма.
     **/
    function calcInvesting(address _account) public onlyEngine returns (uint _sum) {
        require(!isCashBack[_account]);

        for (uint8 i = 0; i < products.length; i += 1) {
            IdeaSubCoin product = IdeaSubCoin(products[i]);

            _sum = _sum.add(product.balanceOf(_account) * product.price());
        }

        if (isWorkFailState()) {
            _sum = _sum.mul(100 - failInvestPercents).div(100);
        }

        isCashBack[_account] = true;
    }

    // ===                ===
    // === VOTING SECTION ===
    // ===                ===

    /**
     * @notice Процент голосов отданных за возврат денег инветорам.
     * Значение хранится в виде числа процентов, возведенных в 10 степень,
     * то есть число 10000000000 соответствует 1% головов за возврат средств.
     * Смотри также метод 'voteForCashBack'.
     **/
    uint public cashBackVotes;

    /**
     * @notice Соответствие процента веса голоса аккаунту инвестора.
     * В обычном случае это будет 0 или 100, в некоторох других - смотри
     * метод 'voteForCashBackInPercentOfWeight'.
     **/
    mapping(address => uint8) public cashBackWeight;

    /**
     * @notice Отдать голос за прекращение проекта и возврат средств.
     * Голосовать можно в любой момент, также можно отменить голос воспользовавшись
     * методом 'cancelVoteForCashBack'. Вес голоса зависит от количества вложенных средств.
     * Перед началом нового этапа работ и выдачей очередного транша создателю проекта -
     * происходит проверка на голоса за возврат. Если голосов, с учетом их веса, суммарно
     * оказалось больше 50% общего веса голосов - проект помечается как провальный,
     * владелец проекта не получает транш, а инвесторы могут забрать оставшиеся средства
     * пропорционально вложениям.
     * @param _account Аккаунт.
     **/
    function voteForCashBack(address _account) public onlyState(States.Workflow) onlyEngine {
        voteForCashBackInPercentOfWeight(_account, 100);
    }

    /**
     * @notice Отменить голос за возврат средст.
     * Смотри подробности в описании метода 'voteForCashBack'.
     * @param _account Аккаунт.
     **/
    function cancelVoteForCashBack(address _account) public onlyState(States.Workflow) onlyEngine {
        voteForCashBackInPercentOfWeight(_account, 0);
    }

    /**
     * @notice Аналог метода 'voteForCashBack', но позволяющий
     * голосовать не всем весом. Подобное может использоваться для
     * фондов, хранящих средства нескольких клиентов.
     * Вызов этого метода повторно с другим значением процента
     * редактирует вес голоса, установка значения на 0 эквивалентна
     * вызову метода 'cancelVoteForCashBack'.
     * @param _account Аккаунт.
     * @param _percent Необходимый процент от 0 до 100.
     **/
    function voteForCashBackInPercentOfWeight(
        address _account,
        uint8 _percent
    ) public onlyState(States.Workflow) onlyEngine {

        uint8 currentWeight = cashBackWeight[_account];
        uint supply;
        uint part;

        for (uint8 i; i < products.length; i += 1) {
            supply += IdeaSubCoin(products[i]).totalSupply();
            part += IdeaSubCoin(products[i]).balanceOf(_account);
        }

        cashBackVotes += ((part ** 10) / supply) * (_percent - currentWeight);
        cashBackWeight[_account] = _percent;

        if (cashBackVotes > 50 ** 10) {
            projectWorkFail();
        }
    }

    /**
     * @notice Корректирует значения голосов за возвврат средств при переводе
     * монет в одном из продуктов проекта.
     * Смотри также 'voteForCashBack'.
     * @param _from Отправитель.
     * @param _to Получатель.
     **/
    function updateVotesOnTransfer(address _from, address _to) public onlyProduct {
        if (isWorkflowState()) {
            voteForCashBackInPercentOfWeight(_from, cashBackWeight[_from]);
            voteForCashBackInPercentOfWeight(_to, cashBackWeight[_to]);
        }
    }

    // ===                         ===
    // === CONTROL PRODUCT SECTION ===
    // ===                         ===

    /**
     * @notice Увеличение максимального лимита количества продуктов, доступных к продаже.
     * @param _product Продукт.
     * @param _amount Колчество, на которое необходимо увеличить лимит.
     **/
    function incProductLimit(
        address _product,
        uint _amount
    ) public onlyState(States.Initial) onlyProduct onlyEngine {
        IdeaSubCoin(_product).incLimit(_amount);
    }

    /**
     * @notice Уменьшение максимального лимита количества продуктов, доступных к продаже.
     * @param _product Продукт.
     * @param _amount Количество, на которое необходимо уменьшить лимит.
     **/
    function decProductLimit(
        address _product,
        uint _amount
    ) public onlyState(States.Initial) onlyProduct onlyEngine {
        IdeaSubCoin(_product).decLimit(_amount);
    }

    /**
     * @notice Делает количество продуктов безлимитным.
     * @param _product Продукт.
     **/
    function makeProductUnlimited(
        address _product
    ) public onlyState(States.Initial) onlyProduct onlyEngine {
        IdeaSubCoin(_product).makeUnlimited();
    }

    /**
     * @notice Производит покупку токенов продукта.
     * @param _product Продукт.
     * @param _account Аккаунт покупателя.
     * @param _amount Количество токенов.
     **/
    function buyProduct(
        address _product,
        address _account,
        uint _amount
    ) public onlyState(States.Funding) onlyProduct onlyEngine {
        IdeaSubCoin coin = IdeaSubCoin(_product);
        uint idea = _amount * coin.price();

        coin.buy(_account, _amount);
        earned.add(idea);

        EarnIncreased(idea);
    }

    /**
     * @notice Устанавливает адрес физической доставки товара.
     * @param _product Продукт.
     * @param _account Аккаунт покупателя.
     * @param _shipping Адрес физической доставки.
     **/
    function setProductShipping(
        address _product,
        address _account,
        string _shipping
    ) public onlyProduct onlyEngine {
        IdeaSubCoin(_product).setShipping(_account, _shipping);
    }

}