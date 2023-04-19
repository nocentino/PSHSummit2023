#######################################################################################################################################
# Anthony E. Nocentino
# Centino Systems
# aen@centinosystems.com
# Platform: PowerShell on Windows, Mac or Linux
#######################################################################################################################################


cd ./m4-demos


#Launch a deployment, this is hello-world with 4 replicas
#This is a declarative implementation, we've done imperitive so far with kubectl run
code deploymentv1.yaml
kubectl apply -f deploymentv1.yaml


#Expose our Deployment as Service declarativly
#This is a declarative implementation, we've done imperitive so far with kubectl expose
code service.yaml
kubectl apply -f service.yaml


#Look at the details of our service, check out the selector. 
#And how it refers back the the pods' labels form our deployment.
kubectl describe service hello-world 


#We can use labels to determine which pods are a member of this service, and thus will have traffic load balanced to?
kubectl get pods --selector app=hello-world -o wide


#What is the IP of our service?
kubectl get service hello-world
$SERVICEIP=kubectl get service hello-world -o jsonpath='{.status.loadBalancer.ingress[].hostname}'
Write-Output $SERVICEIP


#Let's access that application, and it's load balanced across the pods in the serivce.
#Are you hitting each of the pods?
(Invoke-WebRequest $SERVICEIP -DisableKeepAlive).Content
