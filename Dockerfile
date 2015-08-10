#
# Node.js Dockerfile
#
# https://github.com/dockerfile/nodejs
#

# Pull base image.
FROM ubuntu:14.04

# Install Node.js
RUN apt-get update
RUN apt-get install --yes curl git ruby python build-essential
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install --yes nodejs 
RUN gem install sass
RUN npm install -g sails

# add the package for npm install
ADD package.json /app/
WORKDIR /app
RUN npm install .

# add the rest after
ADD api/ /app/api/
ADD assets/ /app/assets/
ADD config/ /app/config/
ADD tasks/ /app/tasks/
ADD views/ /app/views/
ADD app.coffee Gruntfile.js /app/

RUN apt-get install --yes lua5.2

ENV NODE_ENV docker
ENV PORT 1337
EXPOSE 1337

CMD ["bash", "-c", "sails lift"]
