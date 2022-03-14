// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import {TLD, DDDInfo} from "./utils/StructDeclaration.sol";
import {TokenURIHelper} from "./utils/TokenURIHelper.sol";

contract DevDaoDomain is ERC721Enumerable, ERC721Burnable {
    uint256 constant MIN_LENGTH = 3;
    uint256 constant MAX_LENGTH = 12;

    mapping(uint256 => DDDInfo) private domains;

    error NotTokenOwner(); // Caller is not the token owner
    error DomainNameTooShort(uint256 minLength); // Restrict names to 3+ characters
    error DomainNameTooLong(uint256 maxLength); // Restrict names to 10- characters
    error NonExistentToken(uint256 tokenId); // The token doesn't exist

    constructor() ERC721("DDD", "DevDao Domains") {}

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!_exists(_tokenId)) revert NonExistentToken(_tokenId);

        return TokenURIHelper.getJSON(_tokenId, domains[_tokenId]);
    }

    function _burn(uint256 _tokenId) internal override {
        super._burn(_tokenId);
        delete domains[_tokenId];
    }

    function mint(string memory _domain) public returns (uint256 tokenId) {
        if (bytes(_domain).length < MIN_LENGTH)
            revert DomainNameTooShort(MIN_LENGTH);
        if (bytes(_domain).length > MAX_LENGTH)
            revert DomainNameTooLong(MAX_LENGTH);

        tokenId = getTokenId(_domain);

        super._safeMint(msg.sender, tokenId);

        domains[tokenId].domain = _domain;
    }

    function mintWithInfo(DDDInfo memory _data)
        public
        returns (uint256 tokenId)
    {
        tokenId = mint(_data.domain);
        setInfo(_data.domain, _data);
    }

    function setInfo(string memory _domain, DDDInfo memory _data) public {
        uint256 _tokenId = getTokenId(_domain);
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();

        domains[_tokenId].showAddress = _data.showAddress;
        domains[_tokenId].showUrl = _data.showUrl;
        domains[_tokenId].showTwitter = _data.showTwitter;
        domains[_tokenId].showDiscord = _data.showDiscord;
        domains[_tokenId].showGithub = _data.showGithub;
        domains[_tokenId].showD4R = _data.showD4R;

        domains[_tokenId].addr = _data.addr;
        domains[_tokenId].url = _data.url;
        domains[_tokenId].twitter = _data.twitter;
        domains[_tokenId].discord = _data.discord;
        domains[_tokenId].github = _data.github;
    }

    function setAddress(
        string memory _domain,
        bool _showAddress,
        address _address
    ) public {
        uint256 _tokenId = getTokenId(_domain);
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();
        domains[_tokenId].showAddress = _showAddress;
        domains[_tokenId].addr = _address;
    }

    function setUrl(
        string memory _domain,
        bool _showUrl,
        string calldata _url
    ) public {
        uint256 _tokenId = getTokenId(_domain);
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();
        domains[_tokenId].showUrl = _showUrl;
        domains[_tokenId].url = _url;
    }

    function setTwitter(
        string memory _domain,
        bool _showTwitter,
        string calldata _twitter
    ) public {
        uint256 _tokenId = getTokenId(_domain);
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();
        domains[_tokenId].showTwitter = _showTwitter;
        domains[_tokenId].twitter = _twitter;
    }

    function setDiscord(
        string memory _domain,
        bool _showDiscord,
        string calldata _discord
    ) public {
        uint256 _tokenId = getTokenId(_domain);
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();
        domains[_tokenId].showDiscord = _showDiscord;
        domains[_tokenId].discord = _discord;
    }

    function setGithub(
        string memory _domain,
        bool _showGithub,
        string calldata _github
    ) public {
        uint256 _tokenId = getTokenId(_domain);
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();
        domains[_tokenId].showGithub = _showGithub;
        domains[_tokenId].github = _github;
    }

    function getInfoByTokenId(uint256 _tokenId)
        public
        view
        returns (DDDInfo memory info)
    {
        return domains[_tokenId];
    }

    function getInfoByDomain(string memory _domain)
        public
        view
        returns (DDDInfo memory info)
    {
        return domains[getTokenId(_domain)];
    }

    function domainOfOwnerByIndex(address owner, uint256 index)
        public
        view
        returns (string memory)
    {
        uint256 tokenId = tokenOfOwnerByIndex(owner, index);
        return domains[tokenId].domain;
    }

    function getTokenId(string memory _domain) internal pure returns (uint256) {
        return uint256(keccak256(bytes(_domain)));
    }

    // Overrides required by solidity
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
