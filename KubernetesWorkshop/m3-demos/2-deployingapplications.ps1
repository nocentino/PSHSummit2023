#######################################################################################################################################
# Anthony E. Nocentino
# Centino Systems
# aen@centinosystems.com
# Platform: bash on Windows (WSL), Mac or Linux
#######################################################################################################################################

#Deploying resources imperatively in your cluster.
#kubectl create deployment, creates a Deployment with one replica in it.
#This is pulling a simple hello-world app container image from a container registry.
kubectl create deployment hello-world --image=psk8s.azurecr.io/hello-app:1.0


#But let's deploy a single "bare" pod that's not managed by a controller...
kubectl run hello-world-pod --image=psk8s.azurecr.io/hello-app:1.0


#Let's see of the Deployment creates a single replica and also see if that bare pod is created. 
#You should have two pods here...
# - the one managed by our controller has a the pod template hash in it's name and a unique identifier
# - the bare pod
kubectl get pods
kubectl get pods -o wide


#We can pull the logs from the container. Which is going to be anything written to stdout. 
#Maybe something went wrong inside our app and our pod won't start. This is useful for troubleshooting.
kubectl logs hello-world-pod


#Starting a process inside a container inside a pod.
#We can use this to launch any process as long as the executable/binary is in the container.
#Launch a shell into the container. Callout that this is on the *pod* network.
kubectl exec -it  hello-world-pod -- /bin/sh
hostname
ip addr
exit


#Remember that first kubectl create deployment we executed, it created a deployment for us.
#Let's look more closely at that deployment
#Deployments are made of ReplicaSets and ReplicaSets create Pods!
kubectl get deployment hello-world
kubectl get replicaset
kubectl get pods


#Let's take a closer look at our Deployment and it's Pods.
#Name, Replicas, and Events. In Events, notice how the ReplicaSet is created by the deployment.
#Deployments are made of ReplicaSets!
kubectl describe deployment hello-world | more


#The ReplicaSet creates the Pods...check out...Name, Controlled By, Replicas, Pod Template, and Events.
#In Events, notice how the ReplicaSet create the Pods
kubectl describe replicaset hello-world | more



#For a deep dive into Deployments check out 'Managing Kubernetes Controllers and Deployments'
#https://www.pluralsight.com/courses/managing-kubernetes-controllers-deployments





#Expose the Deployment as a Service. This will create a Service for the Deployment
#We are exposing our Service on port 80, connecting to an application running on 8080 in our pod.
#Port: Internal Cluster Port, the Service's port. You will point cluster resources here.
#TargetPort: The Pod's Service Port, your application. That one we defined when we started the pods.
kubectl expose deployment hello-world `
     --port=80 `
     --target-port=8080 `
     --type=LoadBalancer


#Check out the CLUSTER-IP and PORT(S), that's where we'll access this service, from inside the cluster.
kubectl get service hello-world


#We can also get that information from using describe
#Endpoints are IP:Port pairs for each of Pods that that are a member of the Service.
#Right now there is only one...later we'll increase the number of replicas and more Endpoints will be added.
kubectl describe service hello-world


#Access the Service inside the cluster. 
#Since we're using docker desktop the ip address is localhost, in a cluster this would be allocated an IP address by the cluster or load balancer in the cloud.
kubectl get service hello-world
$SERVICEIP=kubectl get service hello-world -o jsonpath='{.status.loadBalancer.ingress[].hostname}'
Write-Output $SERVICEIP
(Invoke-WebRequest $SERVICEIP -DisableKeepAlive).Content


#Access a single pod's application directly, useful for troubleshooting.
kubectl get endpoints hello-world


#Using kubectl to generate yaml or json for your deployments
#This includes runtime information...which can be useful for monitoring and config management
#but not as source mainifests for declarative deployments
kubectl get deployment hello-world -o yaml | more 
kubectl get deployment hello-world -o json | more 



#Let's remove everything we created imperatively and start over using a declarative model
#Deleting the deployment will delete the replicaset and then the pods
#We have to delete the bare pod manually since it's not managed by a contorller. 
kubectl get all
kubectl delete service hello-world
kubectl delete deployment hello-world
kubectl delete pod hello-world-pod
kubectl get all



#Deploying resources declaratively in your cluster.
#We can use apply to create our resources from yaml.
#We could write the yaml by hand...but we can use dry-run=client to build it for us
#This can be used a a template for move complex deployments.
kubectl create deployment hello-world `
     --image=psk8s.azurecr.io/hello-app:1.0 `
     --dry-run=client -o yaml | more 


#Let's write this deployment yaml out to file
kubectl create deployment hello-world `
     --image=psk8s.azurecr.io/hello-app:1.0 `
     --dry-run=client -o yaml > deployment.yaml


#The contents of the yaml file show the definition of the Deployment...
#To launch code from the command line - https://code.visualstudio.com/docs/setup/mac#_launching-from-the-command-line
code deployment.yaml


#Create the deployment...declaratively...in code
kubectl apply -f deployment.yaml


#Generate the yaml for the service
kubectl expose deployment hello-world `
     --port=80 --target-port=8080 --type=LoadBalancer `
     --dry-run=client -o yaml | more


#Write the service yaml manifest to file
kubectl expose deployment hello-world `
     --port=80 --target-port=8080 --type=LoadBalancer `
     --dry-run=client -o yaml > service.yaml 


#The contents of the yaml file show the definition of the Service
code service.yaml 


#Create the service declaratively
kubectl apply -f service.yaml 


#Check out our current state, Deployment, ReplicaSet, Pod and a Service
kubectl get all


#Scale up our deployment...in code.
code deployment.yaml
Change spec.replicas from 1 to 20
     replicas: 20


#Update our configuration with apply to make that code to the desired state...notice how the output says "configured" it changed the state of the deployment
kubectl apply -f deployment.yaml


#And check the current configuration of our deployment...you should see 20/20
kubectl get deployment hello-world
kubectl get pods | more 


#Repeat the Invoke-WebRequest access several times to see the load balancing of the HTTP request...we're still hitting local host because its docker desktop
kubectl get service hello-world
(Invoke-WebRequest localhost -DisableKeepAlive).Content


#We can edit the resources "on the fly" with kubectl edit. But this isn't reflected in our yaml. 
#But this change is persisted in the etcd...cluster store. Change 20 to 30.
#This will change the cluster state from 20 to 30 replicas.
kubectl edit deployment hello-world


#The deployment is scaled to 30 and we have 30 pods
kubectl get deployment hello-world


#You can also scale a deployment using scale...changing the cluster state from 30 to 40 replicas
kubectl scale deployment hello-world --replicas=40
kubectl get deployment hello-world


#Let's clean up our deployment and remove everything
kubectl delete deployment hello-world
kubectl delete service hello-world
kubectl get all
