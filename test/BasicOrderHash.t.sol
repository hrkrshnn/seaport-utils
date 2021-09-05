pragma solidity ^0.8.14;

import {BasicOrderHash, additionalRecipientToken} from "src/BasicOrderHash.sol";

import "seaport/lib/ConsiderationEnums.sol";
import "seaport/lib/ConsiderationStructs.sol";

import "forge-std/Test.sol";

contract BasicOrderHashTest is Test {
    BasicOrderHash immutable basicOrderHash = new BasicOrderHash();

    function setUp() external {
    }

    function testSanity() external {
        assertEq(uint(1), 1, "ok");
    }

    /// Requires a --fork-url to succeed, although it can be avoided
    function testBasicOrderHash() external {
        AdditionalRecipient[] memory totalAdditionalRecipients = new AdditionalRecipient[](1);
        totalAdditionalRecipients[0] = AdditionalRecipient({
            amount: 6250000000000000,
            recipient: payable(0x5b3256965e7C3cF26E11FCAf296DfC8807C01073)
        });

        BasicOrderParameters memory basicOrderParameters = BasicOrderParameters({
            considerationToken: 0x495f947276749Ce646f68AC8c248420045cb7b5e,
            considerationIdentifier: 56225169322858599289437147468138695293781176124058194708552719117832467513345,
            considerationAmount: 1,
            offerer: payable(0x0b16F27877A3dB0dB994F61949Cf7fD1bD602679),
            zone: 0x004C00500000aD104D7DBd00e3ae0A5C00560C00,
            offerToken: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            offerIdentifier: 0,
            offerAmount: 250000000000000000,
            basicOrderType: BasicOrderType.ERC1155_TO_ERC20_PARTIAL_OPEN,
            startTime: 0,
            endTime: 1655512515,
            zoneHash: 0x0000000000000000000000000000000000000000000000000000000000000000,
            salt: 42031123743982896,
            offererConduitKey: 0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000,
            fulfillerConduitKey: 0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000,
            totalOriginalAdditionalRecipients: 1,
            additionalRecipients: totalAdditionalRecipients,
            signature: hex"31109f2c13afc0fb669bb6581270ea3e637be340be25011e71c1b8e069c135fc7323b0eb5bcf4c15d22b294c42c506f2023dcad32ba6fc07125e8ab62f7f060f1b"
        });

        assert(
            additionalRecipientToken({
                offerToken: basicOrderParameters.offerToken,
                considerationToken: basicOrderParameters.considerationToken,
                basicOrderType: basicOrderParameters.basicOrderType
            }) ==
            basicOrderParameters.offerToken
        );

        bytes32 hash = basicOrderHash.basicOrderHash(basicOrderParameters);
        assertEq(hash, 0xb51cf65f4287a8a1e19ecfb5fb2758967ae0c243282bb37453daaca3987e5844);
    }

}
