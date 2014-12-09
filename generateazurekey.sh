#!/bin/bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout myPrivateKey.key -out myCert.pem
chmod 600 myPrivateKey.key
openssl  x509 -outform der -in myCert.pem -out myCert.cer
