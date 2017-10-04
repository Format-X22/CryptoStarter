pragma solidity ^0.4.17;

/**
 * @notice Расширение типа uint.
 **/
library IdeaUint {

    /**
     * @notice Безопасное сложение.
     * @param a Исходное число.
     * @param b Модификатор.
     * @return result Результат.
     **/
    function add(uint a, uint b) constant internal returns (uint result) {
        uint c = a + b;

        assert(c >= a);

        return c;
    }

    /**
     * @notice Безопасное вычитание.
     * @param a Исходное число.
     * @param b Модификатор.
     * @return result Результат.
     **/
    function sub(uint a, uint b) constant internal returns (uint result) {
        uint c = a - b;

        assert(b <= a);

        return c;
    }

    /**
     * @notice Безопасное умножение.
     * @param a Исходное число.
     * @param b Модификатор.
     * @return result Результат.
     **/
    function mul(uint a, uint b) constant internal returns (uint result) {
        uint c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }

    /**
     * @notice Безопасное деление.
     * @param a Исходное число.
     * @param b Модификатор.
     * @return result Результат.
     **/
    function div(uint a, uint b) constant internal returns (uint result) {
        uint c = a / b;

        // No 'assert' for current Solidity version.

        return c;
    }
}