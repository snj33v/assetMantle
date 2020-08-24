#add chain id in config
assetClient config chain-id test

#set env variables
NONCE="0"
SLEEP=6
PASSWD="123123123"
KEYRING="--keyring-backend os"
MODE="-b sync"

#Create users
ACCOUNT_NAME_1=account1$NONCE
ACCOUNT_NAME_2=account2$NONCE
ACCOUNT_NAME_3=account3$NONCE
ACCOUNT_NAME_4=account4$NONCE
assetClient keys add $ACCOUNT_NAME_1 $KEYRING
assetClient keys add $ACCOUNT_NAME_2 $KEYRING
assetClient keys add $ACCOUNT_NAME_3 $KEYRING
assetClient keys add $ACCOUNT_NAME_4 $KEYRING

#name users with their addresses
TEST=$(assetClient keys show -a test $KEYRING)
ACCOUNT_1=$(assetClient keys show -a $ACCOUNT_NAME_1 $KEYRING)
ACCOUNT_2=$(assetClient keys show -a $ACCOUNT_NAME_2 $KEYRING)
ACCOUNT_3=$(assetClient keys show -a $ACCOUNT_NAME_3 $KEYRING)
ACCOUNT_4=$(assetClient keys show -a $ACCOUNT_NAME_4 $KEYRING)

#Load coins in main
assetClient tx send $TEST $ACCOUNT_1 10000stake -y $KEYRING $MODE
sleep $SLEEP
#send coins in users
assetClient tx send $ACCOUNT_1 $ACCOUNT_3 110stake -y $KEYRING $MODE
sleep $SLEEP
assetClient tx send $ACCOUNT_3 $ACCOUNT_4 10stake -y $KEYRING $MODE
assetClient tx send $ACCOUNT_1 $ACCOUNT_2 100stake -y $KEYRING $MODE
sleep $SLEEP

#recursively send coins
assetClient tx send $ACCOUNT_1 $ACCOUNT_3 100stake -y $KEYRING $MODE
assetClient tx send $ACCOUNT_3 $ACCOUNT_2 50stake -y $KEYRING $MODE
assetClient tx send $ACCOUNT_2 $ACCOUNT_4 5stake -y $KEYRING $MODE
assetClient tx send $ACCOUNT_4 $ACCOUNT_2 5stake -y $KEYRING $MODE
sleep $SLEEP

#Add classifications
ID_CLASSIFICATION_IMMUTABLE_META_1=id_classification_immutable_meta_1$NONCE
ID_CLASSIFICATION_IMMUTABLE_1=id_classification_immutable_1$NONCE
ID_CLASSIFICATION_MUTABLE_META_1=id_classification_mutable_meta_1$NONCE
ID_CLASSIFICATION_MUTABLE_1=id_classification_mutable_1$NONCE
ASSET_CLASSIFICATION_IMMUTABLE_META_1=asset_classification_immutable_meta_1$NONCE
ASSET_CLASSIFICATION_IMMUTABLE_1=asset_classification_immutable_1$NONCE
ASSET_CLASSIFICATION_MUTABLE_META_1=asset_classification_mutable_meta_1$NONCE
ASSET_CLASSIFICATION_MUTABLE_1=asset_classification_mutable_1$NONCE
ORDER_CLASSIFICATION_IMMUTABLE_META_1=order_classification_immutable_meta_1$NONCE
ORDER_CLASSIFICATION_IMMUTABLE_1=order_classification_immutable_1$NONCE
ORDER_CLASSIFICATION_MUTABLE_META_1=order_classification_mutable_meta_1$NONCE
ORDER_CLASSIFICATION_MUTABLE_1=order_classification_mutable_1$NONCE
assetClient tx classifications define -y --from $ACCOUNT_1 \
  --immutableMetaTraits "$ID_CLASSIFICATION_IMMUTABLE_META_1:S|$ID_CLASSIFICATION_IMMUTABLE_META_1" \
  --immutableTraits "$ID_CLASSIFICATION_IMMUTABLE_1:S|$ID_CLASSIFICATION_IMMUTABLE_1" \
  --mutableMetaTraits "$ID_CLASSIFICATION_MUTABLE_META_1:S|$ID_CLASSIFICATION_MUTABLE_META_1" \
  --mutableTraits "$ID_CLASSIFICATION_MUTABLE_1:S|$ID_CLASSIFICATION_MUTABLE_1" \
  $KEYRING $MODE

