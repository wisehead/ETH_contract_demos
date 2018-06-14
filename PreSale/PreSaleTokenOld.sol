
pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount);
}

contract Presale {
    address public beneficiary;
    uint public fundingGoal;
    uint public softCap;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool softCapReached = false;
    bool fundingGoalReached = false;
    bool presaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event SoftCapReached(uint softCap);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constructor function
     *
     * Setup the owner
     */
    function Presale(
        address ifSuccessfulSendTo,
        uint durationInMinutes,
        address addressOfTokenUsedAsReward
    ) {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = 3360 * 1 ether;
        softCap = 336 * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = 2500;//each ETH = 3000 * XSHB.
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable {
        require(!presaleClosed);
        require(msg.value >= 5 * 1 ether);
        require(amountRaised + msg.value <= fundingGoal);

        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        FundTransfer(msg.sender, amount, true);
    }
    
    function balanceOf(address _owner)
        constant
        public
        returns (uint256)
    {
        return balanceOf[_owner];
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        presaleClosed = true;
    }

    function checkSoftCapReached() {
        if (!softCapReached && amountRaised >= softCap) {
            softCapReached = true;
            SoftCapReached(softCap);
        }
    }
    

    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
     * the amount they contributed.
     */
    function safeWithdrawal() afterDeadline {
        if (!softCapReached) {
            uint remainingCoins = (fundingGoal - amountRaised) * price;
            
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if (softCapReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                //If we fail to send the funds to beneficiary, unlock funders balance
                fundingGoalReached = false;
            }
        }
    }
}
