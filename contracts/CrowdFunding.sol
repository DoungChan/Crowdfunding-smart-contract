// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations;
        uint256 donationCount;
    }
    mapping(uint256 => Campaign) public campaigns;

    uint256 public campaignCount = 0;

    function createCampafign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        // create a new campaign
        Campaign storage campaign = campaigns[campaignCount];

        // is everything ok?
        require(campaign.deadline < block.timestamp, "Deadline is in the past");

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.image = _image;
        campaign.amountCollected = 0;

        campaignCount++;

        return campaignCount - 1;
    }

    function donateToCapaign(uint256 _id) public payable {
        uint256 amount = msg.value;

        require(
            block.timestamp < campaigns[_id].deadline,
            "Campaign has ended"
        );
        require(msg.value > 0, "You cannot donate 0 ether");

        Campaign storage campaign = campaigns[_id];

        campaign.donationCount++;
        campaign.donations.push(amount);
        campaign.donators.push(msg.sender);

        (bool success, ) = campaign.owner.call{value: amount}("");
        require(success, "Transfer failed.");
        if (success) {
            campaign.amountCollected += amount;
        }
    }

    function getDonations(uint256 _id)
        public
        view
        returns (uint256[] memory, address[] memory)
    {
        return (campaigns[_id].donations, campaigns[_id].donators);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory _campaigns = new Campaign[](campaignCount);
        for (uint256 i = 0; i < campaignCount; i++) {
            _campaigns[i] = campaigns[i];
        }
        return _campaigns;
    }
}
