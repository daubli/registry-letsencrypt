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
- **HEALTH_CHECK_URL:** URL that has to response before certbot become active (e.g a reverse proxy)
- **RENEWED_CERTS_HOOK:** Command that can be used for example to notify another container that certificates where
                             renewed and that the configuration (e.g of nginx) should be reloaded

