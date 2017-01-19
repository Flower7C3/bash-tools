#!/usr/bin/env bash

sudo apt-get install wkhtmltopdf
sudo ln -s /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
sudo chmod a+x /usr/local/bin/wkhtmltopdf
sudo apt-get install openssl build-essential xorg libssl-dev
sudo apt-get install xvfb

sudo rm /usr/local/bin/wkhtmltopdf.sh
sudo touch /usr/local/bin/wkhtmltopdf.sh
sudo sh -c "echo 'xvfb-run -a -s \"-screen 0 640x480x16\" wkhtmltopdf \"\$@\"' > /usr/local/bin/wkhtmltopdf.sh"
sudo chmod a+x /usr/local/bin/wkhtmltopdf.sh

sudo rm /usr/bin/wkhtmltopdf.sh
sudo ln -s /usr/local/bin/wkhtmltopdf.sh /usr/bin/wkhtmltopdf.sh
