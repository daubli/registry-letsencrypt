## Certbot

This docker image runs certbot-auto to automate issuance and renewal of letsencrypt certificates.

The certificates validity is checked at 06:00 every day. If the certificate is expired it gets renewed automatically.

The certificates are stored in the directory `/certs`. This directory can be mounted as docker volume to make the
certificated available for other applications.

### Run parameters

####Ports
The software inside the container exposes port 80. You should expose the same port on the docker host.

#### Volumes

- `/certs` certificates directory
- `/etc/letsencrypt` letsencrypt installation directory
- `/var/log/letsencrypt` logs directory 

#### Environment variables
- **LOGFILE:** path of a file where to write the logs from the certificate request/renewal script
- **DEBUG:** Show tracebacks in case of errors
- **STAGING:** Use the staging server to obtain or revoke test (invalid) certificates
- **DOMAINS:** Comma seperated list of domains to obtain a certificate for
- **EMAIL:** Your e-mail address for cert registration and notifications

### Build and run the container
#### Build
In case you have a compose file, simply build the container with:

`docker-compose build`
#### Run

`docker-compose up` 
