FROM golang:alpine AS build
LABEL maintainer="elvia@elvia.no"

ENV GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o ./out/executable ./cmd/demo-api-go


FROM alpine:3.20
LABEL maintainer="elvia@elvia.no"

RUN addgroup application-group --gid 1001 && \
    adduser application-user --uid 1001 \
        --ingroup application-group \
        --disabled-password

WORKDIR /app

COPY --from=build /app/out .

RUN chown --recursive application-user .
USER application-user

EXPOSE 8080

ENTRYPOINT ["./executable"]
