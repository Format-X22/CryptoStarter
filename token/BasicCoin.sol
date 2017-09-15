pragma solidity ^0.4.16;

import './Uint.sol';

/**
 * @notice Базовая монета проекта.
 * Совместима с ERC20 стандартом.
 **/
contract IdeaBasicCoin {
    using IdeaUint for uint;

    /**
     * @notice Имя монеты.
     **/
    string public name;

    /**
     * @notice Аббривеатура монеты.
     **/
    string public symbol;

    /**
     * @notice Мультипликатор размерности монеты.
     **/
    uint8 public decimals;

    /**
     * @notice Общее количество монет.
     **/
    uint public totalSupply;

    /**
     * @notice Балансы аккаунтов.
     **/
    mapping(address => uint) balances;

    /**
     * @notice Балансы для разрешенного расходования.
     **/
    mapping(address => mapping(address => uint)) allowed;

    /**
     * @notice Список адресов всех известных аккаунтов.
     **/
    address[] public accounts;

    /**
     * @notice Список адресов всех известных аккаунтов в виде MAP.
     **/
    mapping(address => bool) internal accountsMap;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @notice Совершен перевод.
     * @param _from Отправитель.
     * @param _to Получатель.
     * @param _value Количество.
     **/
    event Transfer(address indexed _from, address indexed _to, uint _value);

    /**
     * @notice Разрешен расход.
     * @param _owner Владелец.
     * @param _spender Получатель.
     * @param _value Количество.
     **/
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    /**
     * @notice Проверить баланс аккаунта.
     * @param _owner Аккаунт.
     * @return balance Баланс.
     **/
    function balanceOf(address _owner) constant public returns (uint balance) {
        return balances[_owner];
    }

    /**
     * @notice Совершить перевод на указанный адрес.
     * @param _to Получатель.
     * @param _value Количество.
     * @return success Результат.
     **/
    function transfer(address _to, uint _value) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        tryCreateAccount(_to);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * @notice Совершить перевод с одного адреса на другой.
     * Для этого дейтвия сначала должен быть разрешен расход.
     * @param _from Отправитель.
     * @param _to Получатель.
     * @param _value Количество.
     * @return success Результат.
     **/
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        uint _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        tryCreateAccount(_to);

        Transfer(_from, _to, _value);

        return true;
    }

    /**
     * @notice Разрешить расход указанному адресу.
     * @param _spender Получатель.
     * @param _value Значение.
     * @return success Результат.
     **/
    function approve(address _spender, uint _value) public returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
     * @notice Проверить количество, разрешенное к расходу.
     * @param _owner Владелец.
     * @param _spender Получатель.
     * @return remaining Количество.
     **/
    function allowance(address _owner, address _spender) constant public returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * @notice Увеличить разрешенный расход.
     * @param _spender Получатель.
     * @param _addedValue Значение.
     * @return success Результат.
     **/
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    /**
     * @notice Уменьшить разрешенный расход.
     * @param _spender Получатель.
     * @param _subtractedValue Значение.
     * @return success Результат.
     **/
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    /**
     * @notice Создание аккаунта в случае если такой адрес ещё не зарегистрирован.
     * @param _account Адрес.
     **/
    function tryCreateAccount(address _account) internal {
        if (balances[_account] == 0 && !accountsMap[_account]) {
            accounts.push(_account);
            accountsMap[_account] = true;
        }
    }
}
