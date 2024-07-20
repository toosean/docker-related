# Ref

https://phoenixnap.com/kb/letsencrypt-docker

# Steps
- clone the repo to local
- cd into the folder
- mkdir ./etc/nginx/conf.d/ -p
- nano ./etc/nginx/conf.d/app.conf

```
server {
    listen 80;
    listen [::]:80;

    server_name [domain-name] www.[domain-name];
    server_tokens off;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://[domain-name]$request_uri;
    }
}
```

- docker compose up -d  webserver

- docker compose run --rm certbot certonly --webroot --webroot-path /var/www/certbot/ -d [domain-name]

- nano ./etc/nginx/conf.d/app.conf

    > add the following lines to the file

```
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name [domain-name];

    ssl_certificate /etc/letsencrypt/live/[domain-name]/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/[domain-name]/privkey.pem;
    
    location / {
        # proxy_pass or root
    }
}
```

- docker compose restart webserver