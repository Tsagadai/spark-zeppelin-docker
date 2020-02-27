# Purpose 

This docker image provides a local *spark* installation with *zeppelin* and a running *spark-history-server*.

## Components
- Spark version="2.4.3"
- Zeppelin version="0.8.2"
- Hadoop version="2.7"
 
## Start the container
```
  docker run -it -p 18080:18080 -p 8088:8080 -d tsagadai/spark-zeppelin-docker
```

## Open Zeppelin and Spark History Server  

In your local browser 
- Zeppelin: http://localhost:8888/#/
- Spark History Server: http://localhost:18080/?showIncomplete=true

Probably, you have to wait roughly 10 second until zeppelin daemon has been started, right after starting the container.



## Spark-App
 
### Copy your spark jar to docker container

Start another shell session and copy the jar-file into the docker container.
Following command copies it into your latest started container.
```
docker cp <your-jar-file.jar> $(docker ps  -l -q):/work/
```


###  Run spark job

Go back to container session. You should be connected as root in the docker container:

```
cd /work
spark-submit   --class <your-class-name-with-package> \
      <your-jar-file.jar> \
      [<your-program-parameters>]
```
 

## Changes in dockerfile
 
After changes in `Dockerfile` goto project home dir and run
```
docker build  -t tsagadai/spark-zeppelin-docker .
```

This repo is connected to an automated build in docker hub, so the following *no push* to docker hub is not required.
```
docker push  tsagadai/spark-zeppelin-docker
```


## Misc

### if container session is lost
```
docker start CONTAINER_ID
docker attach CONTAINER_ID
```

### run as background session
add `- d`
