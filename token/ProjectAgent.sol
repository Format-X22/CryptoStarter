pragma solidity ^0.4.17;

import './Project.sol';
import './SubCoin.sol';

contract ProjectAgent {

    /**
     * @notice Владелец агента.
     **/
    address public owner;

    /**
     * @notice Монета агента.
     **/
    address public coin;

    /**
     * @notice Разрешить действие только владельцу агента.
     **/
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @notice Разрешить действие только монете агента.
     **/
    modifier onlyCoin() {
        require(msg.sender == coin);
        _;
    }

    /**
     * @notice Конструктор.
     **/
    function ProjectAgent() {
        owner = msg.sender;
    }

    /**
     * @notice Создание проекта в системе IdeaCoin.
     * @param _owner Владелец проекта.
     * @param _name Имя проекта.
     * @param _required Необходимое количество инвестиций в IDEA.
     * @param _requiredDays Количество дней сбора инвестиций.
     * Должно быть в диапазоне от 10 до 100.
     **/
    function makeProject(
        address _owner,
        string _name,
        uint _required,
        uint _requiredDays
    ) public returns (address _address) {
        return address(
            new IdeaProject(
                _owner,
                _name,
                _required,
                _requiredDays
            )
        );
    }

    /**
     * @notice Установка монеты агента.
     * @param _coin Монета агента.
     **/
    function setCoin(address _coin) public onlyOwner {
        coin = _coin;
    }

    /**
     * @notice Вывести средства, полученные на текущий этап работы.
     * Средства поступят на счет владельца проекта.
     * @param _owner Владелец проекта.
     * @param _project Проект.
     * @param _stage Этап.
     * @return _value Значение для вывода в случае успеха.
     **/
    function withdrawFromProject(
        address _owner,
        address _project,
        uint8 _stage
    ) public onlyCoin returns (bool _success, uint _value) {
        require(_owner == IdeaProject(_project).owner());

        IdeaProject project = IdeaProject(_project);
        uint sum;

        updateFundingStateIfNeed(_project);

        if (project.isWorkflowState() || project.isSuccessDoneState()) {
            sum = project.withdraw(_stage);

            if (sum > 0) {
                _value = sum;
                _success = true;
            } else {
                _success = false;
            }
        } else {
            _success = false;
        }
    }

    /**
     * @notice Вывести средства назад в случае провала проекта.
     * Если проект был провален на одном из этапов - средства вернуться
     * в соответствии с оставшимся процентом.
     * @param _owner Владелец проекта.
     * @param _project Проект.
     * @return _success Успешность запроса.
     * @return _value Значение для вывода в случае успеха.
     **/
    function cashBackFromProject(
        address _owner,
        address _project
    ) public onlyCoin returns (bool _success, uint _value) {
        IdeaProject project = IdeaProject(_project);

        updateFundingStateIfNeed(_project);

        if (
            project.isFundingFailState() ||
            project.isWorkFailState()
        ) {
            _value = project.calcInvesting(_owner);
            _success = true;
        } else {
            _success = false;
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

    /**
     * @notice Покупка указанного продукта для покупателя.
     * Покупка возможна только в случае если проект находится в состоянии сбора инвестиций.
     * @param _product Продукт.
     * @param _account Аккаунт.
     * @param _amount Количество.
     **/
    function buyProduct(address _product, address _account, uint _amount) public onlyCoin {
        IdeaSubCoin _productContract = IdeaSubCoin(_product);
        IdeaProject _projectContract = IdeaProject(_productContract.project());

        require(_projectContract.isFundingState());

        _productContract.buy(_account, _amount);
        _projectContract.addEarned(_amount * _productContract.price());
    }
}