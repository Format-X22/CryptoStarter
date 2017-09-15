pragma solidity ^0.4.16;

import '../coin/Basic';

/**
 * @notice IdeaCoin (IDEA) - непосредственно сама монета.
 **/
contract IdeaMainCoin is IdeaCoinBasic {

    /**
     * @notice Конструктор.
     **/
    function IdeaCoin() {
        name = 'IdeaCoin';
        symbol = 'IDEA';
        decimals = 18;
        uint supply = 100000000; // 100 000 000 IDEA
        totalSupply = supply ** decimals;

        owner = msg.sender;
        balances[owner] = totalSupply;
        tryCreateAccount(msg.sender);
    }
}