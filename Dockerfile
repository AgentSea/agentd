FROM --platform=$TARGETPLATFORM lscr.io/linuxserver/webtop:latest

COPY . /config/agentd/

RUN apk update && \
    apk add --no-cache python3 py3-pip build-base libffi-dev openssl-dev curl poetry python3-dev

RUN ls /config/agentd

RUN cd /config/agentd && poetry install

RUN mkdir -p /etc/services.d/uvicorn

COPY uvicorn-run.sh /etc/services.d/uvicorn/run

RUN chmod +x /etc/services.d/uvicorn/run