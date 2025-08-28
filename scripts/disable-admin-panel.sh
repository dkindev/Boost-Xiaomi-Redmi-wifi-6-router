#!/bin/sh

# Disable admin panel to clean up RAM
/etc/init.d/nginx stop
/etc/init.d/nginx disable