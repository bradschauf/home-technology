#!/bin/zsh
# OLD Bluehost shared hosting server (being decommissioned).
# theschaufs.com DNS now points at AWS, so connect to Bluehost by IP directly.
# Host: box2232.bluehost.com (50.87.221.44), cPanel user theschau.
# NOTE: Bluehost cPHulk may temporarily block the IP after rapid repeated SSH attempts.
ssh theschau@50.87.221.44 -i ~/.ssh/schauf.priv
