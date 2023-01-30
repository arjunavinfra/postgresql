#!/bin/bash 


kc kind-cluster

# if [ $1 = "--clean" ]; then

# kunectl delete -k ./

# kubectl delete -f postgres-operator/minimal-postgres-manifest-12.yaml

# kubectl delete -f postgres-operator/standby-manifest-cluster.yaml

# exit 123

# fi 

wait()

{
    sleep $1

}

show_pass(){
   POSTGRES_PASS=`kubectl get secrets -n postgres --context  kind-cluster postgres.acid-main-cluster.credentials.postgresql.acid.zalan.do  -ojson  | jq .data.password | sed -e 's/"//g'`

   STANDBY_PASS=`kubectl get secrets -n postgres --context  kind-cluster standby.acid-main-cluster.credentials.postgresql.acid.zalan.do  -ojson  | jq .data.password | sed -e 's/"//g'`

   echo "postgres password: $POSTGRES_PASS"
}
secret_patch(){

   secret_count=`kubectl  get secret  -n postgres --context  kind-cluster | grep postgresql.acid.zalan.do  | wc -l`

   if [ ! $secret_count = '6' ]; then
      echo "secrets are creating......! wait for a while"
      wait 8
   fi

   POSTGRES_PASS=`kubectl get secrets -n postgres --context  kind-cluster postgres.acid-main-cluster.credentials.postgresql.acid.zalan.do  -ojson  | jq .data.password | sed -e 's/"//g'`

   STANDBY_PASS=`kubectl get secrets -n postgres --context  kind-cluster standby.acid-main-cluster.credentials.postgresql.acid.zalan.do  -ojson  | jq .data.password | sed -e 's/"//g'`

   # echo -e "standby password: `echo $STANDBY_PASS  | base64 -d`\n"

   echo -e "Patching the standby cluster with main cluster secret...................................!"

   kubectl patch secret -n postgres  --context  kind-cluster postgres.acid-main-$1.credentials.postgresql.acid.zalan.do --type='json' -p='[{"op" : "replace" ,"path" : "/data/password" ,"value" : "'${POSTGRES_PASS}'"}]'

   echo -e "\n"

   echo -e "Patching the standby cluster with main cluster secret....................................!"

   kubectl patch secret -n postgres --context  kind-cluster  standby.acid-main-$1.credentials.postgresql.acid.zalan.do --type='json' -p='[{"op" : "replace" ,"path" : "/data/password" ,"value" : "'${STANDBY_PASS}'"}]'


}

show_pass(){
   
   echo -e "\n"

   POSTGRES_PASS=`kubectl get secrets  --context  kind-cluster -n postgres postgres.acid-main-cluster.credentials.postgresql.acid.zalan.do  -ojson  | jq .data.password | sed -e 's/"//g'`

   echo -e "postgresql password: `echo $POSTGRES_PASS | base64 -d` \n"

   echo -e "\n"

}

status()

{
   if [ $1 = "standby" ]; then

      kubectl  logs acid-standby-cluster-0 -n postgres --context  kind-cluster | grep "FATAL:  password authentication failed" > /dev/null 
      if [[ $? = 0  ]]; then 
         secret_patch $2
         echo "Problem with authetication"
         echo "Deleting the pods on standby"
         kubectl delete -n postgres pod acid-standby-${2}-0 acid-standby-${2}-1 --context  kind-cluster
         show_pass
         exit
         
      else 
         echo "No problem with authentcation"
         show_pass
         exit
         
      fi 


   else 


      kubectl get postgresqls.acid.zalan.do -n postgres --context  kind-cluster | grep Failed > /dev/null
      if [ $? = 0 ]; then
         echo -e "\n"
         echo "failed  to provsion `kubectl get  -n postgres --context  kind-cluster postgresqls.acid.zalan.do | grep Failed  | awk '{print $1}'` cluster"
         echo -e "\n"
         kubectl get -n postgres postgresqls.acid.zalan.do --context  kind-cluster
      fi  

   fi

}



echo "Installing Postgres Operator & CRD on main cluster.................................!"


kubectl apply -k ./  -n postgres --context  kind-cluster


while [[ $(kubectl get pods -n postgres --context  kind-cluster -l name=postgres-operator -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
   wait 8
   echo "Operator Pod is still creating......! wait for a while"
done


echo -e "\n"

echo -e "Installing Postgres cluster........................................................!"

kubectl apply -f postgres-operator/minimal-postgres-manifest-12.yaml -n postgres --context  kind-cluster



while [[ $(kubectl get -n postgres --context  kind-cluster postgresqls.acid.zalan.do acid-main-cluster -ojson | jq -r .status.PostgresClusterStatus) != "Running" ]]; do
   wait 8
   status main
   echo "Postgres Pod is still creating......! wait for a while"
done


echo -e "\n"

echo -e "Installing standby S3 cluster.........................................................!"

# kubectl apply -f postgres-operator/standby-manifest-cluster.yaml

# while [[ $(kubectl get postgresqls.acid.zalan.do acid-standby-cluster -ojson | jq -r .status.PostgresClusterStatus) != "Running" ]]; do
#    wait 8
#    status standby cluster
#    echo -e "\n" 
#    echo "Standby Pod is still creating......! wait for a while"
# done


echo -e "\n"

echo -e "Installing standby cluster with backend s3.........................................................!"

kubectl apply -f postgres-operator/standby-manifest-s3.yaml -n postgres --context  kind-cluster

while [[ $(kubectl get postgresqls.acid.zalan.do acid-standby-s3  -n postgres --context  kind-cluster -ojson | jq -r .status.PostgresClusterStatus) != "Running" ]]; do
   wait 8
   status standby s3
   echo -e "\n" 
   echo "Standby Pod is still creating......! wait for a while"
done

show_pass
