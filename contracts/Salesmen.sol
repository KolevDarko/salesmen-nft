// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CheekySnails is ERC721A, Ownable {
    uint256 public MAX_SUPPLY = 5555;
    uint256 public FREE_LIMIT = 777;
    uint256 public EARLY_LIMIT = 2777;
    uint256 public EARLY_PRICE = 0.01 ether;
    uint256 public MAX_MINTS = 20;
    uint256 public MAX_WHITELIST = 5;
    uint256 public PRICE = 0.2 ether;
    uint256 public WHITELIST_PRICE = 0.1 ether;
    string public projName = "Cheeky Snails";
    string public projSym = "SNA";
    // 0 - minting disabled
    // 1 - whitelist mint
    // 2 - public mint
    uint8 public MINT_STATE = 0;
    string public uriPrefix = "";
    mapping(address => uint8) public allowList;

    constructor() ERC721A(projName, projSym) {
        setUriPrefix("https://api.salesmen.xyz/placeholder/");
    }

    function addToWhitelist(address[] calldata addresses, uint8 numTokens)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            allowList[addresses[i]] = numTokens;
        }
    }

    function whitelistMint(uint8 numTokens) public payable {
        require(MINT_STATE == 1, "Whitelist sale not started");
        require(allowList[msg.sender] >= numTokens, "not allowed");
        require(msg.value >= WHITELIST_PRICE * numTokens, "not enough eth");
        allowList[msg.sender] = allowList[msg.sender] - numTokens;
        _safeMint(msg.sender, numTokens);
    }

    function mint(uint256 numTokens) public payable {
        require(MINT_STATE == 2, "Public sale not started");
        require(
            totalSupply() + numTokens <= MAX_SUPPLY,
            "max supply is reached"
        );
        require(
            numTokens > 0 && numTokens <= MAX_MINTS,
            "minting too many tokens"
        );
        require(msg.value >= PRICE * numTokens, "not enough eth");
        _safeMint(msg.sender, numTokens);
    }

    function setMintState(uint8 newMintState) public onlyOwner {
        MINT_STATE = newMintState;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return string(abi.encodePacked(_baseURI(), Strings.toString(_tokenId)));
    }

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }

    function setWhitelistPrice(uint256 newPrice) public onlyOwner {
        WHITELIST_PRICE = newPrice;
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        PRICE = newPrice;
    }

    function setMaxWhitelistMints(uint256 newMax) public onlyOwner {
        MAX_WHITELIST = newMax;
    }

    function setMaxMints(uint256 newMax) public onlyOwner {
        MAX_MINTS = newMax;
    }

    function setSupply(uint256 newSupply) public onlyOwner {
        MAX_SUPPLY = newSupply;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Nothing to withdraw");
        Address.sendValue(payable(owner()), balance);
    }

    fallback() external payable {}

    receive() external payable {}
}
