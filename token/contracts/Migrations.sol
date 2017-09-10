pragma solidity ^0.4.15;

/**
 * @notice Контракт миграции, совместимый с Truffle.
 **/
contract Migrations {

    /**
     * @notice Владелец контракта.
     **/
    address public owner;

    /**
     * @notice Идентификатор последней миграции.
     **/
    uint public last_completed_migration;

    /**
     * @notice Конструктор.
     **/
    function Migrations() {
        owner = msg.sender;
    }

    // Отключаем возможность пересылать эфир на адрес контракта.
    function() payable {
        revert();
    }

    /**
     * @notice Разрешить действие только владельцу контракта.
     **/
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @notice Пометить миграцию завершенной.
     **/
    function setCompleted(uint completed) onlyOwner {
        last_completed_migration = completed;
    }

    /**
     * @notice Запуск миграции.
     **/
    function upgrade(address new_address) onlyOwner {
        Migrations upgraded = Migrations(new_address);

        upgraded.setCompleted(last_completed_migration);
    }
}
