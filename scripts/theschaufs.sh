#!/bin/zsh
# theschaufs.com now points at the NEW server (AWS Lightsail schauf-server).
# This SSHes into it. For the OLD Bluehost shared server, use ./old-theschaufs.sh
ssh ubuntu@44.231.156.226 -i ~/.ssh/schauf-server.pem
