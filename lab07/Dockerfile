# Set the base image to Ubuntu
FROM alpine:latest

# Update the repository sources list and install python3
#RUN apk update && apk add python3
RUN apk add --no-cache python3

# install pip and install requests
RUN easy_install-3.7 pip && pip3 install requests

COPY myip.py /usr/local/bin

# Set default container command
ENTRYPOINT /usr/bin/python3 /usr/local/bin/myip.py
