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
	FC_ENABLE=1 FC_SETTINGS="config/settings" FC_PARTIALS="config/partials" FC_TEMPLATES="config/templates" FC_OUT=$(OUTPUT_FILE_NAME) krakend run -c "config/krakend.tmpl" \

lint-output: krakend check -tlc $(OUTPUT_FILE_NAME)

prettiefy:
	jq . $(OUTPUT_FILE_NAME)

autogen: gen lint-output prettiefy 

compile-flexible-config:
	sudo docker run \
        -v $(PWD)/config/:/etc/krakend/ \
        -e FC_ENABLE=1 \
        -e FC_SETTINGS=/etc/krakend/settings \
        -e FC_PARTIALS=/etc/krakend/partials \
        -e FC_TEMPLATES=/etc/krakend/templates \
        -e FC_OUT=/etc/krakend.json \
        devopsfaith/krakend \
        check -c krakend.tmpl