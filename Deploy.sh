POSTGRES_PASS=`kubectl get secrets -n postgres postgres.acid-main-cluster.credentials.postgresql.acid.zalan.do  -ojson  | jq .data.password | sed -e 's/"//g'`


echo -e "postgresql password: `echo $POSTGRES_PASS | base64 -d` \n"



STANDBY_PASS=`kubectl get secrets -n postgres standby.acid-main-cluster.credentials.postgresql.acid.zalan.do  -ojson  | jq .data.password | sed -e 's/"//g'`


echo -e "standby password: `echo $STANDBY_PASS  | base64 -d`\n"



echo -e "Patching the standby cluster with main cluster secret"


kubectl patch secret postgres.acid-standby-cluster.credentials.postgresql.acid.zalan.do --type='json' -p='[{"op" : "replace" ,"path" : "/data/password" ,"value" : "'${POSTGRES_PASS}'"}]'


echo -e "\n"


echo -e "Patching the standby cluster with main cluster secret"

kubectl patch secret standby.acid-standby-cluster.credentials.postgresql.acid.zalan.do --type='json' -p='[{"op" : "replace" ,"path" : "/data/password" ,"value" : "'${STANDBY_PASS}'"}]'


echo -e "\n"

echo  -e "forwarding port to local \n "
pc

kubectl  port-forward acid-main-cluster-0 5432:5432 &

kubectl  port-forward acid-standby-cluster-0 5433:5432