assetClient tx classifications define -y --from $ACCOUNT_2 \
  --immutableMetaTraits "$ASSET_CLASSIFICATION_IMMUTABLE_META_1:S|$ASSET_CLASSIFICATION_IMMUTABLE_META_1" \
  --immutableTraits "$ASSET_CLASSIFICATION_IMMUTABLE_1:S|$ASSET_CLASSIFICATION_IMMUTABLE_1" \
  --mutableMetaTraits "$ASSET_CLASSIFICATION_MUTABLE_META_1:S|$ASSET_CLASSIFICATION_MUTABLE_META_1,burn:H|1" \
  --mutableTraits "$ASSET_CLASSIFICATION_MUTABLE_1:S|$ASSET_CLASSIFICATION_MUTABLE_1" \
  $KEYRING $MODE

assetClient tx classifications define -y --from $ACCOUNT_3 \
  --immutableMetaTraits "$ORDER_CLASSIFICATION_IMMUTABLE_META_1:S|$ORDER_CLASSIFICATION_IMMUTABLE_META_1" \
  --immutableTraits "$ORDER_CLASSIFICATION_IMMUTABLE_1:S|$ORDER_CLASSIFICATION_IMMUTABLE_1" \
  --mutableMetaTraits "$ORDER_CLASSIFICATION_MUTABLE_META_1:S|$ORDER_CLASSIFICATION_MUTABLE_META_1,exchangeRate:D|0.000000000001,makerOwnableSplit:D|1,expiry:H|500" \
  --mutableTraits "$ORDER_CLASSIFICATION_MUTABLE_1:S|$ORDER_CLASSIFICATION_MUTABLE_1" \
  $KEYRING $MODE
sleep $SLEEP
assetClient q classifications classifications
ID_CLASSIFICATION_ID_1=test.$(echo $(assetClient q classifications classifications) | awk -v var=$ID_CLASSIFICATION_IMMUTABLE_META_1 '{for(i=1;i<=NF;i++)if($i=="hashid:" && $(i+9)==var)print $(i+2)}')
ASSET_CLASSIFICATION_ID_1=test.$(echo $(assetClient q classifications classifications) | awk -v var=$ASSET_CLASSIFICATION_IMMUTABLE_META_1 '{for(i=1;i<=NF;i++)if($i=="hashid:" && $(i+9)==var)print $(i+2)}')
ORDER_CLASSIFICATION_ID_1=test.$(echo $(assetClient q classifications classifications) | awk -v var=$ORDER_CLASSIFICATION_IMMUTABLE_META_1 '{for(i=1;i<=NF;i++)if($i=="hashid:" && $(i+9)==var)print $(i+2)}')

# identities issue, provision, unprovision
ID_1=identity1$NONCE
ID_2=identity2$NONCE
ID_3=identity3$NONCE

assetClient tx identities issue -y --from $ACCOUNT_1 --to $ACCOUNT_1 --classificationID $ID_CLASSIFICATION_ID_1 \
  --immutableMetaProperties "$ID_CLASSIFICATION_IMMUTABLE_META_1:S|$ID_CLASSIFICATION_IMMUTABLE_META_1" \
  --immutableProperties "$ID_CLASSIFICATION_IMMUTABLE_1:S|$ID_CLASSIFICATION_IMMUTABLE_1" \
  --mutableMetaProperties "$ID_CLASSIFICATION_MUTABLE_META_1:S|$ID_1" \
  --mutableProperties "$ID_CLASSIFICATION_MUTABLE_1:S|$ID_1" \
  $KEYRING $MODE

sleep $SLEEP
ACCOUNT_1_ID=$ID_CLASSIFICATION_ID_1"|"$(echo $(assetClient q identities identities) | awk -v var=$ID_CLASSIFICATION_IMMUTABLE_META_1 '{for(i=1;i<=NF;i++)if($i=="hashid:" && $(i+14)==var)print $(i+2)}')

