#!/bin/bash

hostnamectl set-hostname red-team-${index}

apt update
apt install nmap ftp telnet -y