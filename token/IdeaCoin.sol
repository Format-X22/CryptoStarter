pragma solidity ^0.4.16;

import 'IdeaBasicCoin';
import 'IdeaDividendsEngine';
import 'IdeaProjectsEngine';
import 'IdeaIco';

/**
 * @notice IdeaCoin (IDEA) - непосредственно сама монета.
 **/
contract IdeaCoin is IdeaBasicCoin, IdeaDividendsEngine, IdeaProjectsEngine, IdeaIco {

    /**
     * @notice Имя монеты.
     **/
    string public constant name = 'IdeaCoin';

    /**
     * @notice Аббривеатура монеты.
     **/
    string public constant symbol = 'IDEA';

    /**
     * @notice Мультипликатор размерности монеты.
     **/
    uint8 public constant decimals = 8;

    /**
     * @notice Общее количество монет.
     **/
    uint public constant totalSupply = 600000000 * 100000000; // 600 000 000 IDEA

    /**
     * @notice Владелец IdeaCoin.
     **/
    address public owner;

    /**
     * @notice Конструктор.
     **/
    function IdeaCoin() {
        owner = msg.sender;
        balances[owner] = totalSupply;
        tryCreateAccount(msg.sender);
    }
}