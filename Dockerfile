# Looking for information on environment variables?
# We don't declare them here — take a look at our docs.
# https://github.com/swagger-api/swagger-ui/blob/master/docs/usage/configuration.md
FROM node:lts-buster as base

WORKDIR /tmp/build

COPY package.json ./
RUN npm install --no-optional

COPY ./webpack/ ./webpack/
COPY ./src ./src/

RUN npm run-script build

FROM nginx:1.19-alpine as final

RUN apk --no-cache add nodejs

LABEL maintainer="fehguy"

ENV API_KEY "**None**"
ENV SWAGGER_JSON "/app/swagger.json"
ENV PORT 8080
ENV BASE_URL ""
ENV SWAGGER_JSON_URL ""

COPY ./docker/nginx.conf ./docker/cors.conf /etc/nginx/

COPY --from=base /tmp/build/dist/* /usr/share/nginx/html/
COPY ./docker/run.sh /usr/share/nginx/
COPY ./docker/configurator /usr/share/nginx/configurator

RUN chmod +x /usr/share/nginx/run.sh && \
    chmod -R a+rw /usr/share/nginx && \
    chmod -R a+rw /etc/nginx && \
    chmod -R a+rw /var && \
    chmod -R a+rw /var/run

EXPOSE 8080

CMD ["sh", "/usr/share/nginx/run.sh"]
