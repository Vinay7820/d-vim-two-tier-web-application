#!/bin/bash
# Install outdated MongoDB intentionally
sudo apt-get update
sudo apt-get install -y mongodb=1:3.6.*
sudo systemctl enable mongodb
sudo systemctl start mongodb
