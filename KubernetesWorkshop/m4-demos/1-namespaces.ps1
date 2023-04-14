#######################################################################################################################################
# Anthony E. Nocentino
# Centino Systems
# aen@centinosystems.com
# Platform: PowerShell on Windows, Mac or Linux
#######################################################################################################################################

cd ../m4-demos

#Get a list of all the namespaces in our cluster
kubectl get namespaces


#Describe the details of an indivdual namespace
kubectl describe namespaces kube-system


#Get all the pods in our cluster across all namespaces
kubectl get pods
kubectl get pods --all-namespaces


#Get all the resource across all of our namespaces
kubectl get all --all-namespaces


#Get a list of the pods in the kube-system namespace
kubectl get pods --namespace kube-system


#Declaratively create a namespace
kubectl create namespace playground1


#Imperatively create a namespace...but there's some character restrictions. Lower case and only dashes.
kubectl create namespace Playground1


#Declaratively create a namespace
more namespace.yaml
kubectl apply -f namespace.yaml


#Get a list of all the current namespaces
kubectl get namespaces


#Start a deployment into our playground1 namespace
kubectl create deployment hello-world `
    --image=psk8s.azurecr.io/hello-app:1.0 `
    --namespace=playground1


#Where are the pods?
kubectl get pods


#List all the pods on our namespace
kubectl get pods --namespace playground1


#Get a list of all of the resources in our namespace...Deployment, ReplicaSet and Pods
kubectl get all --namespace=playground1


#Try to delete all the pods in our namespace
kubectl delete pods --all --namespace playground1


#Get a list of all of the *new* pods in our namespace. Did a pod you just deleted come back? Why?
kubectl get pods -n playground1


#Deleting the namespace will delete all the resources in that namespace...careful yo!
kubectl delete namespaces playground1
kubectl delete namespaces playgroundinyaml


#List all resources in all namespaces, now our Deployment in our playground1 namespace is gone.
kubectl get all --all-namespaces


#Let's create some Pods with custom labels, no controllers here.
more CreatePodsWithLabels.yaml
kubectl apply -f CreatePodsWithLabels.yaml


#Look at all the Pod labels in our cluster
kubectl get pods --show-labels


#Look at one Pod's labels in our cluster
kubectl describe pod nginx-pod-1


#Query labels and selectors
kubectl get pods --selector tier=prod
kubectl get pods -l tier=prod
kubectl get pods -l tier=prod --show-labels


#More complex query example
kubectl get pods -l 'tier=prod,app=MyWebApp' --show-labels
kubectl get pods -l 'tier=prod,app!=MyWebApp' --show-labels
kubectl get pods -l 'tier in (prod,qa)'


#Why doesn't this one yeild a Pod?
kubectl get pods -l 'tier notin (prod,qa)'


#Edit an existing label
kubectl label pod nginx-pod-1 tier=non-prod --overwrite
kubectl get pod nginx-pod-1 --show-labels


#Adding a new label
kubectl label pod nginx-pod-1 another=Label
kubectl get pod nginx-pod-1 --show-labels


#Removing an existing label
kubectl label pod nginx-pod-1 another-
kubectl get pod nginx-pod-1 --show-labels


#Performing an operation on a collection of pods based on a label query
kubectl label pod --all tier=non-prod --overwrite
kubectl get pod --show-labels


#Delete all pods matching our non-prod label
kubectl delete pod -l tier=non-prod


#And we're left with nothing.
kubectl get pods --show-labels
