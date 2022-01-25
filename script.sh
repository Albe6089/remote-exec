#!/bin/bash
for user in $( cat ./user-list1.txt ); do
    
    sudo    mkdir -p /home/$user/.ssh
    sudo    cat /path/to/pubkey >> /home/$user/.ssh/authorized_keys
    sudo    chmod 700 /home/$user/.ssh
    sudo    chmod 640 /home/$user/.ssh/authorized_keys
    sudo    chown -R $user.$user /home/$user/.ssh
    
done