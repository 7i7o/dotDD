// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

import {TLD, DDDInfo} from "./utils/StructDeclaration.sol";

import {TokenURIHelper} from "./utils/TokenURIHelper.sol";

contract DevDaoDomain is ERC721, ERC721Burnable {
    // string public constant TLD = "devdao";

    mapping(uint256 => DDDInfo) private domains;

    error NotTokenOwner(); // Caller is not the token owner
    error DomainNameTooShort(uint256 minLength); // Restrict names to 3+ characters
    // error DomainNameTooLong(uint256 maxLength); // Restrict names to 10- characters
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
        if (bytes(_domain).length < 3) revert DomainNameTooShort(3);
        // if (bytes(_domain).length > 10) revert DomainNameTooLong(10);

        tokenId = uint256(keccak256(bytes(_domain)));

        super._safeMint(msg.sender, tokenId);

        domains[tokenId].domain = _domain;
    }

    function mintWithInfo(DDDInfo memory _data) public {
        uint256 tokenId = mint(_data.domain);
        setInfo(tokenId, _data);
    }

    function setInfo(uint256 _tokenId, DDDInfo memory _data) public {
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
        uint256 _tokenId,
        bool _showAddress,
        address _address
    ) public {
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();
        domains[_tokenId].showAddress = _showAddress;
        domains[_tokenId].addr = _address;
    }

    function setUrl(
        uint256 _tokenId,
        bool _showUrl,
        string calldata _url
    ) public {
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();
        domains[_tokenId].showUrl = _showUrl;
        domains[_tokenId].url = _url;
    }

    function setTwitter(
        uint256 _tokenId,
        bool _showTwitter,
        string calldata _twitter
    ) public {
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();
        domains[_tokenId].showTwitter = _showTwitter;
        domains[_tokenId].twitter = _twitter;
    }

    function setDiscord(
        uint256 _tokenId,
        bool _showDiscord,
        string calldata _discord
    ) public {
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();
        domains[_tokenId].showDiscord = _showDiscord;
        domains[_tokenId].discord = _discord;
    }

    function setGithub(
        uint256 _tokenId,
        bool _showGithub,
        string calldata _github
    ) public {
        if (ownerOf(_tokenId) != msg.sender) revert NotTokenOwner();
        domains[_tokenId].showGithub = _showGithub;
        domains[_tokenId].github = _github;
    }

    // function getInfo(uint256 _tokenId)
    //     public
    //     view
    //     returns (DDDInfo memory info)
    // {
    //     return domains[_tokenId];
    // }

    function getInfo(string memory _domain)
        public
        view
        returns (DDDInfo memory info)
    {
        uint256 _tokenId = uint256(keccak256(bytes(_domain)));
        return domains[_tokenId];
    }
}
