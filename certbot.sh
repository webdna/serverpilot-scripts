#!/bin/bash

# Bash wrapper for certbot renews
certbot renew

# Reload the config to take into account new certs
service nginx-sp reload