#provision identities
assetClient tx identities provision -y --from $ACCOUNT_1 --to $ACCOUNT_4 --identityID $ACCOUNT_1_ID $KEYRING $MODE
sleep $SLEEP
assetClient tx identities unprovision -y --from $ACCOUNT_1 --to $ACCOUNT_4 --identityID $ACCOUNT_1_ID $KEYRING $MODE
sleep $SLEEP
assetClient query identities identities

#metas reveal, meta properties are already revealed.
assetClient tx metas reveal -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --metaFact "S|$ID_CLASSIFICATION_IMMUTABLE_1"
sleep $SLEEP

#assets mint, mutate burn
ASSET_P1=assets1$NONCE
ASSET_P2=assets2$NONCE
ASSET_P3=assets3$NONCE
ASSET_P4=assets4$NONCE
ASSET_P5=assets5$NONCE
ASSET_P6=assets6$NONCE
ASSET_P7=assets7$NONCE
assetClient tx assets mint -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --toID $ACCOUNT_1_ID --classificationID $ASSET_CLASSIFICATION_ID_1 \
  --immutableMetaProperties "$ASSET_CLASSIFICATION_IMMUTABLE_META_1:S|$ASSET_CLASSIFICATION_IMMUTABLE_META_1" \
  --immutableProperties "$ASSET_CLASSIFICATION_IMMUTABLE_1:S|$ASSET_CLASSIFICATION_IMMUTABLE_1" \
  --mutableMetaProperties "$ASSET_CLASSIFICATION_MUTABLE_META_1:S|$ASSET_P1,burn:H|1" \
  --mutableProperties "$ASSET_CLASSIFICATION_MUTABLE_1:S|$ASSET_P1" \
  $KEYRING $MODE

sleep $SLEEP

ACCOUNT_1_ASSET_1=$ASSET_CLASSIFICATION_ID_1"|"$(echo $(assetClient q assets assets) | awk -v var=$ASSET_CLASSIFICATION_IMMUTABLE_META_1 '{for(i=1;i<=NF;i++)if($i=="hashid:" && $(i+9)==var)print $(i+2)}')

assetClient tx assets mutate -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --assetID $ACCOUNT_1_ASSET_1 \
  --mutableMetaProperties "$ASSET_CLASSIFICATION_MUTABLE_META_1:S|CHANGE$ASSET_P1" \
  --mutableProperties "$ASSET_CLASSIFICATION_MUTABLE_1:S|CHANGE$ASSET_P1" \
  $KEYRING $MODE

sleep $SLEEP
assetClient tx assets burn -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --assetID $ACCOUNT_1_ASSET_1 $KEYRING $MODE
sleep $SLEEP

##wraping/unwrapping coins
assetClient tx splits wrap -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --coins 50stake $KEYRING $MODE
sleep $SLEEP
assetClient tx splits unwrap -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --ownableID stake --split 1 $KEYRING $MODE
sleep $SLEEP

#splits send
assetClient tx splits send -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --toID $ACCOUNT_1_ID --ownableID stake --split "1" $KEYRING $MODE
sleep $SLEEP

#order make and cancel
assetClient tx orders make --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --classificationID $ORDER_CLASSIFICATION_ID_1 --makerOwnableSplit 1 --makerOwnableID stake \
  --immutableMetaProperties "$ORDER_CLASSIFICATION_IMMUTABLE_META_1:S|$ORDER_CLASSIFICATION_IMMUTABLE_META_1" \
  --immutableProperties "$ORDER_CLASSIFICATION_IMMUTABLE_1:S|$ORDER_CLASSIFICATION_IMMUTABLE_1" \
  --mutableMetaProperties "$ORDER_CLASSIFICATION_MUTABLE_META_1:S|$ID_1" \
  --mutableProperties "$ORDER_CLASSIFICATION_MUTABLE_1:S|$ID_1" \
  --takerOwnableID stake -y $KEYRING $MODE
