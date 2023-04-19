#######################################################################################################################################
# Anthony E. Nocentino
# Centino Systems
# aen@centinosystems.com
# Platform: bash on Windows (WSL), Mac or Linux
#######################################################################################################################################


#This will show the API endpoint of your control plane including its DNS name and port
kubectl cluster-info


#review status and roles
kubectl get nodes


#Additional information the nodes in the cluster. 
kubectl get nodes -o wide


#Let's get a list of pods...but there isn't any running.
kubectl get pods 


#True, but let's get a list of system pods. A namespace is a way to group resources together.
#You'll find a pod supporting each of the core cluster components. The status should be Running.
kubectl get pods --namespace kube-system


#Let's get additional information about each pod, such as pod ID and the node name the pod is running on.
kubectl get pods --namespace kube-system -o wide


#Asking kubernetes for the resources it knows about
#Let's look at the headers in each column. Name, Alias/shortnames, API Group (or where that resource is in the k8s API Path),
#Is the resource in a namespace, for example StorageClass isn't and is available to all namespaces and finally Kind...this is the object type.
kubectl api-resources | more


#We can easily filter using group, using bash...use grep
kubectl api-resources | grep pod


#Explain an indivdual resource in detail...this is core to how you're going to build and troubleshoot your yaml manifests.
kubectl explain pod | more 
kubectl explain pod.spec | more 
kubectl explain pod.spec.containers | more 


#You'll soon find your favorite alias, you can find other aliases in kubectl api-resources
kubectl get no


#Let's take a closer look at our nodes using Describe
#Check out Name, Taints, Conditions, Addresses, System Info, Non-Terminated Pods, and Events
kubectl describe nodes docker-desktop  | more


#Very in depth help menus...
kubectl -h | more
kubectl get -h | more
kubectl describe -h | more 
