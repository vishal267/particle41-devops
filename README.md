Architecture 

┌─────────────────────────────────────────┐
│         HTTP Request                    │
└────────────────┬────────────────────────┘
                 │
     ┌───────────▼───────────┐
     │  Go Application       │
     │  (Port 8080)          │
     ├───────────────────────┤
     │ Runs as: appuser      │
     │ UID: 1000             │
     │ Non-root              │
     └───────────┬───────────┘
                 │
     ┌───────────▼───────────────────────┐
     │  Docker Container                 │
     │  Alpine Linux                     │
     │  Go Binary                        │
     │  SSL Cer                          │
     └───────────────────────────────────┘



# Make sure you have main.go file and Dockerfile in simpletimeservice directory

cd simpleTimeService/

### Build the Docker image:

docker build -t simpletimeservice:1.0.0 .

### Run the container:

docker run -d -p 8080:8080 --name time-service simpletimeservice:1.0.0

### Test endpoint

curl localhost:8080/health
{"status":"healthy"}

curl localhost:8080
{"timestamp":"2025-12-17T08:52:12Z","ip":"192.168.65.1:46150"}

### Push the image to docker hub 
docker login 

docker tag simpletimeservice:1.0.0 vishal26778/simpletimeservice:1.0.0

docker push vishal26778/simpletimeservice:1.0.0

### Now use below command to pull from docker hub command and run into local

docker pull vishal26778/simpletimeservice:1.0.0
docker run -d -p 8080:8080 --name time-service vishal26778/simpletimeservice:1.0.0

### Test using below commands 

curl localhost:8080
{"timestamp":"2025-12-17T08:52:12Z","ip":"192.168.65.1:46150"}


curl localhost:8080/health
{"status":"healthy"}


