pragma solidity ^0.4.16;

/**
 * @notice Расширение типа string.
 **/
library IdeaString {

    /**
     * @notice Активное вычисление длины строки.
     * @param str Исходная строка.
     * @return length Длина строки.
     **/
    function length(string str) constant internal returns (uint length) {
        for (uint i = 0; i < bytes(str).length; i++) {
            if (str[i] >> 7 == 0) {
                i += 1;
            } else if (str[i] >> 5 == 0x6) {
                i += 2;
            } else if (str[i] >> 4 == 0xE) {
                i += 3;
            } else if (str[i] >> 3 == 0x1E) {
                i += 4;
            } else {
                i += 1; // Add +1 for safety
            }

            length++;
        }
    }

    /**
     * @notice Запрещаем длинну строки равную нулю.
     * @param str Исходная строка.
     **/
    function denyEmpty(string str) constant internal {
        require(str.length() > 0);
    }
}