pragma solidity ^0.4.16;

import './IdeaUint.sol';
import './IdeaString.sol';
import './IdeaAddress.sol';

contract IdeaTypeBind {
    using IdeaUint for uint;
    using IdeaString for string;
    using IdeaAddress for address;
}