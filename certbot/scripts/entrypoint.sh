#!/bin/sh
/scripts/certbot.sh
# scheduling periodic executions
exec crond -f
