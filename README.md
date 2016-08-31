# Create container
```
docker run -it -d --name=magento -h=magento -p 1080:80 -p 1022:22 cristo/magento:php7 /bin/bash
```


# MySQL
```
DB: magento
user: root 
password: root
```

# SSH
```
ssh -p1022 root@localhost
password: root
```

# NGINX server config file for communicate with docker
```
server {
        listen *:80;
        server_name localhost;
        proxy_set_header Host localhost;
        client_max_body_size 100M;

                location / {
                                proxy_set_header Host $host;
                                proxy_set_header X-Real-IP $remote_addr;
                                proxy_cache off;
                                proxy_pass http://localhost:1080;
                        }
}
```

# Origin
[Docker Hub] (https://registry.hub.docker.com/r/cristo/magento)

[Git Hub] (https://github.com/monte-fm/magento)

