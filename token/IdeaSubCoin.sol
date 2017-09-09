pragma solidity ^0.4.16;

import './IdeaBasicCoin.sol';

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
     * @param amount Колчество.
     **/
    event IncreaseLimit(uint amount);

    /**
     * @notice Лимит продуктов, доступных к продаже, был уменьшен.
     * @param amount Количество.
     **/
    event DecreaseLimit(uint amount);

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
     * @param account Аккаунт покупателя.
     * @param amount Количество.
     **/
    event Buy(address account, uint amount);

    /**
     * @notice Конструктор.
     * @param _owner Владелец продуктов.
     * @param _name Имя продукта.
     * @param _symbol Символ продукта.
     * @param _description Описание продукта.
     * @param _price Цена продукта в IDEA токенах.
     * @param _limit Лимит количества продуктов, 0 установит безлимитный режим.
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
        _owner.denyZero();
        _name.denyEmpty();
        _symbol.denyEmpty();
        _description.denyEmpty();
        _price.denyZero();

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
        revert();
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
     * @param _amount Колчество, на которое необходимо увеличить лимит.
     **/
    function incLimit(uint _amount) public onlyProject {
        limit.denyZero();

        if (limit == 0) {
            Limited();
        }

        limit = limit.add(_amount);

        IncreaseLimit(_amount);
    }

    /**
     * @notice Уменьшение максимального лимита количества продуктов, доступных к продаже.
     * @param _amount Количество, на которое необходимо уменьшить лимит.
     **/
    function decLimit(uint _amount) public onlyProject {
        limit.denyZero();

        limit = limit.sub(_amount);

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
     * @param _account Аккаунт покупателя.
     * @param _amount Количество токенов.
     **/
    function buy(address _account, uint _amount) public onlyProject {
        uint total = totalSupply.add(_amount);

        if (limit != 0) {
            require(total <= limit);
        }

        totalSupply = totalSupply.add(_amount);
        balances[_account] = balances[_account].add(_amount);
        tryCreateAccount(_account);

        Buy(_account, _amount);
    }

    /**
     * @notice Устанавливает адрес физической доставки товара.
     * @param _account Аккаунт покупателя.
     * @param _shipping Адрес физической доставки.
     **/
    function setShipping(address _account, string _shipping) public onlyProject {
        _shipping.length().denyZero();
    
        shipping[_account] = _shipping;
    }

    /**
     * @notice Уничтожает продукт.
     * Используется на этапе конфигурирования проекта.
     **/
    function destroy() public onlyProject {
        selfdestruct();
    }

}