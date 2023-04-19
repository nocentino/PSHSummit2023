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
kubectl get pods --show-labels

#Scale the deployment from 4 to 5 replicas, it just stamps out a new Pods based on the Pod Template
kubectl scale deployment hello-world --replicas=5
kubectl get pods --show-labels


#Examine Events to see the scaling of the replicaset, Examing Replicas:
kubectl describe deployment


#Create our service, so we can hit our application. Should be unchanged if you're following along from the last demo
code service.yaml
kubectl apply -f service.yaml


#Test out our service to ensure all is well before moving on.
kubectl get service hello-world
$SERVICEIP=kubectl get service hello-world -o jsonpath='{.status.loadBalancer.ingress[].hostname}'
Write-Output $SERVICEIP


#We can apply a yaml file for the deployment's definition...this will rollout v2 of our application.
#The only difference between the two files is the container tag
# deploymentv1.yaml - image: psk8s.azurecr.io/hello-app:1.0
# deploymentv2.yaml - image: psk8s.azurecr.io/hello-app:2.0
code deploymentv2.yaml
kubectl apply -f deploymentv2.yaml


#Check the status of our rollout...this will block until the rollout is finished
kubectl rollout status deployment hello-world


#In the Events section, watch the replicasets scale up and down
kubectl describe deployment hello-world


#We can see our new ReplicaSet at 5 and our old at 0
kubectl get replicasets


#We can see a history of what's occurred...get a listing of the deployment history. 
#Then ask for the changes in a specific deployment history by specifying the revision number
kubectl rollout history deployment hello-world
kubectl rollout history deployment hello-world --revision=2


#Test out to ensure we're on v2...you should see Version: 2.0.0 in your output
(Invoke-WebRequest $SERVICEIP -DisableKeepAlive).Content


#Maybe we need to rollback to v1...
#we can do that by specifying a  --to-revision=1 where the number is based on the deployment history from above.
kubectl rollout undo deployment hello-world --to-revision=1


#Check out the events...you'll see the new replica set scale down and the old scale back up.
kubectl describe deployment hello-world


#Check out the current status of the replicasets, we should be back on the initial replicaset
kubectl get replicaset


#test to ensure we're on v1...you should see Version: 1.0.0 in your output
(Invoke-WebRequest $SERVICEIP -DisableKeepAlive).Content


#Let's delete these resources to move into the next demo
kubectl delete deployment hello-world
kubectl delete service hello-world
kubectl get all 




#Now let's work with Deployments and Services and Labels and Selectors. 
#Start a Deployment with 4 replicas, open deploymentv1.yaml
#Examine the pod template and the labels defined.
kubectl apply -f deploymentv1.yaml


#Expose our Deployment as a Service, open and examine service.yaml
#Examine the label selectors defined. They match the pod template in the deployment.
more service.yaml
kubectl apply -f service.yaml


#Look at the Labels and Selectors on each resource, the Deployment, ReplicaSet and Pod
#Examine the labels and selectors in the deployment and also the labels defined in the pod template.
kubectl describe deployment hello-world | more


#Examine the labels and selectors in the deployment and also the additional labels defined in the pod template when compared with the deployment
#Using the pod-template-hash is how the deployment can track different versions of a deployment.
#you've already seen how replica sets are added and scaled up and down based on the state of the deployment. This is the mechanism that controls that.
kubectl describe replicaset hello-world | more


#Let's check out the actual Pods' Labels...they will have labels for the deployment (app=hello-world) and also the pod-template-hash
kubectl get pods --show-labels


#From the output of the last command, copy and paste a pod name here, we'll reuse this environment variable a bunch in this demo
#Then you will edit the label on one of the Pods in the ReplicaSet, change the pod-template-hash
$PODNAME='PASTE A POD NAME HERE'
kubectl label pod $PODNAME pod-template-hash=DEBUG --overwrite


#The ReplicaSet will deploy a new Pod to satisfy the number of replicas. 
#Our relabeled Pod still exists but isn't with in the scope of the label selector. 
#Notice how one of the pods' AGE is newer than the others. And that our relabed pod has the pod-temlate-hash set to DEBUG
kubectl get pods --show-labels


#Let's look at how Services use labels and selectors
kubectl get service


#The selector for this serivce is app=hello-world, and there's currently 5 endpoints available, why 5 rather than 4?
#There's a selector for the Service AND the Deployment/ReplicaSet, we changed it only in impacting Deployment/ReplicaSet
kubectl describe service hello-world


#Get a list of all Pod Endpoint IPs in the service...and you will see 5 endpoints
kubectl describe endpoints hello-world


#To remove a pod from load balancing, change the label used by the service's selector. In our example here the label is app=hello-world
#The ReplicaSet will respond by placing another pod in the ReplicaSet
kubectl get pods --show-labels
kubectl label pod $PODNAME app=DEBUG --overwrite


#Check out all the labels in our pods...still 5 pods, right?
kubectl get pods --show-labels 


#Look at the registered endpoint addresses, did the pod IP get removed?
#You should have just 4 endpoints to the 4 pods in the scope of the selector. We are no longer load balancing to the DEBUG pod.
kubectl describe endpoints hello-world


#Let's delete our resources before we move onto the next demo
kubectl delete deployment hello-world
kubectl delete service hello-world


#We'll still have our one pod left, since it's no longer within the scope the selector of our deployment. 
#So it won't be terminated when we delete the deployment...we will need to delete it manually.
kubectl get pods 
kubectl delete pod $PODNAME