sleep $SLEEP
ACCOUNT_1_ACCOUNT_3_ORDER_1=test..$(echo $(assetClient q orders orders) | awk -v var=$ACCOUNT_1_ASSET_1 '{for(i=1;i<=NF;i++)if($i=="hashid:"){for(j=1;j<=i+40;j++)if($j==var){print $(i+2)}}}')
assetClient tx orders cancel --from $ACCOUNT_1 --orderID $ACCOUNT_1_ACCOUNT_3_ORDER_1 -y $KEYRING $MODE
sleep $SLEEP








#order make and take private
assetClient tx orders make --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --toID $ACCOUNT_3_ID --makerSplit 1 --makerSplitID $ACCOUNT_1_ASSET_1 --exchangeRate="1" --takerSplitID $ACCOUNT_3_ASSET_1 -y $KEYRING $MODE
sleep $SLEEP
ACCOUNT_1_ACCOUNT_3_ORDER_1=test..$(echo $(assetClient q orders orders) | awk -v var=$ACCOUNT_1_ASSET_1 '{for(i=1;i<=NF;i++)if($i=="hashid:"){for(j=1;j<=i+40;j++)if($j==var){print $(i+2)}}}')
assetClient tx orders take --from $ACCOUNT_3 --orderID $ACCOUNT_1_ACCOUNT_3_ORDER_1 --takerSplit 1 --fromID $ACCOUNT_3_ID -y $KEYRING $MODE
sleep $SLEEP

#order make and cancel
assetClient tx orders make --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --toID $ACCOUNT_3_ID --makerSplit 1 --makerSplitID $ACCOUNT_1_ASSET_1 --exchangeRate="1" --takerSplitID $ACCOUNT_3_ASSET_1 -y $KEYRING $MODE
sleep $SLEEP
ACCOUNT_1_ACCOUNT_3_ORDER_1=test..$(echo $(assetClient q orders orders) | awk -v var=$ACCOUNT_1_ASSET_1 '{for(i=1;i<=NF;i++)if($i=="hashid:"){for(j=1;j<=i+40;j++)if($j==var){print $(i+2)}}}')
assetClient tx orders cancel --from $ACCOUNT_1 --orderID $ACCOUNT_1_ACCOUNT_3_ORDER_1 -y $KEYRING $MODE
sleep $SLEEP

#order make and take private
assetClient tx orders make --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --toID $ACCOUNT_3_ID --makerSplit 1 --makerSplitID $ACCOUNT_1_ASSET_1 --exchangeRate="1" --takerSplitID $ACCOUNT_3_ASSET_1 -y $KEYRING $MODE
sleep $SLEEP
ACCOUNT_1_ACCOUNT_3_ORDER_1=test..$(echo $(assetClient q orders orders) | awk -v var=$ACCOUNT_1_ASSET_1 '{for(i=1;i<=NF;i++)if($i=="hashid:"){for(j=1;j<=i+40;j++)if($j==var){print $(i+2)}}}')
assetClient tx orders take --from $ACCOUNT_3 --orderID $ACCOUNT_1_ACCOUNT_3_ORDER_1 --takerSplit 1 --fromID $ACCOUNT_3_ID -y $KEYRING $MODE
sleep $SLEEP

#order make and take public
assetClient tx orders make --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --makerSplit 1 --makerSplitID $ACCOUNT_1_ASSET_2 --exchangeRate="1" --takerSplitID $ACCOUNT_2_ASSET_1 -y $KEYRING $MODE
sleep $SLEEP
ACCOUNT_1_ORDER_2=test..$(echo $(assetClient q orders orders) | awk -v var=$ACCOUNT_1_ASSET_2 '{for(i=1;i<=NF;i++)if($i=="hashid:"){for(j=1;j<=i+40;j++)if($j==var){print $(i+2)}}}')
assetClient tx orders take --from $ACCOUNT_2 --orderID $ACCOUNT_1_ORDER_2 --takerSplit 1 --fromID $ACCOUNT_2_ID -y $KEYRING $MODE
sleep $SLEEP

