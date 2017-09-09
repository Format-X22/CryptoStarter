pragma solidity ^0.4.16;

/**
 * @notice Часть контракта краудфайндинг-проекта,
 * отвечающая за механизм работы с продуктами.
 **/
contract IdeaProjectProducts {

    /**
     * @notice Список продуктов проекта.
     **/
    address[] public products;

    /**
     * @notice Соответствие имени продукта адресу продукта.
     **/
    mapping(string => address) public productsByName;

    /**
     * @notice Максимальное разрешенное количество продуктов у одного проекта.
     **/
    uint8 constant maxProducts = 25;

    /**
     * @notice Создания продукта, предлагаемого проектом.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _name Имя продукта.
     * @param _symbol Символ продукта.
     * @param _description Описание продукта.
     * @param _price Цена продукта в IDEA токенах.
     * @param _limit Лимит количества продуктов, 0 установит безлимитный режим.
     * @return _productAddress Адрес экземпляра контракта продукта.
     **/
    function makeProduct(
        string _name,
        string _symbol,
        string _description,
        uint _price,
        uint _limit
    ) onlyState(States.Initial) public onlyEngine returns (address _productAddress) {
        require(products.length <= maxProducts);

        IdeaSubCoin product = new IdeaSubCoin(this, _name, _symbol, _description, _price, _limit);

        products.push(product);
        productsByName[_name] = address(product);

        return address(product);
    }

    /**
     * @notice Получение адреса продукта по имени продукта.
     * @param _name Имя продукта.
     * @return _address Адрес продукта, в случае отсутствия будет возвращен нулевой адрес.
     **/
    function getProductAddressByName(string _name) constant public onlyEngine returns (address _address) {
        return productsByName[_name];
    }

    /**
     * @notice Получение всех имен продуктов. Результатом вычислений будет строка
     * из склеенных имен продуктов, разделенных разделителем в виде вертикальной черы '|'.
     * @return _stringWithSplitter Результат.
     **/
    function getAllProductsNames() constant public onlyEngine returns (string _stringWithSplitter) {
        string _stringWithSplitter;

        for (uint i = 0; i < products.length - 1; i += 1) {  // (length - 1) not a bug
            _stringWithSplitter += products[i].name() + '|';
        }

        _stringWithSplitter += products[products.length - 1].name();
    }

    /**
     * @notice Уничтожить последний созданный продукт.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     **/
    function destroyLastProduct() public onlyState(States.Initial) onlyEngine {
        require(products.length > 0);

        IdeaSubCoin(products[products.length - 1]).destroy();

        products.length = products.length - 1;
    }

    /**
     * @notice Уничтожить все продукты.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     **/
    function destroyAllProducts() public onlyState(States.Initial) onlyEngine {
        for (uint8 i = 0; i < products.length; i += 1) {
            IdeaSubCoin(products[i]).destroy();
        }

        delete products;
    }

}