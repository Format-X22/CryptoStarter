pragma solidity ^0.4.16;

import 'IdeaBasicCoin';

/**
 * @notice Контракт саб-монеты IdeaCoin.
 * Подобные монеты создаются под каждый тип товара каждого проекта CryptoStarter.
 * Это полноценная ERC20 монета c дополнительными свойствами, присущими Idea инфраструктуре.
 **/
contract IdeaSubCoin is IdeaBasicCoin {

    // Базовая информация
    string public name;
    string public symbol;

    /**
     * @notice Описание продукта.
     **/
    string public description;

    /**
     * @notice Максимальный лимит продаж.
     * Значение равное нулю (0) означает что лимита нет.
     **/
    uint public limit;

    /**
     * @notice Цена за продукт в IDEA токенах, установленная владельцем проекта.
     * Значение используется только в момент первичной продажи.
     **/
    uint public price;

    /**
     * @notice Владелец продуктов.
     **/
    address public owner;

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
     * @notice Лимит продуктов, доступных к продаже, был увеличен.
     * @param Колчество.
     **/
    event IncreaseLimit(uint _amount);

    /**
     * @notice Лимит продуктов, доступных к продаже, был уменьшен.
     * @param Количество.
     **/
    event DecreaseLimit(uint _amount);

    /**
     * @notice Теперь продукты ограничены в количестве.
     **/
    event Limited();

    /**
     * @notice Теперь продукты не ограничены в количестве.
     **/
    event Unlimited();

    /**
     * @notice Произведена покупка токенов за IDEA токены.
     * Эвент возможен только в период первичных продаж.
     * @param Аккаунт покупателя.
     * @param Количество.
     **/
    event Buy(address _account, uint _amount);

    /**
     * @notice Конструктор.
     * @param Владелец продуктов.
     * @param Имя продукта.
     * @param Символ продукта.
     * @param Описание продукта.
     * @param Цена продукта в IDEA токенах.
     * @param Лимит количества продуктов, 0 установит безлимитный режим.
     * Лимиты можно изменить в любой момент.
     **/
    function IdeaSubCoin(
        address _owner,
        string _name,
        string _symbol,
        string _description,
        uint _price,
        uint _limit
    ) {
        require(_owner);
        require(_name);
        require(_symbol);
        require(_description);
        require(_price);

        owner = _owner;
        name = _name;
        symbol = _symbol;
        description = _description;
        price = _price;
        limit = _limit;
        project = msg.sender;
    }

    // Отключаем возможность пересылать эфир на адрес контракта.
    function() payable {
        throw;
    }

    /**
     * @notice Ограничивает возможность исполнения метода только контрактом-проектом.
     **/
    modifier onlyProject() {
        require(msg.sender == project);
        _;
    }

    /**
     * @notice Увеличение максимального лимита количества продуктов, доступных к продаже.
     * @param Колчество, на которое необходимо увеличить лимит.
     **/
    function incLimit(uint _amount) public onlyProject {
        require(limit > 0);
        require(limit + _amount > limit);

        if (limit == 0) {
            Limited();
        }

        limit += _amount;

        IncreaseLimit(_amount);
    }

    /**
     * @notice Уменьшение максимального лимита количества продуктов, доступных к продаже.
     * @param Количество, на которое необходимо уменьшить лимит.
     **/
    function decLimit(uint _amount) public onlyProject {
        require(limit > 0);
        require(limit - _amount < limit);

        limit -= _amount;

        DecreaseLimit(_amount);

        if (limit == 0) {
            Unlimited();
        }
    }

    /**
     * @notice Делает количество продуктов безлимитным.
     **/
    function makeUnlimited() public onlyProject {
        limit = 0;
    }

    /**
     * @notice Производит покупку токенов продукта.
     * @param Аккаунт покупателя.
     * @param Количество токенов.
     **/
    function buy(address _account, uint _amount) public onlyProject {
        require(supply + _amount > supply);

        if (limit != 0) {
            require(supply + _amount < limit);
        }

        require(balances[_account] + _amount > balances[_account]);

        totalSupply += _amount;
        balances[_account] += _amount;

        Buy(_account, _amount);
    }

    /**
     * @notice Устанавливает адрес физической доставки товара.
     * @param Аккаунт покупателя.
     * @param Адрес физической доставки.
     **/
    function setShipping(address _account, string _shipping) public onlyProject {
        require(_account);
        require(_shipping.length > 0);
    
        shipping[_account] = _shipping;
    }

}