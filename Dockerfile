FROM node:18 AS build
WORKDIR /app


COPY . .


RUN yarn install


RUN yarn workspace ra-core build
RUN yarn workspace ra-i18n-polyglot build
RUN yarn workspace ra-language-english build
RUN yarn workspace ra-language-french build
RUN yarn workspace ra-data-simple-rest build
RUN yarn workspace ra-data-fakerest build
RUN yarn workspace ra-data-graphql build
RUN yarn workspace ra-data-graphql-simple build
RUN yarn workspace ra-data-json-server build
RUN yarn workspace ra-data-local-storage build
RUN yarn workspace ra-i18n-i18next build
RUN yarn workspace ra-ui-materialui build
RUN yarn workspace ra-input-rich-text build
RUN yarn workspace react-admin build
RUN yarn workspace ra-no-code build
RUN yarn workspace data-generator-retail build


RUN cd examples/demo && npx vite build


FROM nginx:alpine


COPY --from=build /app/examples/demo/dist /usr/share/nginx/html


RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
