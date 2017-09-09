pragma solidity ^0.4.16;

/**
 * @notice Часть контракта краудфайндинг-проекта,
 * отвечающая за систему этапов работы.
 **/
contract IdeaWorkStages {

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
     * @notice Пометить текущий этап работ как выполненый.
     * Это запустит очередной этап голосования за выдачу следующего
     * транша средств для реализации следующего этапа работ.
     * В случае если это последний этап - будет вызван метод 'projectDone'.
     **/
    function stageDone() public onlyState(States.Workflow) onlyEngine {
        // TODO
    }

}