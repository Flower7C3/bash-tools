#!/usr/bin/env

cd ~/Library/Mail
find . -type f -name ".mboxCache.plist" -exec ls -la {} \; .
