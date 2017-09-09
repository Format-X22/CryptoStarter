pragma solidity ^0.4.16;

import './lib/IdeaTypeBind.sol';

/**
 * @notice Контракт краудфайндинг-проекта.
 **/
contract IdeaProject is IdeaTypeBind {

    /**
     * @notice Имя проекта.
     **/
    string public name;

    /**
     * @notice Описание проекта.
     **/
    string public description;

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
     * @notice Минимальное разрешенное количество дней сбора инвестиций.
     **/
    uint8 constant public minRequiredDays = 10;

    /**
     * @notice Максимальное разрешенное количество дней сбора инвестиций.
     **/
    uint8 constant public maxRequiredDays = 100;

    /**
     * @notice Время окончания сбора инвестиций.
     **/
    uint public fundingEndTime;

    /**
     * @notice Количество собранных инвестиций.
     **/
    uint public earned;

    /**
     * @notice Сумма, доступная для вывода в рамках текущего этапа работы.
     * В случае если прошлый транш не был выведен - суммируется с предыдущим.
     **/
    uint public tranche;

    /**
     * @notice Остаток, образовавшийся в процессе деления не нацело суммы транша.
     * Будет суммирован с траншем последнего этапа.
     **/
    uint public trancheRemainder;

    /**
     * @notice Баланс каждого инвестора, необходим для определения кешбека
     * в случае провала проекта.
     **/
    mapping(address => uint) public investorBalance;

    /**
     * @notice Список продуктов проекта.
     **/
    address[] public products;

    /**
     * @notice Соответствие имени продукта адресу продукта.
     **/
    mapping(string => address) public productsByName;

    /**
     * @notice Максимальное разрешенное количество продуктов у одного проекта.
     **/
    uint8 constant maxProducts = 25;

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
     * @notice Структура этапа работ.
     **/
    struct WorkStage {
        string name;        // Имя этапа.
        string description; // Описание этапа.
        uint8 percent;      // Процент средств от общего бюджета.
        uint8 stageDays;    // Количество дней выполнения этапа.
    }

    /**
     * @notice Список этапов работ.
     **/
    WorkStage[] public workStages;

    /**
     * @notice Номер текущего этапа работ.
     **/
    uint8 public workStage;

    /**
     * @notice Максимальное разрешенное количество этапов работ.
     **/
    uint8 constant public maxWorkStages = 10;

    /**
     * @notice Минимальное разрешенное количество времени на выполнение этапа.
     **/
    uint8 constant public minWorkStageDays = 10;

    /**
     * @notice Максимальное разрешенное количество времени на выполнение этапа
     * (для указания в описании этапа, время может быть продлено голосованием).
     **/
    uint8 constant public maxWorkStageDays = 100;

    /**
     * @notice Текущее количество процентов всех этапов.
     **/
    uint public currentWorkStagePercent;

    /**
     * @notice Состояние проекта изменено.
     * Смена состояния происходит не мгновенно по причине особенностей
     * работы Ethereum, однако это не влияет на логику работы контракта.
     * @param state Состояние.
     **/
    event StateChanged(States indexed state);

    /**
     * @notice Проект помечен как скоро стартующий.
     **/
    event ProjectIsComing();

    /**
     * @notice Проект начал собирать инвестиции.
     * @param time Время завершения сбора инвестиций в виде UNIX-таймштампа.
     **/
    event StartFunding(uint indexed time);

    /**
     * @notice Проект успешно завершен.
     **/
    event ProjectSuccessDone();

    /**
     * @notice Конструктор.
     * @param _owner Владелец проекта.
     * @param _name Имя проекта.
     * @param _description Описание проекта.
     * @param _required Необходимое количество инвестиций в IDEA.
     * @param _requiredDays Количество дней сбора инвестиций.
     * Должно быть в диапазоне от `minRequiredDays` до `maxRequiredDays`.
     **/
    function IdeaProject(
        address _owner,
        string _name,
        string _description,
        uint _required,
        uint _requiredDays
    ) {
        _owner.denyZero();
        _name.denyEmpty();
        _description.denyEmpty();
        _required.denyZero();

        require(_requiredDays >= minRequiredDays);
        require(_requiredDays <= maxRequiredDays);

        engine = msg.sender;
        owner = _owner;
        name = _name;
        description = _description;
        required = _required;
        requiredDays = _requiredDays;
    }

    // Отключаем возможность пересылать эфир на адрес контракта.
    function() payable {
        revert();
    }

    /**
     * @notice Разрешаем исполнять метод только в указанном состоянии.
     * @param _state Состояние.
     **/
    modifier onlyState(States _state) {
        require(state == _state);
        _;
    }

    /**
     * @notice Ограничивает возможность исполнения метода только контрактом-движком.
     * @param _state Состояние.
     **/
    modifier onlyEngine() {
        require(msg.sender == engine);
        _;
    }

    /**
     * @notice Установка имени проекта.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _name
     **/
    function setName(string _name) public onlyState(States.Initial) onlyEngine {
        _name.denyEmpty();

        name = _name;
    }

    /**
     * @notice Установка описания проекта.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _description
     **/
    function setDescription(string _description) public onlyState(States.Initial) onlyEngine {
        _description.denyEmpty();

        description = _description;
    }

    /**
     * @notice Установка значения неоходимых инвестиций.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _required
     **/
    function setRequired(uint _required) public onlyState(States.Initial) onlyEngine {
        _required.denyZero();

        required = _required;
    }

    /**
     * @notice Установка значения времени сбора средств.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _days
     **/
    function setRequiredDays(uint _requiredDays) public onlyState(States.Initial) onlyEngine {
        _requiredDays.denyZero();

        requiredDays = _requiredDays;
    }

    /**
     * @notice Создания продукта, предлагаемого проектом.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _name Имя продукта.
     * @param _symbol Символ продукта.
     * @param _description Описание продукта.
     * @param _price Цена продукта в IDEA токенах.
     * @param _limit Лимит количества продуктов, 0 установит безлимитный режим.
     * @return _productAddress Адрес экземпляра контракта продукта.
     **/
    function makeProduct(
        string _name,
        string _symbol,
        string _description,
        uint _price,
        uint _limit
    ) onlyState(States.Initial) public onlyEngine returns (address _productAddress) {
        require(products.length <= maxProducts);

        IdeaSubCoin product = new IdeaSubCoin(this, _name, _symbol, _description, _price, _limit);

        products.push(product);
        productsByName[_name] = address(product);

        return address(product);
    }

    /**
     * @notice Получение адреса продукта по имени продукта.
     * @param _name Имя продукта.
     * @return _address Адрес продукта, в случае отсутствия будет возвращен нулевой адрес.
     **/
    function getProductAddressByName(string _name) constant public onlyEngine returns (address _address) {
        return productsByName[_name];
    }

    /**
     * @notice Получение всех имен продуктов. Результатом вычислений будет строка
     * из склеенных имен продуктов, разделенных разделителем в виде вертикальной черы '|'.
     * @return _stringWithSplitter Результат.
     **/
    function getAllProductsNames() constant public onlyEngine returns (string _stringWithSplitter) {
        string _stringWithSplitter;

        for (uint i = 0; i < products.length; i += 1) {
            _stringWithSplitter += products[i].name() + '|';
        }

        _stringWithSplitter += products[products.length - 1].name();
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
     * @notice Создать этап работы.
     * Суммарно должно быть не более 10 этапов (`maxWorkStages`),
     * а также сумма процентов всех этапов должна быть равна 100%.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _name Имя этапа.
     * @param _description Описание этапа.
     * @param _percent Процент средств от общего бюджета.
     * @param _stageDays Количество дней выполнения этапа.
     * Количество должно быть не менее 10 и не более 100 дней.
     **/
    function makeWorkStage(
        string _name,
        string _description,
        uint8 _percent,
        uint8 _stageDays
    ) public onlyState(States.Initial) {
        require(workStages.length <= maxWorkStages);
        _name.denyEmpty();
        _description.denyEmpty();
        require(_stageDays >= minWorkStageDays);
        require(_stageDays <= maxWorkStageDays);
    
        if (currentWorkStagePercent.add(_stageDays) > 100) {
            revert();
        } else {
            currentWorkStagePercent = currentWorkStagePercent.add(_stageDays);
        }

        workStages.push(Stage(
            _name,
            _description,
            _percent,
            _stageDays
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
     * @notice Перевести проект в состояние 'Coming'
     * и заблокировать возможность внесения изменений.
     **/
    function markAsComingAndFreeze() public onlyState(States.Initial) onlyEngine {
        require(products.length > 0);
        require(currentWorkStagePercent == 100);

        state = States.Coming;
    
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
    
        StartFunding(now);
    }

    /**
     * @notice Пометить текущий этап работ как выполненый.
     * Это запустит очередной этап голосования за выдачу следующего
     * транша средств для реализации следующего этапа работ.
     * В случае если это последний этап - будет вызван метод 'projectDone'.
     **/
    function stageDone() public onlyState(States.Workflow) onlyEngine {
        // TODO
    }

    /**
     * @notice Пометить проект как завершенный. Проект должен находится
     * на последнем этапе работ. Также это означает что стартует доставка
     * готовой продукции.
     **/
    function projectDone() public onlyState(States.Workflow) onlyEngine {
        require(workStage == workStages.length - 1);

        ProjectSuccessDone();

        state = States.SuccessDone;
    }

    /**
     * @notice Вывести средства, полученные на текущий этап работы.
     * Средства поступят на счет владельца проекта.
     **/
    function withdraw() public onlyEngine {
        require(
            state == States.Funding ||
            state == States.Workflow ||
            state == States.SuccessDone
        );

        if (state == States.Funding) {
            // TODO State to workflow or funding fail
        }

        // TODO
    }

    /**
     * @notice Вывести средства назад в случае провала проекта.
     * Если проект был провален на одном из этапов - средства вернуться
     * в соответствии с оставшимся процентом.
     **/
    function cashBack() public onlyEngine {
        require(
            state == States.Funding ||
            state == States.Workflow ||
            state == States.FundingFail ||
            state == States.WorkFail
        );

        if (state == States.Funding || state == States.Workflow) {
            // TODO State to funding fail or work fail
        }

        // TODO
    }

    // TODO Voting for stage done and more time for stage
}