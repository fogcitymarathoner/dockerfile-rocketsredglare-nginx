FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir /etc/nginx/sites-available
ADD sites-available /etc/nginx/sites-available