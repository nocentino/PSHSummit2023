#######################################################################################################################################
# Anthony E. Nocentino
# Centino Systems
# aen@centinosystems.com
# Platform: PowerShell on Windows, Mac or Linux
#######################################################################################################################################

#Start up and run a container from a container registry
docker run --name webapp `
    --publish 80:8080 `
    --detach psk8s.azurecr.io/hello-app:1.0

(Invoke-WebRequest http://localhost:80 -DisableKeepAlive).Content

docker stop webapp
docker rm webapp


#Set password variable used for sa password for SQL Server - https://www.youtube.com/watch?v=WyBKzBtaKWM
$PASSWORD='S0methingS@Str0ng!'


#Pull a container, examine layers.  
docker pull mcr.microsoft.com/mssql/server:2022-latest
docker pull mcr.microsoft.com/mssql/server:2022-RTM-CU1-ubuntu-20.04
docker pull mcr.microsoft.com/mssql/server:2022-RTM-CU2-ubuntu-20.04


#List all available images in a registry...can you find latest and the two other images from above in the list?
Invoke-WebRequest https://mcr.microsoft.com/v2/mssql/server/tags/list | ConvertFrom-Json | Select-Object  -ExpandProperty tags


#List of images on this system...in addition to the tag, each image has a unique IMAGE ID. Are any of your IMAGE ID's the same? Why would that be?
docker images
docker images | Select-String sql


#Check out the docker image details. Interesting information about the container image's configuration
#This file describes the configuration of the image, what process to start up when you run a container and many more elements.
docker image inspect mcr.microsoft.com/mssql/server:2022-RTM-CU2-ubuntu-20.04 | more


#Run a container...
#this code below specifies the environment variables, gives the container a name and also exposes the container based application on a network port.
# the port to the left of the colon : is the port you will point applications to. The port to the right of the colon is the port inside the container.
docker run `
    --env "ACCEPT_EULA=Y" `
    --env "MSSQL_SA_PASSWORD=$PASSWORD" `
    --name "sql1" `
    --hostname "sql1" `
    --publish 1433:1433 `
    --detach mcr.microsoft.com/mssql/server:2022-RTM-CU1-ubuntu-20.04


#Finding help in docker...many parameters to work with. 
#Look up each of the parameters we used in the previous example. env, name, hostname, publish, and detach.
docker help run | more 


#Let's read the logs...this is the stdout output from the container. In our example here its the SQL Server error log
docker logs sql1 | more


#List running containers
docker ps


#Access our application...pointing to the port we published, 1433
sqlcmd -S localhost,1433 -U sa -Q 'SELECT @@SERVERNAME' -P $PASSWORD
sqlcmd -S localhost,1433 -U sa -Q 'SELECT @@VERSION' -P $PASSWORD


#Run a second container, new name, new port, same source image
docker run `
    --name "sql2" `
    -e "ACCEPT_EULA=Y" `
    -e "MSSQL_SA_PASSWORD=$PASSWORD" `
    --hostname "sql2" `
    -p 1434:1433 `
    -d mcr.microsoft.com/mssql/server:2022-RTM-CU1-ubuntu-20.04


#List running containers...now there's two. Notice in Ports we're listening on 1433 for sql1 and 1434 for sql2
docker ps


#Access our second application, discuss servername, connect to specific port
sqlcmd -S localhost,1434 -U sa -Q 'SELECT @@SERVERNAME' -P $PASSWORD


#Copy a backup file into the container and set the permissions.
#docker exec is used to execute commands inside the container.
cd ./m1-demos
docker cp TestDB1.bak sql2:/var/opt/mssql/data
docker exec -u root sql2 chown mssql /var/opt/mssql/data/TestDB1.bak


#Restore a database to our container
sqlcmd -S localhost,1434 -U sa -i restore_testdb1.sql -P $PASSWORD


#Connect to the container, start an interactive bash session
#We just saw that we can execute a program inside a container...we can also launch a shell inside the container and look around.
docker exec -it sql2 /bin/bash


#Inside container, check out the a process listing...just our SQL Server process due to the container isolation.
#We can also see the backup we copied in and the database we restored
ps -aux
ls -la /var/opt/mssql/data
exit


#Stopping a container
docker stop sql2


#List running containers
docker ps


#List all containers, including stopped containers. Examine the status and the exit code
docker ps -a


#Restarting a container that's already local. All the parameters from the docker run command persist.
docker start sql2
docker ps


#Stop the containers...
docker stop sql1
docker stop sql2
docker ps -a



#Removing THE Container...THIS WILL DELETE YOUR DATA IN THE CONTAINER
docker rm sql1
docker rm sql2


#Even though the containers are gone, we still have the image!
docker image ls | Select-String sql 
docker ps -a


#remove an image
#docker rmi mcr.microsoft.com/mssql/server:2022-latest
