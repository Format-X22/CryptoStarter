pragma solidity ^0.4.16;

import 'IdeaUint';

/**
 * @notice Базовая монета проекта.
 * Совместима с ERC20 стандартом.
 **/
contract IdeaBasicCoin {
    using IdeaUint for uint;

    /**
     * @notice Имя монеты.
     **/
    string public constant name;

    /**
     * @notice Аббривеатура монеты.
     **/
    string public constant symbol;

    /**
     * @notice Мультипликатор размерности монеты.
     **/
    uint8 public constant decimals;

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

    /**
     * @notice Совершен перевод.
     * @param Отправитель.
     * @param Получатель.
     * @param Количество.
     **/
    event Transfer(address indexed from, address indexed to, uint value);

    /**
     * @notice Разрешен расход.
     * @param Владелец.
     * @param Получатель.
     * @param Количество.
     **/
    event Approval(address indexed owner, address indexed spender, uint value);

    /**
     * @notice Проверить баланс аккаунта.
     * @param Аккаунт.
     * @return Баланс.
     **/
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    /**
     * @notice Совершить перевод на указанный адрес.
     * @param Получатель.
     * @param Количество.
     * @return Результат.
     **/
    function transfer(address _to, uint _value) returns (bool success) {
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        tryCreateAccount(_to);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * @notice Совершить перевод с одного адреса на другой.
     * Для этого дейтвия сначала должен быть разрешен расход.
     * @param Отправитель.
     * @param Получатель.
     * @param Количество.
     * @return Результат.
     **/
    function transferFrom(address _from, address _to, uint _value) returns (bool success) {
        require(_to != address(0));

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
     * @param Получатель.
     * @param Значение.
     * @return Результат.
     **/
    function approve(address _spender, uint _value) returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    /**
     * @notice Проверить количество, разрешенное к расходу.
     * @param Владелец.
     * @param Получатель.
     * @return Количество.
     **/
    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * @notice Увеличить разрешенный расход.
     * @param Получатель.
     * @param Значение.
     * @return Результат.
     **/
    function increaseApproval(address _spender, uint _addedValue) returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    /**
     * @notice Уменьшить разрешенный расход.
     * @param Получатель.
     * @param Значение.
     * @return Результат.
     **/
    function decreaseApproval(address _spender, uint _subtractedValue) returns (bool success) {
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
     * @param Адрес.
     **/
    function tryCreateAccount(address _account) internal {
        if (balances[_account] == 0 && !accountsMap[_account]) {
            accounts.push(_account);
            accountsUsed[_account] = true;
        }
    }
}