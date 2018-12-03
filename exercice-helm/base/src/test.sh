
docker build -t eu.gcr.io/sandbox-wescale/webservice:v6 .

docker run -it --name test-api -e PREFIX_PATH=/ -p8080:8080 eu.gcr.io/sandbox-wescale/webservice:v7

docker rm -f $(docker ps -aq)

curl -X GET http://localhost:8080/
curl -X GET http://localhost:8080/ips

curl -X GET http://localhost:8080/facture
curl -X GET http://localhost:8080/client

curl -X PUT http://localhost:8080/hack/latency/1000

curl -X POST -d '{ "path": "/tmp/health_KO" }' http://localhost:8080/hack/file
