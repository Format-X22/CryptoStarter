pragma solidity ^0.4.16;

import './SubCoin.sol';
import './Uint.sol';

/**
 * @notice Контракт краудфайндинг-проекта.
 **/
contract IdeaProject {
    using IdeaUint for uint;

    /**
     * @notice Имя проекта.
     **/
    string public name;

    /**
     * @notice Адрес движка-инициатора.
     **/
    address public engine;

    /**
     * @notice Аккаунт владельца.
     **/
    address public owner;

    /**
     * @notice Количество необходимых инвестиций.
     **/
    uint public required;

    /**
     * @notice Количество дней сбора инвестиций.
     **/
    uint public requiredDays;

    /**
     * @notice Время окончания сбора инвестиций.
     **/
    uint public fundingEndTime;

    /**
     * @notice Количество собранных инвестиций.
     **/
    uint public earned;

    /**
     * @notice Соответствие аккаунта и факта того что деньги были возвращены.
     **/
    mapping(address => bool) public isCashBack;


    /**
     * @notice Конструктор.
     * @param _owner Владелец проекта.
     * @param _name Имя проекта.
     * @param _required Необходимое количество инвестиций в IDEA в размерности WEI.
     * @param _requiredDays Количество дней сбора инвестиций.
     * Должно быть в диапазоне от `minRequiredDays` до `maxRequiredDays`.
     **/
    function IdeaProject(
        address _owner,
        string _name,
        uint _required,
        uint _requiredDays
    ) {
        require(bytes(_name).length > 0);
        require(_required != 0);

        require(_requiredDays >= 10);
        require(_requiredDays <= 100);

        engine = msg.sender;
        owner = _owner;
        name = _name;
        required = _required;
        requiredDays = _requiredDays;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @notice Ограничивает возможность исполнения метода только контрактом-движком.
     **/
    modifier onlyEngine() {
        require(msg.sender == engine);
        _;
    }

    // ===                ===
    // === STATES SECTION ===
    // ===                ===

    /**
     * @notice Варианты состояния проекта.
     **/
    enum States {

        // Изначальное состояние, проект ещё не активен,
        // проект может менять свои свойства, покупать продукты ещё нельзя.
        Initial,

        // Проект помечен как предстоящий, настройки проекта заморожены.
        Coming,

        // Проект в состоянии сбора инвестиций, переход на
        // следующее состояние автоматически по завершению указанного
        // количества дней (смотри 'requiredDays').
        Funding,

        // Проект собрал необходимые инвестиции и находится в процессе работы,
        // автор проекта получил деньги для реализации первого проекта и начал
        // реализовывать проект этап за этапом, получая соответствующие инвестиции,
        // инвесторы в праве голосовать за каждый следующий этап или возврат средств
        // (смотри также 'WorkStages').
        Workflow,

        // Проект завершен, в момент установки состояния замораживается список доставки
        // и владельцы находятся в ожидании получения готовой продукции.
        SuccessDone,

        // Проект не собрал необходимые инвестиции и деньги вернулись инвесторам
        FundingFail,

        // На одном из этапов проект был оценен инвесторами как провальный,
        // инвесторы получили оставшиеся деньги назад, проект закрылся
        WorkFail
    }

    /**
     * @notice Текущее состояние проекта.
     * Смена состояния происходит не мгновенно по причине особенностей
     * работы Ethereum, однако это не влияет на логику работы контракта.
     **/
    States public state = States.Initial;

    /**
     * @notice Разрешаем исполнять метод только в указанном состоянии.
     * @param _state Состояние.
     **/
    modifier onlyState(States _state) {
        require(state == _state);
        _;
    }

    /**
     * @notice Находится ли проект в состоянии сбора средств.
     * @param _result Результат проверки.
     **/
    function isFundingState() constant public returns (bool _result) {
        return state == States.Funding;
    }

    /**
     * @notice Находится ли проект в состоянии работы по реализации проекта.
     * @param _result Результат проверки.
     **/
    function isWorkflowState() constant public returns (bool _result) {
        return state == States.Workflow;
    }

    /**
     * @notice Находится ли проект в состоянии успешного завершения.
     * @param _result Результат проверки.
     **/
    function isSuccessDoneState() constant public returns (bool _result) {
        return state == States.SuccessDone;
    }

    /**
     * @notice Находится ли проект в состоянии не успешного сбора средств.
     * @param _result Результат проверки.
     **/
    function isFundingFailState() constant public returns (bool _result) {
        return state == States.FundingFail;
    }

    /**
     * @notice Находится ли проект в состоянии не успешной реализации.
     * @param _result Результат проверки.
     **/
    function isWorkFailState() constant public returns (bool _result) {
        return state == States.WorkFail;
    }

    /**
     * @notice Перевести проект в состояние 'Coming'
     * и заблокировать возможность внесения изменений.
     **/
    function markAsComingAndFreeze() public onlyState(States.Initial) onlyOwner {
        require(products.length > 0);
        require(currentWorkStagePercent == 100);

        uint raw;
        uint reserve;
        uint reserveTotal;

        state = States.Coming;

        for (uint8 i; i < workStages.length; i += 1) {
            raw = required.mul(workStages[i].percent);
            reserve = raw % 100;
            reserveTotal = reserveTotal.add(reserve);

            workStages[i].sum = raw.sub(reserve).div(100);
        }
    
        workStages[workStages.length - 1].sum = workStages[workStages.length - 1].sum.add(reserveTotal);
    }

    /**
     * @notice Запустить сбор средств.
     * Остановить сбор будет нельзя. При успешном сборе проект перейдет
     * в состояние начала работ и будут начислены средства за первый этап.
     * В случае не сбора средств за необходимое время - проект будет закрыт,
     * а средства вернуться на счета инвесторов.
     **/
    function startFunding() public onlyState(States.Coming) onlyOwner {
        state = States.Funding;

        fundingEndTime = uint64(now + requiredDays * 1 days);
        calcLastWorkStageStart();
    }

    /**
     * @notice Установить состояние проекта на факт начала работ по его реализации.
     **/
    function projectWorkStarted() public onlyState(States.Funding) onlyEngine {
        state = States.Workflow;
    }

    /**
     * @notice Пометить проект как завершенный. Проект должен находится
     * на последнем этапе работ. Также это означает что стартует доставка
     * готовой продукции.
     **/
    function projectDone() public onlyState(States.Workflow) onlyOwner {
        require(now > lastWorkStageStartTimestamp);

        state = States.SuccessDone;
    }

    /**
     * @notice Пометить проект как провалившийся на этапе сбора средств.
     **/
    function projectFundingFail() public onlyState(States.Funding) onlyEngine {
        state = States.FundingFail;
    }

    /**
     * @notice Пометить проект как провалившийся на этапе работы над реализацией проекта.
     **/
    function projectWorkFail() internal {
        uint failTime = fundingEndTime;

        state = States.WorkFail;

        for (uint8 i; i < workStages.length; i += 1) {
            failTime = failTime.add(workStages[i].stageDays * 1 days);
            failInvestPercents = failInvestPercents.add(workStages[i].percent);

            if (failTime > now) {
                failStage = int8(i);
            }
        }
    }

    // ===                     ===
    // === WORK STAGES SECTION ===
    // ===                     ===

    /**
     * @notice Структура этапа работ.
     **/
    struct WorkStage {
        uint8 percent;      // Процент средств от общего бюджета.
        uint8 stageDays;    // Количество дней выполнения этапа.
        uint sum;           /* Сумма, доступная для вывода с момента
                               начала этапа в случае если проект
                               не был признан провалившимся. */
    }

    /**
     * @notice Список этапов работ.
     **/
    WorkStage[] public workStages;

    /**
     * @notice Текущее количество процентов всех этапов.
     **/
    uint public currentWorkStagePercent;

    /**
     * @notice Время старта последнего этапа работ.
     **/
    uint internal lastWorkStageStartTimestamp;

    /**
     * @notice Этап работ, который провалился, отсчет с 0.
     * Значение -1 указывает на отсутствие такого этапа.
     **/
    int8 failStage = -1;

    /**
     * @notice Количество потерянны инвестиций в процентах.
     **/
    uint failInvestPercents;

    /**
     * @notice Создать этап работы.
     * Суммарно должно быть не более 10 этапов (`maxWorkStages`),
     * а также сумма процентов всех этапов должна быть равна 100%.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _percent Процент средств от общего бюджета.
     * @param _stageDays Количество дней выполнения этапа.
     * Количество должно быть не менее 10 и не более 100 дней.
     **/
    function makeWorkStage(
        uint8 _percent,
        uint8 _stageDays
    ) public onlyState(States.Initial) {
        require(workStages.length <= 10);
        require(_stageDays >= 10);
        require(_stageDays <= 100);

        if (currentWorkStagePercent.add(_stageDays) > 100) {
            revert();
        } else {
            currentWorkStagePercent = currentWorkStagePercent.add(_stageDays);
        }

        workStages.push(WorkStage(
            _percent,
            _stageDays,
            0
        ));
    }

    /**
     * @notice Вычисление начала последнего этапа работ.
     **/
    function calcLastWorkStageStart() internal {
        lastWorkStageStartTimestamp = fundingEndTime;

        // (length - 1) not a bug
        for (uint8 i; i < workStages.length - 1; i += 1) {
            lastWorkStageStartTimestamp += workStages[i].stageDays * 1 days;
        }
    }

    /**
     * @notice Вывести средства за указанный этап работ.
     * @param _stage Этап.
     * @return _sum Количество.
     **/
    function withdraw(uint8 _stage) public onlyEngine returns (uint _sum) {
        _sum = workStages[_stage].sum;

        workStages[_stage].sum = 0;
    }

    // ===                  ===
    // === PRODUCTS SECTION ===
    // ===                  ===

    /**
     * @notice Список продуктов проекта.
     **/
    address[] public products;

    /**
     * @notice Разрешить действие только от котракта продукта, принадлежащего этому проекту.
     **/
    modifier onlyProduct() {
        bool permissionGranted;

        for (uint8 i; i < products.length; i += 1) {
            if (msg.sender == products[i]) {
                permissionGranted = true;
            }
        }

        if (permissionGranted) {
            _;
        } else {
            revert();
        }
    }

    /**
     * @notice Создания продукта, предлагаемого проектом.
     * Этот метод можно вызывать только до пометки проекта как 'Coming'.
     * @param _name Имя продукта.
     * @param _symbol Символ продукта.
     * @param _price Цена продукта в IDEA токенах в размерности WEI.
     * @param _limit Лимит количества продуктов, 0 установит безлимитный режим.
     * @return _productAddress Адрес экземпляра контракта продукта.
     **/
    function makeProduct(
        string _name,
        string _symbol,
        uint _price,
        uint _limit
    ) public onlyState(States.Initial) onlyEngine returns (address _productAddress) {
        require(products.length <= 25);

        IdeaSubCoin product = new IdeaSubCoin(this, _name, _symbol, _price, _limit);

        products.push(address(product));

        return address(product);
    }

    /**
     * @notice Вычисление неизрасходованных инвестиций, принидлежащих аккаунту.
     * @param _account Аккаунт.
     * @return _sum Сумма.
     **/
    function calcInvesting(address _account) public onlyEngine returns (uint _sum) {
        require(!isCashBack[_account]);

        for (uint8 i = 0; i < products.length; i += 1) {
            IdeaSubCoin product = IdeaSubCoin(products[i]);

            _sum = _sum.add(product.balanceOf(_account) * product.price());
        }

        if (isWorkFailState()) {
            _sum = _sum.mul(100 - failInvestPercents).div(100);
        }

        isCashBack[_account] = true;
    }

    // ===                ===
    // === VOTING SECTION ===
    // ===                ===

    /**
     * @notice Процент голосов отданных за возврат денег инветорам.
     * Значение хранится в виде числа процентов, возведенных в 10 степень,
     * то есть число 10000000000 соответствует 1% головов за возврат средств.
     * Смотри также метод 'voteForCashBack'.
     **/
    uint public cashBackVotes;

    /**
     * @notice Соответствие процента веса голоса аккаунту инвестора.
     * В обычном случае это будет 0 или 100, в некоторох других - смотри
     * метод 'voteForCashBackInPercentOfWeight'.
     **/
    mapping(address => uint8) public cashBackWeight;

    /**
     * @notice Отдать голос за прекращение проекта и возврат средств.
     * Голосовать можно в любой момент, также можно отменить голос воспользовавшись
     * методом 'cancelVoteForCashBack'. Вес голоса зависит от количества вложенных средств.
     * Перед началом нового этапа работ и выдачей очередного транша создателю проекта -
     * происходит проверка на голоса за возврат. Если голосов, с учетом их веса, суммарно
     * оказалось больше 50% общего веса голосов - проект помечается как провальный,
     * владелец проекта не получает транш, а инвесторы могут забрать оставшиеся средства
     * пропорционально вложениям.
     * @param _account Аккаунт.
     **/
    function voteForCashBack(address _account) public onlyState(States.Workflow) onlyEngine {
        voteForCashBackInPercentOfWeight(_account, 100);
    }

    /**
     * @notice Отменить голос за возврат средст.
     * Смотри подробности в описании метода 'voteForCashBack'.
     * @param _account Аккаунт.
     **/
    function cancelVoteForCashBack(address _account) public onlyState(States.Workflow) onlyEngine {
        voteForCashBackInPercentOfWeight(_account, 0);
    }

    /**
     * @notice Аналог метода 'voteForCashBack', но позволяющий
     * голосовать не всем весом. Подобное может использоваться для
     * фондов, хранящих средства нескольких клиентов.
     * Вызов этого метода повторно с другим значением процента
     * редактирует вес голоса, установка значения на 0 эквивалентна
     * вызову метода 'cancelVoteForCashBack'.
     * @param _account Аккаунт.
     * @param _percent Необходимый процент от 0 до 100.
     **/
    function voteForCashBackInPercentOfWeight(
        address _account,
        uint8 _percent
    ) public onlyState(States.Workflow) {

        uint8 currentWeight = cashBackWeight[_account];
        uint supply;
        uint part;

        for (uint8 i; i < products.length; i += 1) {
            supply += IdeaSubCoin(products[i]).totalSupply();
            part += IdeaSubCoin(products[i]).balanceOf(_account);
        }

        cashBackVotes += ((part ** 10) / supply) * (_percent - currentWeight);
        cashBackWeight[_account] = _percent;

        if (cashBackVotes > 50 ** 10) {
            projectWorkFail();
        }
    }

    /**
     * @notice Корректирует значения голосов за возвврат средств при переводе
     * монет в одном из продуктов проекта.
     * Смотри также 'voteForCashBack'.
     * @param _from Отправитель.
     * @param _to Получатель.
     **/
    function updateVotesOnTransfer(address _from, address _to) public onlyProduct {
        if (isWorkflowState()) {
            voteForCashBackInPercentOfWeight(_from, cashBackWeight[_from]);
            voteForCashBackInPercentOfWeight(_to, cashBackWeight[_to]);
        }
    }

}