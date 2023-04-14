#######################################################################################################################################
# Anthony E. Nocentino
# Centino Systems
# aen@centinosystems.com
# Platform: bash on Windows (WSL), Mac or Linux
#######################################################################################################################################


cd ../m5-demos


#Demo 1 - Creating a dotnet core web application
#Install Docker and .NET Core from a powershell prompt with an administrative priviledges
#RUN WITH ADMINISTRATIVE PRIVILEDGES
#NOTE: You will need to re-launch powershell to get dotnet into your path


#This is our simple hello world web app and will be included in the course downloads.
Get-ChildItem ./v1/webapp


#Step 1 - Time to build the container and tag it...the build is defined in the Dockerfile
docker build -f ./v1/Dockerfile -t webappimage:v1 .


#Step 2 - Run the container locally and test it out
docker run --name webapp --publish 8080:80 --detach webappimage:v1
http://localhost:8080  #<-- CMD + Click this link to launch the webpage.


#Delete the running webapp container
docker stop webapp
docker rm webapp


#The image is still here...let's hold onto this for the next demo.
docker image ls webappimage:v1



#Demo 3 - Push a container to a container registry
#To create a repository in our registry, follow the directions here
#Create an account at http://hub.docker.com
#The Namespace will be your login name, your repository name can match mine below, webappimage
#https://docs.docker.com/docker-hub/repos/create/



#Then let's log into docker using the account above.
docker login 


#Check out the list of local images for our image we want to upload
docker image ls webappimage


#Tag our image in the format your registry repository namespace/image:tag
#You'll be using your own repository, so update that information here. 
docker tag webappimage:v1 nocentino/webappimage:v1


#Now push that locally tagged image into our repository at docker hub
#You'll be using your own repository namespace, so update that information here. 
docker push nocentino/webappimage:v1

open a browser to your repository https://hub.docker.com/repository/docker/nocentino/webappimage


#Demo 4 - Create a Kubernetes Cluster and deploy our application

#Let's rollout our service
kubectl apply -f service.yaml
kubectl get service

#You need to update the image in the deployment.yaml prior to deploying
#Set the image to YOUR image in docker hub
kubectl apply -f deploymentv1.yaml


#Check out the status
kubectl get deployment
kubectl get replicaset
kubectl get pods 


#5 - Scaling our application
kubectl scale deployment.v1.apps/webapp-deployment --replicas=10


#Check out how many pods...so fast
kubectl get pods -o wide



#Access our application again, workload should be load balanced.
#In a broswer you'll need to force a refresh
#Firefox CTRL+SHIFT+R
#Edge CTRL+F5
#Open a browser to http://localhost:80
(Invoke-WebRequest http://localhost -DisableKeepAlive).RawContent



####Let's build and push a v2 of our app and update our deployment
#Step 1 - Time to build the container and tag it...the build is defined in the Dockerfile
docker build -f ./v2/Dockerfile -t webappimage:v2 .


#Step 2 - Tag and push the v2 image
docker tag webappimage:v2 nocentino/webappimage:v2
docker push nocentino/webappimage:v2


#Step 3 - Update your deployment with your new image
#You need to update the image in the deployment.yaml prior to deploying
#Set the image to YOUR image in docker hub
kubectl apply -f deploymentv2.yaml


#Check the rollout status
kubectl rollout status deployment webapp-deployment


#Access our application again, workload should be load balanced. And you should see v2 shortly.
#In a broswer you'll need to force a refresh
#Firefox CTRL+SHIFT+R
#Edge CTRL+F5
#Open a browser to http://localhost:80
(Invoke-WebRequest http://localhost -DisableKeepAlive).RawContent


#Time to clean up
kubectl delete deployment webapp-deployment
kubectl delete service webapp
docker rmi webappimage:v1
docker rmi nocentino/webappimage:v1
docker rmi webappimage:v2
docker rmi nocentino/webappimage:v2

