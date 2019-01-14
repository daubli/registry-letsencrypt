# Registry with Letsencrypt Certificates

This service stack issues [letsencrypt](https://letsencrypt.org/) certificates and starts a docker image registry
with a web frontend. The certificates are renewed automatically in case they expire. 
To start the service stack run the following command:  

    
    ./start-registry.sh domain.tld max.mustermann@domain.tld

The first parameter is the domain name that point to the server on which the services run. The second parameter is needed 
to issue the certificate and should be the email address of the responsible person of this domain. 

To stop the service stack run 

    docker-compose stop
    

If you want to start the docker-compose with `docker-compose up` replace the domain name environment variable $DOCKER_REGISTRY_DOMAIN_NAME with 
your desired domain name or assign a new value to $DOCKER_REGISTRY_DOMAIN_NAME by executing
        
        export DOCKER_REGISTRY_DOMAIN_NAME=domain.tld
        export DOCKER_REGISTRY_CERT_EMAIL_ADDRESS=max.mustermann@domain.tld
            

Please ensure that the file `start-registry.sh` is executable. If its not please run 

        chmod +x start-registry.sh

## Services

### Nginx 

[Nginx](https://hub.docker.com/_/nginx) is can be configured as a reverse proxy. This is necessary, because requests on port 80 can be of two 
different types. Requests that want to ensure the correctness of the certificate and request that want to reach the 
registry frontend. The leather ones get forwarded to port 443. Nginx can also be configured to deliver ssl certificates. 
So there is no need to pass the certificates to the frontend service, because the reverse proxy handles them.

The image gets three volumes. The first volume is for the configuration file, the second volume should contain the certificates and the third with the htpasswd file for 
basic http authentication.

    volumes:
      - ./conf/nginx:/etc/nginx/conf.d
      - ./data/certs:/certs
      - ./conf/auth:/auth


#### Example requests 

| Request | Regular expression in nginx | Add SSL Certificate in NGINX | Responsible Container |
| --- | ----------- | --- | ----------- |
| http://registry.docklab.de/.well-known/acme-challenge/9aZg7HEq_JyEnOnKn0fw0xrwDEUvTvx21owF6m_7MoM | /.well-known/acme-challenge/* | no | certbot:80 |
| http://registry.docklab.de/ | /* | no | nginx:443 |
| https://registry.docklab.de/v2/ | /v2/* | yes | registry:5000 | 
| https://registry.docklab.de/ | /* | yes | registryui:80 |    

You can get more detailed information by reading the docker documention [here.](https://docs.docker.com/registry/recipes/nginx/)

#### Overview over nginx configuration

![Overview](overview.png)
      
 
### Certbot

The certbot image is a wrapper of the official [certbot/certbot](https://hub.docker.com/r/certbot/certbot/)
image which can issue certificates from letsencrypt. The wrapper adds the 
functionality that certificates are renewed in case they expire in the next 28 days.
 
For more information read the [certbot README](/certbot/README.md).

### Registry

#### Configuration

##### Ports

The registry image exposes the port **5000**. You can map this port to another on the host machine. 
In the use case of this project we let point the nginx reverse proxy to that port. 

##### Volumes

The following volumes should be mounted:

    volumes:
      - ./data/registry:/var/lib/registry

The *registry* volume stores the data pushed to the registry. 

### Registry frontend

The registry frontend is implemented in the image [docker-registry-frontend](https://github.com/kwk/docker-registry-frontend) maintained by Konrad Kleine.

#### Configuration
 
##### Ports
The image exposes port 443
 
##### Environment variables
- **ENV_DOCKER_REGISTRY_HOST:** The host / container where the registry is running
- **ENV_DOCKER_REGISTRY_PORT:** The port on which the registry is runnings 
- **ENV_DOCKER_REGISTRY_USE_SSL:** Whether the registry uses ssl or not

##### Volumes (if you don't need a proxy server)
In case you want an encrypted frontend without using a proxy server it is necessary to mount your 
certificates to `/etc/apache2/server.key` and `/etc/apache2/server.crt` and set the environment variable `ENV_USE_SSL=yes`

    environment:
      - ENV_USE_SSL=yes
    volumes:
      - ./certs/server.key:/etc/apache2/server.key:ro
      - ./certs/server.crt:/etc/apache2/server.crt:ro
      
      