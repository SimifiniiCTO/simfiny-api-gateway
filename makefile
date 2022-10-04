OUTPUT_FILE_NAME=config/krakend-flexible-config.compiled.json

validate:
	krakend check --config krakend.json -ddd -t
	cat krakend.json | jq >> output.json 
	mv output.json krakend.json 

lint: 
	helm lint ./charts/api-gateway

start-local:
	krakend run -c krakend.json -d

compose-up:
	docker-compose up

compose-up-d:
	docker-compose up -d

compose-down:
	docker-compose down

update-chart: 
	cp krakend.json ./charts/api-gateway

start-minikube:
	minikube start --memory 8192 --cpus 2

dev: start-minikube
	skaffold dev

deploy-minikube:
	eval $(minikube docker-env)
	docker build -t feelguuds/gateway:latest .
	helm upgrade --install api-gateway ./charts/api-gateway
	minikube dashboard

deploy:
	./deploy/deploy.sh

lint-gateway-configs:
	krakend check -tlc krakend.json

gen:
	FC_ENABLE=1 FC_SETTINGS="config/settings" FC_PARTIALS="config/partials" FC_TEMPLATES="config/templates" FC_OUT=$(OUTPUT_FILE_NAME) krakend check -t -ddd -c "config/krakend.tmpl"

lint-output: 
	krakend check -tlc $(OUTPUT_FILE_NAME)

prettiefy:
	cat $(OUTPUT_FILE_NAME) | jq >> krakend.compiled.json 
	mv krakend.compiled.json krakend.json
	rm $(OUTPUT_FILE_NAME)

autogen: gen lint-output prettiefy