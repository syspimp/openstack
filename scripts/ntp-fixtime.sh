#!/bin/bash
systemctl stop ntpd
ntpdate 10.55.3.104
systemctl start ntpd
