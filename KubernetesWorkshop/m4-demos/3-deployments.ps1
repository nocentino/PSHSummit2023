#######################################################################################################################################
# Anthony E. Nocentino
# Centino Systems
# aen@centinosystems.com
# Platform: PowerShell on Windows, Mac or Linux
#######################################################################################################################################

cd ./m4-demos


#Let's make sure our deployment is online. Should be unchanged if you're following along from the last demo
kubectl apply -f deploymentv1.yaml

kubectl get deployment
kubectl get replicaset
kubectl get pods

#Change deployment.yaml from 4 to 5 replicas, it just stamps out a new Pods based on the Pod Template
kubectl edit deployment hello-world
kubectl get pods --show-labels


#Examine Events to see the scaling of the replicaset, Examing Replicas:
kubectl describe deployment


#Create our service, so we can hit our application. Should be unchanged if you're following along from the last demo
code service.yaml
kubectl apply -f service.yaml

kubectl get service hello-world
$SERVICEIP=kubectl get service hello-world -o jsonpath='{.status.loadBalancer.ingress[].hostname}'
Write-Output $SERVICEIP


#We can apply a yaml file for the deployment's definition
kubectl apply -f deploymentv2.yaml


#Check the status of our rollout...this will block until the rollout is finished
kubectl rollout status deployment hello-world


#In the Events section, watch the replicasets scale up and down
kubectl describe deployment hello-world


#We can see our new ReplicaSet at 5 and our old at 0
kubectl get replicasets


#we can see a history of what's occurred
kubectl rollout history deployment hello-world
kubectl rollout history deployment hello-world --revision=2


#Test out to ensure we're on v2
(Invoke-WebRequest $SERVICEIP -DisableKeepAlive).Content


#Maybe we need to rollback to v1
kubectl rollout undo deployment hello-world --to-revision=1


#Check out the events
kubectl describe deployment hello-world


#Check out the current status of the replicasets, we should be back on the initial replicaset
kubectl get replicaset


#test to ensure we're on v1
(Invoke-WebRequest $SERVICEIP -DisableKeepAlive).Content


#Let's delete these resources to move into the next demo
kubectl delete deployment hello-world
kubectl delete service hello-world
kubectl get all 


#Now let's work with Deployments and Services and Labels and Selectors
#Start a Deployment with 4 replicas, open deploymentv1.yaml
kubectl apply -f deploymentv1.yaml


#Expose our Deployment as a Service, open and examine service.yaml
more service.yaml
kubectl apply -f service.yaml


#Look at the Labels and Selectors on each resource, the Deployment, ReplicaSet and Pod
#Check out the Pod Template and the Labels defined there...
kubectl describe deployment hello-world | more


#Check out the Pod Template and the addional Label defined there...
kubectl describe replicaset hello-world | more


#Let's check out the actual Pods' Labels
kubectl get pods --show-labels


#Edit the label on one of the Pods in the ReplicaSet, change the pod-template-hash
#Copy and paste a pod name from above here, we'll reuse this environment variable a bunch
$PODNAME='PASTE A POD NAME HERE'
kubectl label pod $PODNAME pod-template-hash=DEBUG --overwrite


#The ReplicaSet will deploy a new Pod to satisfy the number of replicas. Our relabeled Pod still exists.
kubectl get pods --show-labels


#Let's look at how Services use labels and selectors, check out services.dockerdesktop.yaml
kubectl get service


#The selector for this serivce is app=hello-world, will this Pod still load balanced to (active endpoint?)! Why?
#There's a selector for the Service AND the Deployment/ReplicaSet, we changed it only in the Deployment/ReplicaSet
kubectl describe service hello-world


#Get a list of all Pod Endpoint IPs in the service
kubectl describe endpoints hello-world


#Get a list of pods and their IPs, our relabeled pod is still being load balanced to since it's in the list of endpoints.
kubectl get pod -o wide


#To remove a pod from load balancing, change the label used by the service's selector.
#The ReplicaSet will respond by placing another pod in the ReplicaSet
kubectl get pods --show-labels
kubectl label pod $PODNAME app=DEBUG --overwrite


#Check out all the labels in our pods
kubectl get pods --show-labels 


#Look at the registered endpoint addresses, did the pod IP get removed?
kubectl describe endpoints hello-world


#Let's delete our resources before we move onto the next demo
kubectl delete deployment hello-world
kubectl delete service hello-world


#We'll still have our one pod left, since it's no longer in the selector of our deployment
kubectl get pods 
kubectl delete pod $PODNAME
