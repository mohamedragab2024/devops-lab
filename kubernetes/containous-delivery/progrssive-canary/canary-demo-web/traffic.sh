#!/bin/bash

while true; do
    # Make a cURL request to the URL
    curl -sS "http://canary-demo-web.ragab.biz?error=true"

    # Wait for 300 milliseconds before the next iteration
    sleep 0.3
done
