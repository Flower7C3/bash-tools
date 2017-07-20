#!/usr/bin/env bash

apt-get update
apt-get install -y --fix-missing wkhtmltopdf openssl build-essential xorg libssl-dev xvfb
ln -s /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
chmod a+x /usr/local/bin/wkhtmltopdf

rm /usr/local/bin/wkhtmltopdf.sh
touch /usr/local/bin/wkhtmltopdf.sh
sh -c "echo 'xvfb-run -a -s \"-screen 0 640x480x16\" wkhtmltopdf \"\$@\"' > /usr/local/bin/wkhtmltopdf.sh"
chmod a+x /usr/local/bin/wkhtmltopdf.sh

rm /usr/bin/wkhtmltopdf.sh
ln -s /usr/local/bin/wkhtmltopdf.sh /usr/bin/wkhtmltopdf.sh
