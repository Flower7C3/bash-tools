#!/usr/bin/env bash

cd ~/Library/Mail
find . -type f -name ".mboxCache.plist" -exec ls -la {} \; .
