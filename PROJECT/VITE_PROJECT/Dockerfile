FROM node:20.11.1 as node

WORKDIR /opt/app

COPY package*.json .

RUN npm install --force

COPY . .

RUN npm run build

#RUN npm run preview

FROM nginx:1.17

RUN rm -rf /etc/nginx/conf.d/*

COPY frontend.conf /etc/nginx/conf.d/

COPY --from=node /opt/app/dist/ /var/app/html
