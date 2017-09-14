pragma solidity ^0.4.16;

import './Uint.sol';
import './String.sol';
import './Address.sol';

contract IdeaTypeBind {
    using IdeaUint for uint;
    using IdeaString for string;
    using IdeaAddress for address;
}