# set the base image to Ubuntu
FROM alpine:latest

# install NGINX
RUN apk add --no-cache nginx

# copy new default page

RUN mkdir -p /run/nginx
COPY default.conf /etc/nginx/conf.d/
COPY index.html /var/lib/nginx/html/

# expose default ports
EXPOSE 80

# Set default container command
#ENTRYPOINT [ "nginx" ]
#ENTRYPOINT ["nginx", "-g 'pid /tmp/nginx.pid; daemon off;'"]
CMD ["nginx", "-g", "daemon off;"]