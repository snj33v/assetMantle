package send

import (
	sdkTypes "github.com/cosmos/cosmos-sdk/types"
	"github.com/persistenceOne/persistenceSDK/modules/hub/share/constants"
)

func HandleMessage(context sdkTypes.Context, keeper Keeper, message Message) sdkTypes.Result {

	if error := keeper.transact(context, message); error != nil {
		return error.Result()
	}

	context.EventManager().EmitEvent(
		sdkTypes.NewEvent(
			sdkTypes.EventTypeMessage,
			sdkTypes.NewAttribute(sdkTypes.AttributeKeyModule, constants.AttributeValueCategory),
		),
	)

	return sdkTypes.Result{Events: context.EventManager().Events()}
}