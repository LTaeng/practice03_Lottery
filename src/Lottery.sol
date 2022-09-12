// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Lottery {
    uint nowTime;
    bool isClaim;
    address[] list;
    mapping(address => uint16) bet;
    mapping(address => uint256) balaces;

    uint256 received_msg_value;

    constructor () {
        received_msg_value = 0;
        nowTime = block.timestamp;
        isClaim = false;
    }


    function buy(uint16 num) public payable {
        if (isClaim) {
            nowTime = block.timestamp;
            isClaim = false;
            list = new address[](0);
        }

        require(msg.value == 0.1 ether);
        require(bet[msg.sender] != num + 1);
        require(block.timestamp < nowTime + 24 hours);

        bet[msg.sender] = num + 1;
        received_msg_value += msg.value;
        list.push(msg.sender);
    }

    modifier afterPhase() {
        require(block.timestamp >= nowTime + 24 hours);
        _;
    }

    function draw() public afterPhase {
        require(!isClaim);

        uint totalWin = 0;
        for (uint i = 0; i < list.length; ++i) {
            address sender = list[i];
            uint16 num = bet[sender];

            if (num - 1 == winningNumber())
                totalWin++;
        }

        if (totalWin != 0) {
            uint256 val = received_msg_value / totalWin;
            received_msg_value = 0;

            for (uint i = 0; i < list.length; ++i) {
                address sender = list[i];
                uint16 num = bet[sender];

                bet[sender] = 0;
                if (num - 1 == winningNumber())
                    balaces[sender] += val;
            }
        }
    }

    function claim() public afterPhase {
        isClaim = true;

        uint amount = balaces[msg.sender];
        if (amount != 0) {
            balaces[msg.sender] = 0;
            payable(msg.sender).call{value: amount}("");
        }
    }

    function winningNumber() public pure returns (uint16) {
        return 10;
    }

}