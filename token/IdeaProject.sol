pragma solidity ^0.4.16;

/**
 * @notice Контракт краудфайндинг-проекта.
 **/
contract IdeaProject {

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
     * @notice Количество собранных инвестиций.
     **/
    uint public earned;

    /**
     * @notice
     **/
    address[] public products;

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
     **/
    States public state = States.Initial;

    /**
     * @notice Структура этапа работ.
     **/
    struct WorkStage {
        string name;        // Имя этапа.
        string description; // Описание этапа.
        uint percent;       // Процент средств от общего бюджета.
        uint stageDays;     // Количество дней выполнения этапа.
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
     * @notice Состояние проекта изменено.
     * @param state Состояние.
     **/
    event StateChanged(States indexed state);

    /**
     * @notice Проект помечен как скоро стартующий.
     **/
    event ProjectIsComing();

    /**
     * @notice Проект начал собирать инвестиции.
     **/
    event StartFunding();

    /**
     * @notice Проект закончил собирать инвестиции.
     **/
    event EndFunding();

    /**
     * @notice Работа по проекту начата.
     **/
    event StartWork();

    /**
     * @notice Начат этап работ.
     * @param stage Номер этапа.
     **/
    event StartWorkStage(uint indexed stage);

    /**
     * @notice Закончен этап работ.
     * @param stage Номер этапа.
     **/
    event EndWorkStage(uint indexed stage);

    /**
     * @notice Начато голосование за следующий этап.
     * @param finishedStage Номер завершенного этапа.
     * @param nextStage Номер предстоящего этапа.
     **/
    event StartVoting(uint indexed finishedStage, uint indexed nextStage);

    /**
     * @notice Проект успешно завершен.
     **/
    event ProjectSuccessDone();

    /**
     * @notice Начата доставка.
     **/
    event ShippingStarted();

    /**
     * @notice Проект провален, не достаточное количество инвестиций.
     **/
    event FundingFail();

    /**
     * @notice Проект провален на этапе работы.
     * @param finishedStage Номер завершенного этапа.
     * @param notStartedStage Номер не состоявшегося этапа.
     **/
    event ProjectWorkFail(uint indexed finishedStage, uint indexed notStartedStage);

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
        require(state = _state);
        _;
    }

    /**
     * @notice Ограничивает возможность исполнения метода только контрактом-движком.
     * @param _state Состояние.
     **/
    modifier onlyEngine() {
        require(msg.sender = engine);
        _;
    }

    /**
     * @notice Установка имени проекта.
     * @param _name
     **/
    function setName(string _name) {
        // TODO
    }

    /**
     * @notice Установка описания проекта.
     * @param _description
     **/
    function setDescription(string _description) {
        // TODO
    }

    /**
     * @notice Установка значения неоходимых инвестиций.
     * @param _value
     **/
    function setRequired(uint _value) {
        // TODO
    }

    /**
     * @notice Установка значения времени сбора средств.
     * @param _days
     **/
    function setRequiredDays(uint _days) {
        // TODO
    }

    /**
     * @notice Создания продукта, предлагаемого проектом.
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
    ) returns (address _productAddress) {
        // TODO
    }

    /**
     * @notice Получение адреса продукта по имени продукта.
     * @param _name Имя продукта.
     * @return _address Адрес продукта.
     **/
    function getProductAddressByName(string _name) returns (address _address) {
        // TODO
    }

    /**
     * @notice Получение всех имен продуктов. Результатом вычислений будет строка
     * из склеенных имен продуктов, разделенных разделителем в виде вертикальной черы '|'.
     * @return _stringWithSplitter Результат.
     **/
    function getAllProductsNames() returns (string _stringWithSplitter) {
        // TODO
    }

    /**
     * @notice Уничтожить продукт.
     * @param _address Адрес продукта.
     **/
    function destroyProduct(address _address) {
        // TODO
    }

    /**
     * @notice Уничтожить продукт по имени.
     * @param _name Имя продукта.
     **/
    function destroyProductByName(string _name) {
        // TODO
    }

    /**
     * @notice Уничтожить все продукты.
     **/
    function destroyAllProducts() {
        // TODO
    }

    /**
     * @notice Создать этап работы.
     * Суммарно должно быть не более 10 этапов (`maxWorkStages`),
     * а также сумма процентов всех этапов должна быть равна 100%.
     * @param _name Имя этапа.
     * @param _description Описание этапа.
     * @param _percent Процент средств от общего бюджета.
     * @param _stageDays Количество дней выполнения этапа.
     **/
    function makeStage(
        string _name,
        string _description,
        uint _percent,
        uint _stageDays
    ) {
        // TODO
    }

    /**
     * @notice Уничтожить последний созданный этап.
     **/
    function destroyLastStage() {
        // TODO
    }

    /**
     * @notice Уничтожить все этапы.
     **/
    function destroyAllStages() {
        // TODO
    }

    /**
     * @notice Перевести проект в состояние 'Coming'
     * и заблокировать возможность внесения изменений.
     **/
    function markAsComingAndFreeze() {
        // TODO
    }

    /**
     * @notice Запустить сбор средств.
     **/
    function startFunding() {
        // TODO
    }

    /**
     * @notice Пометить текущий этап работ как выполненый.
     **/
    function stageDone() {
        // TODO
    }

    /**
     * @notice Пометить проект как завершенный.
     **/
    function projectDone() {
        // TODO
    }

    /**
     * @notice Вывести средства, полученные на текущий этап работы.
     * Средства поступят на счет владельца проекта.
     **/
    function withdraw() {
        // TODO
    }

    // TODO Voting for stage done and more time for stage
}