
docker build -t 549637939820.dkr.ecr.eu-west-1.amazonaws.com/webservice-test:0.0.2 .

docker run -it --name test-api -e PREFIX_PATH=/ -p8080:8080 eu.gcr.io/slavayssiere-sandbox/api-test:latest

docker rm -f $(docker ps -aq)

curl -X GET http://localhost:8080/
curl -X GET http://localhost:8080/ips

curl -X GET http://localhost:8080/facture
curl -X GET http://localhost:8080/client

curl -X PUT http://localhost:8080/hack/latency/1000

curl -X POST -d '{ "path": "/tmp/health_KO" }' http://localhost:8080/hack/file
