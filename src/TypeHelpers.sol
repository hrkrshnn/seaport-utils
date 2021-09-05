pragma solidity ^0.8.14;

import "seaport/lib/ConsiderationEnums.sol";

library TypeHelpers {
    function basicOrderTypeToOrderType(BasicOrderType basicOrderType) pure internal returns (OrderType orderType) {
        assembly {
            orderType := and(basicOrderType, 3)
        }
    }

    function route(
        BasicOrderType basicOrderType
    ) pure internal returns (BasicOrderRouteType _route) {
        assembly {
            _route := shr(2, basicOrderType)
        }
    }

    function additionalRecipientsItemType(
        BasicOrderType basicOrderType
    ) pure internal returns (ItemType _additionalRecipientsItemType) {
        BasicOrderRouteType _route = route(basicOrderType);
        assembly {
            _additionalRecipientsItemType := gt(_route, 1)
        }
    }

    /// That is, consideration
    /// TODO rename
    function receivedItemType(
        BasicOrderType basicOrderType
    ) pure internal returns (ItemType _receivedItemType) {
        BasicOrderRouteType _route = route(basicOrderType);
        assembly {
            // If route > 2, receivedItemType is route - 2. If route is 2,
            // the receivedItemType is ERC20 (1). Otherwise, it is Eth (0).
            _receivedItemType := add(
                mul(sub(_route, 2), gt(_route, 2)),
                eq(_route, 2)
            )
        }
    }

    function offeredItemType(
        BasicOrderType basicOrderType
    ) pure internal returns (ItemType _offeredItemType) {
        ItemType _receivedItemType = receivedItemType(basicOrderType);
        BasicOrderRouteType _route = route(basicOrderType);
        ItemType _additionalRecipientsItemType = additionalRecipientsItemType(basicOrderType);

        assembly {
            let offerTypeIsAdditionalRecipientsType := gt(_route, 3)

            _offeredItemType := sub(
                add(_route, mul(iszero(_additionalRecipientsItemType), 2)),
                mul(
                    offerTypeIsAdditionalRecipientsType,
                    add(_receivedItemType, 1)
                )
            )
        }
    }
}
