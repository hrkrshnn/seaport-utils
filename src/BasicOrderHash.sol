pragma solidity ^0.8.15;

import "seaport/lib/ConsiderationStructs.sol";
import "seaport/lib/ConsiderationEnums.sol";
import "seaport/interfaces/ConsiderationInterface.sol";

import {TypeHelpers} from "src/TypeHelpers.sol";


ConsiderationInterface constant seaport = ConsiderationInterface(0x00000000006c3852cbEf3e08E8dF289169EdE581);

function additionalRecipientToken(
    address offerToken, address considerationToken, BasicOrderType basicOrderType
) pure returns (address token) {
    BasicOrderRouteType route = TypeHelpers.route(basicOrderType);
    return route > BasicOrderRouteType.ERC20_TO_ERC1155 ?
        offerToken :
        considerationToken;
}

// Creates a wrapper contract. Instead of fulfilling a basic order, it returns the hash
contract BasicOrderHash {
    /// Returns the orderHash for a basic order. This is a wrapper around Seaport's `getOrderHash`
    /// function.
    function basicOrderHash(BasicOrderParameters calldata parameters) public view returns (bytes32 orderHash) {
        BasicOrderType basicOrderType = parameters.basicOrderType;
        OrderType orderType = TypeHelpers.basicOrderTypeToOrderType(basicOrderType);
        ItemType receivedItemType = TypeHelpers.receivedItemType(basicOrderType);
        ItemType offeredItemType = TypeHelpers.offeredItemType(basicOrderType);
        ItemType additionalRecipientItemType = TypeHelpers.additionalRecipientsItemType(basicOrderType);

        ConsiderationItem memory primaryConsiderationItem =
            ConsiderationItem({
               itemType: receivedItemType,
               token: parameters.considerationToken,
               identifierOrCriteria: parameters.considerationIdentifier,
               startAmount: parameters.considerationAmount,
               endAmount: parameters.considerationAmount,
               recipient: parameters.offerer
            });


        ConsiderationItem[] memory consideration = new ConsiderationItem[](
            parameters.additionalRecipients.length + 1
        );

        consideration[0] = primaryConsiderationItem;

        ConsiderationItem memory additionalConsideration;
        address _additionalRecipientToken = additionalRecipientToken({
            offerToken: parameters.offerToken,
            considerationToken: parameters.considerationToken,
            basicOrderType: parameters.basicOrderType
        });

        for (
            uint256 recipientCount = 0;
            recipientCount < parameters.additionalRecipients.length;
            ++recipientCount
        ) {
            // Get the next additionalRecipient.
            AdditionalRecipient memory additionalRecipient = (
                parameters.additionalRecipients[recipientCount]
            );

            // TODO this need to be re-looked.
            additionalConsideration = ConsiderationItem({
                itemType: additionalRecipientItemType,
                token: _additionalRecipientToken,
                identifierOrCriteria: 0,
                startAmount: additionalRecipient.amount,
                endAmount: additionalRecipient.amount,
                recipient: additionalRecipient.recipient
            });

            consideration[recipientCount + 1] = additionalConsideration;
            /* TODO should we skip hashes? */
            if (
                recipientCount >=
                parameters.totalOriginalAdditionalRecipients
            ) {
                break;
            }
        }

        OfferItem[] memory offer = new OfferItem[](1);

        // Need to figure out what the offer item was
        // Usually, it's going to be an NFT: ERC721 / ERC1155
        // Actually, can also be ETH or ERC721.
        // Hmm, how does that work in terms of additional?
        offer[0] = OfferItem({
            itemType: offeredItemType,
            token: parameters.offerToken,
            identifierOrCriteria: parameters.offerIdentifier,
            startAmount: parameters.offerAmount,
            endAmount: parameters.offerAmount
        });


        OrderComponents memory order = OrderComponents({
            offerer: parameters.offerer,
            zone: parameters.zone,
            offer: offer,
            consideration: consideration,
            orderType: orderType,
            startTime: parameters.startTime,
            endTime: parameters.endTime,
            zoneHash: parameters.zoneHash,
            salt: parameters.salt,
            conduitKey: parameters.offererConduitKey,
            counter: seaport.getCounter(parameters.offerer)
        });

        return seaport.getOrderHash(order);

    }
    /// Returns the orderHash for a BasicOrder. Meant to share the same ABI as
    /// `fulfillBasicOrderHash` for easiness of scripting.
    function fulfillBasicOrder(BasicOrderParameters calldata parameters)
        external
        view
        returns (bytes32 orderHash)
    {
        return basicOrderHash(parameters);
    }

}
