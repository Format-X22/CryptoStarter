pragma solidity ^0.4.16;

contract IdeaCoin {
    // Public constants
    string public constant name = 'IdeaCoin';
    string public constant symbol = 'IDEA';
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETH
    uint public constant totalSupply = 600000000; // 600 000 000

    // Token data
    address public owner;
    mapping(address => uint) private balances;

    // Events
    event Transfer(address indexed from, address indexed to, uint value);

    // Dividends data
    struct Deposit {
        address person;
        uint count;
    }
    Deposit[] private investors;
    mapping(address => uint) private investorsMap;

    // Constructor
    function IdeaCoin () {
        owner = msg.sender;
        balances[owner] = totalSupply;
    }

    function balanceOf(address target) external constant returns (uint) {
        return balances[target];
    }

    /**
     * @notice Transfer `amount` IDEA tokens from sender's
     * account `msg.sender` to provided account address `target`.
     * @param target The address of the tokens recipient
     * @param amount The amount of token to be transferred
     * @return Whether the transfer was successful or not
     **/
    function transfer(address target, uint amount) public returns (bool) {
        // We can`t have overflows, no check
        if (balances[msg.sender] < amount || amount == 0) {
            return false;
        }

        balances[msg.sender] -= amount;
        balances[target] += amount;

        Transfer(msg.sender, target, amount);

        return true;
    }
}