
pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint256 amount);
}

contract Presale {
    address public beneficiary;
    uint256 public amountRaised;
    uint256 public deadline;
    uint256 public price;
    uint256 public hardCap;
    uint256 public softCap;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool softCapReached = false;
    bool fundingGoalReached = false;
    bool presaleClosed = false;

    event GoalReached(address recipient, uint256 totalAmountRaised);
    event SoftCapReached(uint256 softCap);
    event FundTransfer(address backer, uint256 amount, bool isContribution);

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
        hardCap = 4000 * 1 ether;
        softCap = 400 * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = 4000;//each ETH = 4000 XSH
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable {
        require(!presaleClosed);
        require(msg.value >= 0.01 * 1 ether);
        require(amountRaised + msg.value <= hardCap);

        if (!softCapReached && amountRaised < softCap && amountRaised + msg.value >= softCap) {
            softCapReached = true;
            SoftCapReached(softCap);
        }

        uint256 amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount * price);
        FundTransfer(msg.sender, amount * price, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() afterDeadline {
        if (amountRaised >= hardCap){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        presaleClosed = true;
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
            uint256 remainingCoins = (hardCap - amountRaised) * price;
            
            uint256 amount = balanceOf[msg.sender];
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
