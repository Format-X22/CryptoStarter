pragma solidity ^0.4.16;

import './lib/IdeaTypeBind.sol';
import './IdeaProjectVoting.sol';
import './IdeaProjectProducts.sol';
import './IdeaProjectStates.sol';
import './IdeaProjectWorkStages.sol';

/**
 * @notice Контракт краудфайндинг-проекта.
 **/
contract IdeaProject is
    IdeaProjectProducts,
    IdeaProjectStates,
    IdeaProjectWorkStages,
    IdeaProjectVoting,
    IdeaTypeBind
{

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
}