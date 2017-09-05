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
        Done,

        // Проект не собрал необходимые инвестиции и деньги вернулись инвесторам
        Fail,

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
        string name;
        string description;
        uint percent;
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
}