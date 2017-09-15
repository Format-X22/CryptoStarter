pragma solidity ^0.4.16;

import './Uint.sol';
import './String.sol';
import './Address.sol';

/**
 * @notice Биндинг типов.
 * Контракт предназначен для миксования в другие контракты для
 * включения поддержки всех расширений типов за раз.
 **/
contract IdeaTypeBind {
    using IdeaUint for uint;
    using IdeaString for string;
    using IdeaAddress for address;
}