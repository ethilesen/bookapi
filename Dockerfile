FROM node:7.10.0

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY package.json /usr/src/app/
RUN npm install


COPY knexfile.js .
COPY migrations migrations
COPY api api

EXPOSE 3000
CMD [ "node", "api/index.js" ]
