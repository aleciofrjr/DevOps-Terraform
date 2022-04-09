#!/bin/bash

dstat --time --cpu --mem --output monitor.csv 1 5

if [ -e monitor.csv ]
    then {
        echo "Arquivo monitor.csv existe!"
        echo "Convertendo CSV -> JSON!"
        sudo csvtojson monitor.csv | jq >> /var/www/html/index.json
    }
    else {
        echo "Arquivo monitor.csv não existe, é necessário cria-lo!"
    }
fi
