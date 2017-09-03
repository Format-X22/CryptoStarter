pragma solidity ^0.4.16;

/**
 * @notice Расширение типа string.
 **/
library IdeaString {

    /**
     * @notice Активное вычисление длины строки.
     * @param str Исходная строка.
     * @return _length Длина строки.
     **/
    function length(string str) constant internal returns (uint _length) {
        bytes memory str_bytes = bytes(str);

        for (uint i = 0; i < str_bytes.length; i++) {
            if (str_bytes[i] >> 7 == 0) {
                i += 1;
            } else if (str_bytes[i] >> 5 == 0x6) {
                i += 2;
            } else if (str_bytes[i] >> 4 == 0xE) {
                i += 3;
            } else if (str_bytes[i] >> 3 == 0x1E) {
                i += 4;
            } else {
                i += 1; // Add +1 for safety
            }

            _length++;
        }
    }

    /**
     * @notice Запрещаем длинну строки равную нулю.
     * @param str Исходная строка.
     **/
    function denyEmpty(string str) constant internal {
        require(length(str) > 0);
    }
}