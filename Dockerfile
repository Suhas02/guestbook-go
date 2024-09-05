# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#FROM golang:1.23.0
#RUN go install github.com/urfave/negroni/ \
#    go install github.com/gorilla/mux/     \
#    go install github.com/xyproto/simpleredis/v2/
#WORKDIR /app
#COPY go.mod go.sum ./
#RUN go mod download
#COPY ..
#ADD ./main.go .
#RUN CGO_ENABLED=0 GOOS=linux go build -o main .

#FROM scratch
#WORKDIR /app
#COPY --from=0 /app/main .
#COPY ./public/index.html public/index.html
#COPY ./public/script.js public/script.js
#COPY ./public/style.css public/style.css
#CMD ["/app/main"]
#EXPOSE 3000

# Use the official Golang image as a build environment
FROM golang:1.18 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum to the container
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code into the container
COPY main.go ./

# Build the Go binary
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Start a new stage from scratch for a minimal final image
FROM scratch

# Set the working directory in the final image
WORKDIR /app

# Copy the binary and static files from the build stage
COPY --from=build /app/main .
COPY ./public/index.html public/index.html
COPY ./public/script.js public/script.js
COPY ./public/style.css public/style.css

# Specify the command to run the binary
CMD ["/app/main"]

# Expose the application port
EXPOSE 3000

