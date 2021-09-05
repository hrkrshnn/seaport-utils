pragma solidity ^0.8.14;

import {TypeHelpers} from "src/TypeHelpers.sol";
import "seaport/lib/ConsiderationEnums.sol";

import "forge-std/Test.sol";


contract TypeHelpersTest is Test {
    function setUp() external {
    }

    function testSanity() external {
        assertEq(uint(1), 1, "ok");
    }

    function testBasicOrderTypeToOrderType() external pure {
        assert(
            TypeHelpers.basicOrderTypeToOrderType(
                BasicOrderType.ERC1155_TO_ERC20_PARTIAL_OPEN
            ) == OrderType.PARTIAL_OPEN
        );
        assert(
            TypeHelpers.basicOrderTypeToOrderType(
                BasicOrderType.ERC1155_TO_ERC20_FULL_OPEN
            ) == OrderType.FULL_OPEN
        );
        assert(
            TypeHelpers.basicOrderTypeToOrderType(
                BasicOrderType.ERC1155_TO_ERC20_PARTIAL_RESTRICTED
            ) == OrderType.PARTIAL_RESTRICTED
        );
        assert(
            TypeHelpers.basicOrderTypeToOrderType(
                BasicOrderType.ERC1155_TO_ERC20_FULL_RESTRICTED
            ) == OrderType.FULL_RESTRICTED
        );
        assert(
            TypeHelpers.basicOrderTypeToOrderType(
                BasicOrderType.ERC20_TO_ERC721_FULL_RESTRICTED
            ) == OrderType.FULL_RESTRICTED
        );
    }

    function testRoute() external pure {
        assert(
            TypeHelpers.route(
                BasicOrderType.ERC1155_TO_ERC20_PARTIAL_OPEN
            ) ==
            BasicOrderRouteType.ERC1155_TO_ERC20
        );
        assert(
            TypeHelpers.route(
                BasicOrderType.ERC1155_TO_ERC20_FULL_RESTRICTED
            ) ==
            BasicOrderRouteType.ERC1155_TO_ERC20
        );
        assert(
            TypeHelpers.route(
                BasicOrderType.ERC1155_TO_ERC20_PARTIAL_RESTRICTED
            ) ==
            BasicOrderRouteType.ERC1155_TO_ERC20
        );
        assert(
            TypeHelpers.route(
                BasicOrderType.ERC1155_TO_ERC20_FULL_OPEN
            ) == BasicOrderRouteType.ERC1155_TO_ERC20
        );
        assert(
            TypeHelpers.route(
                BasicOrderType.ERC20_TO_ERC721_FULL_RESTRICTED
            ) == BasicOrderRouteType.ERC20_TO_ERC721
        );
    }

    function testAdditionalRecipientsItemType() external pure {
        assert(
            TypeHelpers.additionalRecipientsItemType(
                BasicOrderType.ERC20_TO_ERC721_FULL_RESTRICTED
            ) ==
            ItemType.ERC20
        );
        assert(
            TypeHelpers.additionalRecipientsItemType(
                BasicOrderType.ERC1155_TO_ERC20_FULL_OPEN
            ) ==
            ItemType.ERC20
        );
        assert(
            TypeHelpers.additionalRecipientsItemType(
                BasicOrderType.ETH_TO_ERC721_PARTIAL_OPEN
            ) ==
            ItemType.NATIVE
        );
        assert(
            TypeHelpers.additionalRecipientsItemType(
                BasicOrderType.ERC1155_TO_ERC20_PARTIAL_RESTRICTED
            ) ==
            ItemType.ERC20
        );
    }

    /// Fuzz that the additional recipient is always ETH or ERC20.
    function testFuzzAdditionalRecipientsItemType(uint8 rand) external {
        vm.assume(rand <= uint8(type(BasicOrderType).max));
        BasicOrderType basicOrderType = BasicOrderType(rand);

        ItemType itemType = TypeHelpers.additionalRecipientsItemType(basicOrderType);
        assert(itemType == ItemType.NATIVE || itemType == ItemType.ERC20);
    }

    /// Definition of the received item is the item type of the initial consideration
    /// a bit confusing!
    function testReceivedItemType() external pure {
        assert(
            TypeHelpers.receivedItemType(
                BasicOrderType.ERC20_TO_ERC721_FULL_RESTRICTED
            ) ==
            ItemType.ERC20
        );
        assert(
            TypeHelpers.receivedItemType(
                BasicOrderType.ERC20_TO_ERC721_FULL_OPEN
            ) ==
            ItemType.ERC20
        );
        assert(
            TypeHelpers.receivedItemType(
                BasicOrderType.ERC1155_TO_ERC20_FULL_OPEN
            ) ==
            ItemType.ERC1155
        );
        assert(
            TypeHelpers.receivedItemType(
                BasicOrderType.ERC1155_TO_ERC20_PARTIAL_OPEN
            ) ==
            ItemType.ERC1155
        );

    }

    function testOfferedItemType() external pure {
        assert(
            TypeHelpers.offeredItemType(
                BasicOrderType.ERC20_TO_ERC721_FULL_RESTRICTED
            ) ==
            ItemType.ERC721
        );
        assert(
            TypeHelpers.offeredItemType(
                BasicOrderType.ERC20_TO_ERC721_FULL_OPEN
            ) ==
            ItemType.ERC721
        );
        assert(
            TypeHelpers.offeredItemType(
                BasicOrderType.ERC1155_TO_ERC20_FULL_OPEN
            ) ==
            ItemType.ERC20
        );
    }
}
