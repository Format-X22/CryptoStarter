pragma solidity ^0.4.16;

contract IdeaOfferingPreIco {

    /**
     * @notice Максимальное количество монет, разрешенных к продаже на PreICO.
     * Не проданное будет сожжено в двойном размере от общего количества монет.
     **/
    uint constant public maxCoinsForPreIco = 2500000; // 2 500 000 IDEA

    /**
     * @notice Минимальное количество монет ETH за которое производится продажа
     * монет IDEA на PreICO.
     **/
    uint constant public minEtherForPreIcoBuy = 20;

}