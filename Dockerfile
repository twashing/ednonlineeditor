FROM pandeiro/lein:latest

EXPOSE 80

WORKDIR /app
COPY . /app

RUN lein deps
