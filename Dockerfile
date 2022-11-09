FROM devopsfaith/krakend

USER root

COPY krakend.json /etc/krakend/krakend.json

RUN apk update && apk add bash && apk add curl
RUN set -ex && apk --no-cache add sudo