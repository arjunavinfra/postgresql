echo "Installing Postgrws main cluster"

kubectl apply -k ./

echo -e "\n"

sleep 3 

kubectl wait   --for=condition=ready pod  -l name=postgres-operator --timeout=200s -n postgres

kubectl wait   --for=condition=ready pod  -l cluster-name=acid-main-cluster   --timeout=200s -n postgres

echo -e "Installing standby cluster\n"


kubectl apply -f postgres-operator/standby-manifest.yaml


POSTGRES_PASS=`kubectl get secrets -n postgres postgres.acid-main-cluster.credentials.postgresql.acid.zalan.do  -ojson  | jq .data.password | sed -e 's/"//g'`

STANDBY_PASS=`kubectl get secrets -n postgres standby.acid-main-cluster.credentials.postgresql.acid.zalan.do  -ojson  | jq .data.password | sed -e 's/"//g'`


# echo -e "standby password: `echo $STANDBY_PASS  | base64 -d`\n"



echo -e "Patching the standby cluster with main cluster secret"


kubectl patch secret postgres.acid-standby-cluster.credentials.postgresql.acid.zalan.do --type='json' -p='[{"op" : "replace" ,"path" : "/data/password" ,"value" : "'${POSTGRES_PASS}'"}]'


echo -e "\n"


echo -e "Patching the standby cluster with main cluster secret"

kubectl patch secret standby.acid-standby-cluster.credentials.postgresql.acid.zalan.do --type='json' -p='[{"op" : "replace" ,"path" : "/data/password" ,"value" : "'${STANDBY_PASS}'"}]'



kubectl  logs acid-standby-cluster-0 | grep "FATAL:  password authentication failed" > /dev/null

if [ $? = 0 ]; then
echo "Pod is not running need a restart"

kubectl delete pod acid-standby-cluster-0


else 
echo "Successfully patched the secrete on standby cluster"
fi 


echo -e "postgresql password: `echo $POSTGRES_PASS | base64 -d` \n"

echo -e "\n"

# echo  -e "forwarding port to local \n "
# pc

# echo -e "ACID MAIN"
# kubectl  port-forward acid-main-cluster-0 5434:5432    & 


# echo -e "ACID STANDBY"
# kubectl  port-forward acid-standby-cluster-0 5435:5432 

