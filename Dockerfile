FROM alpine:3.18.2 AS build
RUN apk update && apk upgrade
WORKDIR /app
RUN apk add --no-cache go
ADD app/ /app
RUN go get go.mongodb.org/mongo-driver/bson && \
  go get go.mongodb.org/mongo-driver/mongo && \
  go get go.mongodb.org/mongo-driver/mongo/options && \
  go get go.mongodb.org/mongo-driver/bson && \
  go build

FROM alpine:3.18.2
RUN apk update && apk upgrade
WORKDIR /app
RUN apk add --no-cache go
COPY --from=build /app/run ./
CMD [ "./run" ]