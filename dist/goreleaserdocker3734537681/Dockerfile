FROM devopsfaith/krakend

USER root

COPY krakend.json /etc/krakend/krakend.json

RUN apk update && apk add bash && apk add curl
RUN set -ex && apk --no-cache add sudo

RUN curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=NRAK-FGBHISKJUMWR9DXMIV4Q4EFZJTK NEW_RELIC_ACCOUNT_ID=3270596 /usr/local/bin/newrelic install -n logs-integration