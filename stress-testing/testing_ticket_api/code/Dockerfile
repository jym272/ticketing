FROM golang:1.20.4-alpine3.18 as base

FROM base as builder

# Set destination for COPY
WORKDIR /app

# Download Go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code. Note the slash at the end, as explained in
# https://docs.docker.com/engine/reference/builder/#copy
COPY . ./

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o /run_test

# https://docs.docker.com/language/golang/build-images/#tag-images
FROM scratch

WORKDIR /app

COPY --from=builder /run_test /run_test

ENTRYPOINT ["/run_test"]








