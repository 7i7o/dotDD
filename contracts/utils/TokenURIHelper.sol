// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/Strings.sol";
// import {Base64} from "./Base64.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {TLD, DDDInfo} from "./StructDeclaration.sol";

library TokenURIHelper {
    using Strings for uint256;

    string constant svgHeader =
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="500" height="500" fill="none"><rect fill="url(#F)" width="500" height="500" rx="25"></rect><defs><linearGradient id="F" x1="1" y1="0" x2="0" y2="1"><stop offset="0" style="stop-color:#000"/><stop offset="1" style="stop-color:#444" /></linearGradient><style type="text/css">/* <![CDATA[ */a{cursor: pointer;}a text{fill:#fff;text-decoration:none;}a:hover,a:active{outline:dotted 1px #fff;border-radius:5px;}/* ]]> */</style></defs><defs><filter id="f2" x="0" y="0" width="200%" height="200%"><feColorMatrix result="matrixOut" in="offOut" type="matrix" values="0.8 0 0 0 0 0 0.8 0 0 0 0 0 0.8 0 0 0 0 0 .4 0" /><feGaussianBlur result="blurOut" in="offOut" stdDeviation="1.5"/><feBlend in="SourceGraphic" in2="blurOut" mode="normal" /></filter></defs><rect x="10" y="10" fill="none" width="480" height="480" rx="20" stroke="#fff" stroke-width="2"></rect><g fill="#fff" font-size="30" font-weight="100" font-family="sans-serif" filter="url(#f2)"><text x="440" y="80" text-anchor="end" font-size="36" font-weight="400">';
    string constant svgD4R =
        '<svg x="68" y="145" xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width=".7" stroke-linecap="round" stroke-linejoin="round"><circle cx="13" cy="12" r="10" /><text font-size="8" x="13" y="15" text-anchor="middle" stroke="none" fill="#fff">D_D</text></svg><text x="100" y="170">#';
    string constant svgTwitter =
        '<svg x="70" y="198" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><path d="M23 3a10.9 10.9 0 0 1-3.14 1.53 4.48 4.48 0 0 0-7.86 3v1A10.66 10.66 0 0 1 3 4s-4 9 5 13a11.64 11.64 0 0 1-7 2c9 5 20 0 20-11.5a4.5 4.5 0 0 0-.08-.83A7.72 7.72 0 0 0 23 3z" /></svg><text x="100" y="220">';
    string constant svgDiscord =
        '<svg x="69" y="248" xmlns="http://www.w3.org/2000/svg" width="26" height="24" viewBox="-10 0 85 55" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M60.1045 4.8978C55.5792 2.8214 50.7265 1.2916 45.6527 0.41542C45.5603 0.39851 45.468 0.440769 45.4204 0.525289C44.7963 1.6353 44.105 3.0834 43.6209 4.2216C38.1637 3.4046 32.7345 3.4046 27.3892 4.2216C26.905 3.0581 26.1886 1.6353 25.5617 0.525289C25.5141 0.443589 25.4218 0.40133 25.3294 0.41542C20.2584 1.2888 15.4057 2.8186 10.8776 4.8978C10.8384 4.9147 10.8048 4.9429 10.7825 4.9795C1.57795 18.7309 -0.943561 32.1443 0.293408 45.3914C0.299005 45.4562 0.335386 45.5182 0.385761 45.5576C6.45866 50.0174 12.3413 52.7249 18.1147 54.5195C18.2071 54.5477 18.305 54.5139 18.3638 54.4378C19.7295 52.5728 20.9469 50.6063 21.9907 48.5383C22.0523 48.4172 21.9935 48.2735 21.8676 48.2256C19.9366 47.4931 18.0979 46.6 16.3292 45.5858C16.1893 45.5041 16.1781 45.304 16.3068 45.2082C16.679 44.9293 17.0513 44.6391 17.4067 44.3461C17.471 44.2926 17.5606 44.2813 17.6362 44.3151C29.2558 49.6202 41.8354 49.6202 53.3179 44.3151C53.3935 44.2785 53.4831 44.2898 53.5502 44.3433C53.9057 44.6363 54.2779 44.9293 54.6529 45.2082C54.7816 45.304 54.7732 45.5041 54.6333 45.5858C52.8646 46.6197 51.0259 47.4931 49.0921 48.2228C48.9662 48.2707 48.9102 48.4172 48.9718 48.5383C50.038 50.6034 51.2554 52.5699 52.5959 54.435C52.6519 54.5139 52.7526 54.5477 52.845 54.5195C58.6464 52.7249 64.529 50.0174 70.6019 45.5576C70.6551 45.5182 70.6887 45.459 70.6943 45.3942C72.1747 30.0791 68.2147 16.7757 60.1968 4.9823C60.1772 4.9429 60.1437 4.9147 60.1045 4.8978Z" /><circle cx="24" cy="30" r="7" fill="#fff" stroke-width="0" /><circle cx="47.5" cy="30" r="7" fill="#fff" stroke-width="0" /></svg><text x="100" y="270">';
    string constant svgGithub =
        '<svg x="70" y="298" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22" /></svg><text x="100" y="320">';
    string constant svgUrl =
        '<svg x="70" y="348" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg><a xlink:href="';
    string constant svgUrlEnd =
        '" target="_blank"><text x="100" y="370">Personal Website</text></a>';
    string constant svgAddress =
        '<svg x="70" y="398" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"><path d="M12 1L18 12L12 15L6 12z" /><path d="M12 18L18 15L12 23L6 15z" /></svg><text x="100" y="416" font-size="16">';
    string constant svgTextEnd = "</text>";
    string constant svgEnd = "</g></svg>";

    function getJSON(uint256 _tokenId, DDDInfo memory _data)
        internal
        pure
        returns (string memory)
    {
        string memory _strTokenId = Strings.toString(_tokenId);

        string memory finalSvg = getSVG(_data);

        string memory info;

        if (_data.showTwitter && bytes(_data.twitter).length > 0)
            info = string(abi.encodePacked('"twitter":"', _data.twitter, '",'));
        if (_data.showDiscord && bytes(_data.discord).length > 0)
            info = string(
                abi.encodePacked(info, '"discord":"', _data.discord, '",')
            );
        if (_data.showGithub && bytes(_data.github).length > 0)
            info = string(
                abi.encodePacked(info, '"github":"', _data.github, '",')
            );
        if (_data.showUrl && bytes(_data.url).length > 0)
            info = string(abi.encodePacked(info, '"url":"', _data.url, '",'));
        if (_data.showAddress && _data.addr != address(0x0))
            info = string(
                abi.encodePacked(
                    info,
                    '"address":"',
                    Strings.toHexString(uint256(uint160(_data.addr)), 20),
                    '",'
                )
            );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name":"DevDaoDomains","description":"Get your own .devdao domain on the Polygon Network!'
                        '","domain":"',
                        _data.domain,
                        '","tokenId":"',
                        _strTokenId,
                        '.devdao",',
                        info,
                        '"image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function getSVG(DDDInfo memory _data)
        internal
        pure
        returns (string memory svg)
    {
        svg = string(
            abi.encodePacked(svgHeader, _data.domain, ".", TLD, svgTextEnd)
        );

        string memory d4rNumber = "5577";
        if (_data.showD4R)
            svg = string(abi.encodePacked(svg, svgD4R, d4rNumber, svgTextEnd));
        if (_data.showTwitter)
            svg = string(
                abi.encodePacked(svg, svgTwitter, _data.twitter, svgTextEnd)
            );
        if (_data.showDiscord)
            svg = string(
                abi.encodePacked(svg, svgDiscord, _data.discord, svgTextEnd)
            );
        if (_data.showGithub)
            svg = string(
                abi.encodePacked(svg, svgGithub, _data.github, svgTextEnd)
            );
        if (_data.showUrl)
            svg = string(abi.encodePacked(svg, svgUrl, _data.url, svgUrlEnd));
        if (_data.showAddress)
            svg = string(
                abi.encodePacked(
                    svg,
                    svgAddress,
                    Strings.toHexString(uint256(uint160(_data.addr)), 20),
                    svgTextEnd
                )
            );

        svg = string(abi.encodePacked(svg, svgEnd));
    }
}
