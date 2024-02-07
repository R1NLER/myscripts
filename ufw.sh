#!/bin/bash

while true; do
    # Display UFW rules with numbers
    ufw status numbered

    # Ask the user for the rule number to delete
    echo "Enter the rule number to delete (or 0 to exit):"
    read rule_number

    # If the user input is 0, then exit the script
    if [ "$rule_number" == "0" ]; then
        echo "Exiting script."
        exit 0
    fi

    # Execute UFW delete command with the rule number provided by the user
    ufw delete "$rule_number"
done