#splits send
assetClient tx splits send -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --toID $ACCOUNT_3_ID --ownableID $ACCOUNT_3_ASSET_1 --split "1" $KEYRING $MODE
assetClient tx splits send -y --from $ACCOUNT_3 --fromID $ACCOUNT_3_ID --toID $ACCOUNT_1_ID --ownableID $ACCOUNT_1_ASSET_1 --split "1" $KEYRING $MODE
assetClient tx splits send -y --from $ACCOUNT_2 --fromID $ACCOUNT_2_ID --toID $ACCOUNT_1_ID --ownableID $ACCOUNT_1_ASSET_2 --split "1" $KEYRING $MODE
sleep $SLEEP
assetClient tx splits send -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --toID $ACCOUNT_2_ID --ownableID $ACCOUNT_2_ASSET_1 --split "1" $KEYRING $MODE
sleep $SLEEP

##wraping/unwrapping coins
assetClient tx splits wrap -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --coins 50stake $KEYRING $MODE
assetClient tx splits wrap -y --from $ACCOUNT_3 --fromID $ACCOUNT_3_ID --coins 50stake $KEYRING $MODE
assetClient tx splits wrap -y --from $ACCOUNT_2 --fromID $ACCOUNT_2_ID --coins 50stake $KEYRING $MODE
sleep $SLEEP
assetClient tx splits unwrap -y --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --ownableID stake --split 1 $KEYRING $MODE
assetClient tx splits unwrap -y --from $ACCOUNT_3 --fromID $ACCOUNT_3_ID --ownableID stake --split 1 $KEYRING $MODE
assetClient tx splits unwrap -y --from $ACCOUNT_2 --fromID $ACCOUNT_2_ID --ownableID stake --split 1 $KEYRING $MODE
sleep $SLEEP
# orders maker asset taker split
assetClient tx orders make --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --makerSplit 1 --makerSplitID $ACCOUNT_1_ASSET_1 --exchangeRate="2.25" --takerSplitID stake -y $KEYRING $MODE
sleep $SLEEP
ACCOUNT_1_ORDER_1=test..$(echo $(assetClient q orders orders) | awk -v var=$ACCOUNT_1_ASSET_1 '{for(i=1;i<=NF;i++)if($i=="hashid:"){for(j=1;j<=i+40;j++)if($j==var){print $(i+2)}}}') $KEYRING $MODE
assetClient tx orders take --from $ACCOUNT_3 --fromID $ACCOUNT_3_ID --orderID $ACCOUNT_1_ORDER_1 --takerSplit 5 -y $KEYRING $MODE
sleep $SLEEP

# orders maker split taker asset
assetClient tx orders make --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --makerSplit 10 --makerSplitID stake --exchangeRate="0.1" --takerSplitID $ACCOUNT_1_ASSET_1 -y $KEYRING $MODE
sleep $SLEEP
ACCOUNT_1_ORDER_1=test..$(echo $(assetClient q orders orders) | awk -v var=$ACCOUNT_1_ASSET_1 '{for(i=1;i<=NF;i++)if($i=="hashid:"){for(j=1;j<=i+60;j++)if($j==var){print $(i+2)}}}')
assetClient tx orders take --from $ACCOUNT_3 --fromID $ACCOUNT_3_ID --orderID $ACCOUNT_1_ORDER_1 --takerSplit 1 -y $KEYRING $MODE
sleep $SLEEP

# orders maker split taker split
assetClient tx orders make --from $ACCOUNT_1 --fromID $ACCOUNT_1_ID --makerSplit 10 --makerSplitID stake --exchangeRate="0.7" --takerSplitID stake -y $KEYRING $MODE
sleep $SLEEP
ACCOUNT_1_ORDER_2=test..$(echo $(assetClient q orders orders) | awk -v var=ACCOUNT_1_ID '{for(i=1;i<=NF;i++)if($i=="hashid:"){for(j=1;j<=i+40;j++)if($j==var){print $(i+2)}}}')
assetClient tx orders take --from $ACCOUNT_2 --fromID $ACCOUNT_2_ID --orderID $ACCOUNT_1_ORDER_2 --takerSplit 9 -y $KEYRING $MODE
sleep $SLEEP
