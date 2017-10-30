pragma solidity 0.4.17;

import './SubCoin.sol';
import './Uint.sol';

contract IdeaProject {
    using IdeaUint for uint;

    string public name;
    address public engine;
    address public owner;
    uint public required;
    uint public requiredDays;
    uint public fundingEndTime;
    uint public earned;
    mapping(address => bool) public isCashBack;
    uint public currentWorkStagePercent;
    uint internal lastWorkStageStartTimestamp;
    int8 public failStage = -1;
    uint public failInvestPercents;
    address[] public products;
    uint public cashBackVotes;
    mapping(address => uint8) public cashBackWeight;

    enum States {
        Initial,
        Coming,
        Funding,
        Workflow,
        SuccessDone,
        FundingFail,
        WorkFail
    }

    States public state = States.Initial;

    struct WorkStage {
        uint8 percent;
        uint8 stageDays;
        uint sum;
    }

    WorkStage[] public workStages;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyEngine() {
        require(msg.sender == engine);
        _;
    }

    modifier onlyState(States _state) {
        require(state == _state);
        _;
    }

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

    function addEarned(uint _earned) public onlyEngine {
        earned = earned.add(_earned);
    }

    function isFundingState() constant public returns (bool _result) {
        return state == States.Funding;
    }

    function isWorkflowState() constant public returns (bool _result) {
        return state == States.Workflow;
    }

    function isSuccessDoneState() constant public returns (bool _result) {
        return state == States.SuccessDone;
    }

    function isFundingFailState() constant public returns (bool _result) {
        return state == States.FundingFail;
    }

    function isWorkFailState() constant public returns (bool _result) {
        return state == States.WorkFail;
    }

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

    function startFunding() public onlyState(States.Coming) onlyOwner {
        state = States.Funding;

        fundingEndTime = uint64(now + requiredDays * 1 minutes);
        calcLastWorkStageStart();
    }

    function projectWorkStarted() public onlyState(States.Funding) onlyEngine {
        state = States.Workflow;
    }

    function projectDone() public onlyState(States.Workflow) onlyOwner {
        require(now > lastWorkStageStartTimestamp);

        state = States.SuccessDone;
    }

    function projectFundingFail() public onlyState(States.Funding) onlyEngine {
        state = States.FundingFail;
    }

    function projectWorkFail() internal {
        uint failTime = fundingEndTime;

        state = States.WorkFail;

        for (uint8 i; i < workStages.length; i += 1) {
            failTime = failTime.add(workStages[i].stageDays * 1 minutes);
            failInvestPercents = failInvestPercents.add(workStages[i].percent);

            if (failTime > now) {
                failStage = int8(i);
            }
        }
    }

    function makeWorkStage(
        uint8 _percent,
        uint8 _stageDays
    ) public onlyState(States.Initial) {
        require(workStages.length <= 10);
        require(_stageDays >= 10);
        require(_stageDays <= 100);

        if (currentWorkStagePercent.add(_percent) > 100) {
            revert();
        } else {
            currentWorkStagePercent = currentWorkStagePercent.add(_percent);
        }

        workStages.push(WorkStage(
            _percent,
            _stageDays,
            0
        ));
    }

    function calcLastWorkStageStart() internal {
        lastWorkStageStartTimestamp = fundingEndTime;

        for (uint8 i; i < workStages.length - 1; i += 1) {
            lastWorkStageStartTimestamp += workStages[i].stageDays * 1 minutes;
        }
    }

    function withdraw(uint8 _stage) public onlyEngine returns (uint _sum) {
        _sum = workStages[_stage].sum;

        workStages[_stage].sum = 0;
    }

    function voteForCashBack() public onlyState(States.Workflow) {
        voteForCashBackInPercentOfWeight(msg.sender, 100);
    }

    function cancelVoteForCashBack() public onlyState(States.Workflow) {
        voteForCashBackInPercentOfWeight(msg.sender, 0);
    }

    function voteForCashBackInPercentOfWeight(uint8 _percent) public onlyState(States.Workflow) {
        uint8 currentWeight = cashBackWeight[msg.sender];
        uint supply;
        uint part;

        for (uint8 i; i < products.length; i += 1) {
            supply += IdeaSubCoin(products[i]).totalSupply();
            part += IdeaSubCoin(products[i]).balanceOf(msg.sender);
        }

        cashBackVotes += ((part ** 10) / supply) * (_percent - currentWeight);
        cashBackWeight[msg.sender] = _percent;

        if (cashBackVotes > 50 ** 10) {
            projectWorkFail();
        }
    }

    function updateVotesOnTransfer(address _from, address _to) public onlyProduct {
        if (isWorkflowState()) {
            voteForCashBackInPercentOfWeight(_from, cashBackWeight[_from]);
            voteForCashBackInPercentOfWeight(_to, cashBackWeight[_to]);
        }
    }

    function makeProduct(
        string _name,
        string _symbol,
        uint _price,
        uint _limit
    ) public onlyState(States.Initial) onlyOwner returns (address _productAddress) {
        require(products.length <= 25);

        IdeaSubCoin product = new IdeaSubCoin(msg.sender, _name, _symbol, _price, _limit, engine);

        products.push(address(product));

        return address(product);
    }

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
}