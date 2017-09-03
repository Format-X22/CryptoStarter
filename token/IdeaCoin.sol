pragma solidity ^0.4.16;

import './IdeaBasicCoin.sol';
import './IdeaDividendsEngine.sol';
import './IdeaProjectsEngine.sol';
import './IdeaIco.sol';

/**
 * @notice IdeaCoin (IDEA) - непосредственно сама монета.
 **/
contract IdeaCoin is IdeaBasicCoin, IdeaDividendsEngine, IdeaProjectsEngine, IdeaIco {

    /**
     * @notice Владелец IdeaCoin.
     **/
    address public owner;

    /**
     * @notice Конструктор.
     **/
    function IdeaCoin() {
        name = 'IdeaCoin';
        symbol = 'IDEA';
        decimals = 8;
        uint supply = 600000000; // 600 000 000 IDEA
        totalSupply = supply ** decimals;

        owner = msg.sender;
        balances[owner] = totalSupply;
        tryCreateAccount(msg.sender);
    }
}