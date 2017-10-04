pragma solidity ^0.4.17;

import './BasicCoin.sol';
import './Project.sol';

/**
 * @notice Контракт саб-монеты IdeaCoin.
 * Подобные монеты создаются под каждый тип товара каждого проекта CryptoStarter.
 * Это полноценная ERC20 монета c дополнительными свойствами, присущими Idea инфраструктуре.
 **/
contract IdeaSubCoin is IdeaBasicCoin {

    /**
     * @notice Названия продукта (название монеты).
     **/
    string public name;

    /**
     * @notice Аббривеатура продукта (аббривеатура монеты).
     **/
    string public symbol;

    /**
     * @notice Мультипликатор размерности монеты.
     * (В нашем случае нулевая так как дробление не уместно).
     **/
    uint8 public constant decimals = 0;

    /**
     * @notice Максимальный лимит продаж.
     * Значение равное нулю (0) означает что лимита нет.
     **/
    uint public limit;

    /**
     * @notice Цена за продукт в IDEA токенах в размерности WEI,
     * установленная владельцем проекта. Значение используется
     * только в момент первичной продажи и при голосовании.
     **/
    uint public price;

    /**
     * @notice Адрес контракта проекта, которому принадлежат продукты.
     **/
    address public project;

    /**
     * @notice Хранилище соответствий между адресом аккаунта и физическим
     * адресом доставки. Может отстутствовать.
     **/
    mapping(address => string) public shipping;

    /**
     * @notice Конструктор.
     * @param _owner Владелец продуктов.
     * @param _name Имя продукта.
     * @param _symbol Символ продукта.
     * @param _price Цена продукта в IDEA токенах.
     * @param _limit Лимит количества продуктов, 0 установит безлимитный режим.
     * Лимиты можно изменить в любой момент.
     **/
    function IdeaSubCoin(
        address _owner,
        string _name,
        string _symbol,
        uint _price,
        uint _limit
    ) {
        require(_price != 0);

        owner = _owner;
        name = _name;
        symbol = _symbol;
        price = _price;
        limit = _limit;
        project = msg.sender;
    }

    /**
     * @notice Ограничивает возможность исполнения метода только контрактом-проектом.
     **/
    modifier onlyProject() {
        require(msg.sender == project);
        _;
    }

    /**
     * @notice Совершить перевод на указанный адрес.
     * @param _to Получатель.
     * @param _value Количество.
     * @return success Результат.
     **/
    function transfer(address _to, uint _value) public returns (bool success) {
        bool result = super.transfer(_to, _value);

        if (result) {
            IdeaProject(project).updateVotesOnTransfer(msg.sender, _to);
        }

        return result;
    }

    /**
     * @notice Совершить перевод с одного адреса на другой.
     * @param _from Отправитель.
     * @param _to Получатель.
     * @param _value Количество.
     * @return success Результат.
     **/
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        bool result = super.transferFrom(_from, _to, _value);

        if (result) {
            IdeaProject(project).updateVotesOnTransfer(_from, _to);
        }

        return result;
    }

    /**
     * @notice Производит покупку токенов продукта.
     * @param _amount Количество токенов.
     **/
    function buy(uint _amount) public onlyProject {
        uint total = totalSupply.add(_amount);

        if (limit != 0) {
            require(total <= limit);
        }

        totalSupply = totalSupply.add(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
        tryCreateAccount(msg.sender);
    }

    /**
     * @notice Устанавливает адрес физической доставки товара.
     * @param _shipping Адрес физической доставки.
     **/
    function setShipping(string _shipping) public onlyProject {
        require(bytes(_shipping).length > 0);
    
        shipping[msg.sender] = _shipping;
    }

}