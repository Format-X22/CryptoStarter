pragma solidity ^0.4.16;

contract IdeaProjectWorkStage {

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

}