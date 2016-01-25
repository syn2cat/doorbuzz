#!/bin/bash
wget -qO - http://10.2.113.6/output.cgi |
sed 's/.*Occupancy://'|
awk '{print $2}' 

