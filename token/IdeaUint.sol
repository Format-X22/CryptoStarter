pragma solidity ^0.4.16;

/**
 * @notice Расширение типа uint.
 **/
library IdeaUint {

    /**
     * @notice Безопасное сложение.
     * @param Исходное число.
     * @param Модификатор.
     * @return Результат.
     **/
    function add(uint a, uint b) internal returns (uint result) {
        uint c = a + b;

        assert(c >= a);

        return c;
    }

    /**
     * @notice Безопасное вычитание.
     * @param Исходное число.
     * @param Модификатор.
     * @return Результат.
     **/
    function sub(uint a, uint b) internal returns (uint result) {
        uint c = a - b;

        assert(b <= a);

        return c;
    }

    /**
     * @notice Безопасное умножение.
     * @param Исходное число.
     * @param Модификатор.
     * @return Результат.
     **/
    function mul(uint a, uint b) internal returns (uint result) {
        uint c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }

    /**
     * @notice Безопасное деление.
     * @param Исходное число.
     * @param Модификатор.
     * @return Результат.
     **/
    function div(uint a, uint b) internal returns (uint result) {
        uint c = a / b;

        // No 'assert' for current Solidity version.

        return c;
    }

    /**
     * @notice Запрещаем числу быть нулем.
     * @param Исходное число.
     **/
    function denyZero(uint a) internal {
        require(a > 0);
    }
}