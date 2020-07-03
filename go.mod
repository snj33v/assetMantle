module github.com/persistenceOne/assetMantle

go 1.14

require (
	cloud.google.com/go v0.60.1-0.20200701022403-b2554dbd94d5 // indirect
	github.com/CosmWasm/wasmd v0.8.2-0.20200615222734-a60300154552
	github.com/cosmos/cosmos-sdk v0.34.4-0.20200702031639-8f96ec0585a6
	github.com/otiai10/copy v1.2.0
	github.com/persistenceOne/persistenceSDK v0.0.0-20200622080109-8c07ace549aa
	github.com/spf13/cobra v1.0.0
	github.com/spf13/viper v1.7.0
	github.com/tendermint/go-amino v0.15.1
	github.com/tendermint/tendermint v0.34.0-dev1
	github.com/tendermint/tm-db v0.5.1
	go.etcd.io/bbolt v1.3.4 // indirect
	honnef.co/go/tools v0.0.1-2020.1.3
)

replace github.com/cosmos/cosmos-sdk v0.34.4 => github.com/cosmos/cosmos-sdk v0.34.4-0.20200702031639-8f96ec0585a6

replace github.com/tendermint/tendermint/libs/bech32 v0.33.5 => github.com/cosmos/cosmos-sdk/types/bech32 v0.34.4-0.20200702031639-8f96ec0585a6

replace github.com/tendermint/tendermint/crypto/multisig v0.33.5 => github.com/cosmos/cosmos-sdk/crypto/types/multisig v0.34.4-0.20200702031639-8f96ec0585a6

replace github.com/tendermint/tendermint/crypto/encoding/amino v0.33.5 => github.com/cosmos/cosmos-sdk/crypto v0.34.4-0.20200702031639-8f96ec0585a6

replace github.com/tendermint/tendermint/lite/proxy v0.33.5 => github.com/tendermint/tendermint/light/proxy v0.34.0-dev1

replace github.com/tendermint/tendermint/lite v0.33.5 => github.com/tendermint/tendermint/light v0.34.0-dev1

replace github.com/tendermint/tendermint/lite2 v0.33.5 => github.com/tendermint/tendermint/light v0.34.0-dev1

replace github.com/tendermint/tendermint/libs/kv v0.33.5 => github.com/tendermint/tendermint/abci v0.34.0-dev1
