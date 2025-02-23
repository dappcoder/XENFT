// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// mapping: NFT tokenId => MintInfo (used in tokenURI generation)
// MintInfo encoded as:
//      term (uint16)
//      | maturityTs (uint64)
//      | rank (uint128)
//      | amp (uint16)
//      | eaa (uint16)
//      | series (uint8):
//          [7] isRare
//          [6] isLimited
//          [0-5] powerSeriesIdx
//      | redeemed (uint8)
library MintInfo {
    /**
        @dev helper to convert Bool to U256 type and make compiler happy
     */
    function toU256(bool x) internal pure returns (uint256 r) {
        assembly {
            r := x
        }
    }

    /**
        @dev encodes MintInfo record from its props
     */
    function encodeMintInfo(
        uint256 term,
        uint256 maturityTs,
        uint256 rank,
        uint256 amp,
        uint256 eaa,
        uint256 series,
        bool redeemed
    ) public pure returns (uint256 info) {
        info = info | (toU256(redeemed) & 0xFF);
        info = info | ((series & 0xFF) << 8);
        info = info | ((eaa & 0xFFFF) << 16);
        info = info | ((amp & 0xFFFF) << 32);
        info = info | ((rank & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) << 48);
        info = info | ((maturityTs & 0xFFFFFFFFFFFFFFFF) << 176);
        info = info | ((term & 0xFFFF) << 240);
    }

    /**
        @dev decodes MintInfo record and extracts all of its props
     */
    function decodeMintInfo(uint256 info)
        public
        pure
        returns (
            uint256 term,
            uint256 maturityTs,
            uint256 rank,
            uint256 amp,
            uint256 eaa,
            uint256 series,
            bool rare,
            bool limited,
            bool redeemed
        )
    {
        term = uint16(info >> 240);
        maturityTs = uint64(info >> 176);
        rank = uint128(info >> 48);
        amp = uint16(info >> 32);
        eaa = uint16(info >> 16);
        series = uint8(info >> 8) & 0x3F;
        rare = (uint8(info >> 8) & 0x80) > 0;
        limited = (uint8(info >> 8) & 0x40) > 0;
        redeemed = uint8(info) == 1;
    }

    /**
        @dev extracts `term` prop from encoded MintInfo
     */
    function getTerm(uint256 info) public pure returns (uint256 term) {
        (term, , , , , , , , ) = decodeMintInfo(info);
    }

    /**
        @dev extracts `maturityTs` prop from encoded MintInfo
     */
    function getMaturityTs(uint256 info) public pure returns (uint256 maturityTs) {
        (, maturityTs, , , , , , , ) = decodeMintInfo(info);
    }

    /**
        @dev extracts `rank` prop from encoded MintInfo
     */
    function getRank(uint256 info) public pure returns (uint256 rank) {
        (, , rank, , , , , , ) = decodeMintInfo(info);
    }

    /**
        @dev extracts `AMP` prop from encoded MintInfo
     */
    function getAMP(uint256 info) public pure returns (uint256 amp) {
        (, , , amp, , , , , ) = decodeMintInfo(info);
    }

    /**
        @dev extracts `EAA` prop from encoded MintInfo
     */
    function getEAA(uint256 info) public pure returns (uint256 eaa) {
        (, , , , eaa, , , , ) = decodeMintInfo(info);
    }

    /**
        @dev extracts `redeemed` prop from encoded MintInfo
     */
    function getSeries(uint256 info)
        public
        pure
        returns (
            uint256 series,
            bool rare,
            bool limited
        )
    {
        (, , , , , series, rare, limited, ) = decodeMintInfo(info);
    }

    /**
        @dev extracts `redeemed` prop from encoded MintInfo
     */
    function getRedeemed(uint256 info) public pure returns (bool redeemed) {
        (, , , , , , , , redeemed) = decodeMintInfo(info);
    }
}
