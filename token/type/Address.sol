pragma solidity ^0.4.16;

/**
 * @notice Расширение типа address.
 **/
library IdeaAddress {

    /**
     * @notice Запрещаем адресу быть нулевым.
     * @param _target Исходный адрес.
     **/
    function denyZero(address _target) constant internal {
        require(_target != address(0));
    }
}