#!/bin/bash
# Check if script is run with sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or with sudo" 
   exit 1
fi


trap "unset sitename dbname dbuser confirmation choice choicemysql dbpassword rootpassword" EXIT
echo
echo "########################################################"
echo "###           R1NLER Script for Wordpress            ###"
echo "###        GitHub: https://github.com/R1NLER         ###"
echo "########################################################"

sleep 2s

while true; do
    read -p "Your site: " sitename
    read -p "Your database: " dbname
    read -p "Your database user: " dbuser
    echo "Your site: $sitename"
    echo "Your database: $dbname"
    echo "Your database user: $dbuser"

    read -p "Is the information correct? (Y for Yes, N for No, Q for Quit): " confirmation

    case "$confirmation" in
    Y|y)
        while true; do
            read -p "Do you want to enter your own password for the database user? (Y for Yes, N for No): " choice

            case "$choice" in
            Y|y)
                while true; do
                    read -sp "Enter your password: " dbpassword
                    if [[ ${#dbpassword} -ge 8 ]] && [[ $dbpassword =~ [A-Z] ]] && [[ $dbpassword =~ [a-z] ]] && [[ $dbpassword =~ [0-9] ]] && [[ $dbpassword =~ [^a-zA-Z0-9] ]]; then
                        echo
                        echo -e "\e[32mValid password\e[0m"
                        break
                    fi
                    echo
                    echo -e "\e[31mError: Password must be at least 8 characters, with at least one uppercase letter, one lowercase letter, one number, and one special character.\e[0m"
                done
                break
                ;;
            N|n)
                echo "A secure random password will be generated."
                dbpassword=$(openssl rand -base64 12)
                echo "Your secure random password is: $dbpassword"
                echo -e "\e[31mALERT: You must copy this password, this password wont be showed again. PLease retype your user password again to continue: \e[0m"
                while true; do
                    read -sp "Please confirm your password: " passwordconfirm
                    if [[ "$dbpassword" == "$passwordconfirm" ]]; then
                        echo -e "\e[32mPassword confirmed.\e[0m"
                        break
                    else
                        echo -e "\e[31mError: Passwords do not match. Please try again.\e[0m"
                    fi
                done
                break
                ;;
            *)
                echo -e "\e[31mError: Invalid choice. Please enter Y or N.\e[0m"
                ;;
            esac
        done
        break
        ;;
    N|n)
        echo "Please re-enter the information."
        continue
        ;;
    Q|q)
        echo "Quitting the script."
        exit 0
        ;;
    *)
        echo -e "\e[31mError: Invalid choice. Please enter Y or N or Q.\e[0m"
        ;;
    esac
done

echo
echo "#######################################"
echo "###       MYSQL Installation        ###"
echo "#######################################"
echo

sleep 2s

# Check if MySQL is installed
if ! command -v mysql >/dev/null 2>&1; then
    read -p "MySQL is not installed. Do you want to install MySQL now? (Y/N): " choice

    if [[ $choice =~ ^[Yy]$ ]]; then
        # Install MySQL
        sudo apt-get install mysql-server mysql-client

        # Start MySQL service
        sudo service mysql start

        # Generate new password
        rootpassword=$(openssl rand -base64 12)
        echo "Your new MySQL root password is: $rootpassword"

        # Change MySQL root password
        sudo mysqladmin -u root password "$rootpassword"

        while true; do
            read -sp "Please enter your new MySQL root password to continue: " passwordconfirm
            if [[ "$rootpassword" == "$passwordconfirm" ]]; then
                echo -e "\e[32mCorrect password. Continuing script execution...\e[0m"
                break
            else
                echo -e "\e[31mError: Passwords do not match. Please try again.\e[0m"
            fi
        done

    else
        echo -e "\e[31mError: MySQL is not installed. Please install MySQL and run this script again.\e[0m"
        exit 1
    fi
else
    echo -e "\e[32mMySQL already installed\e[0m"
    read -sp "Insert your MySQL root password: " rootpassword
fi


echo -e "\e[32mCreating database...\e[0m"
sleep 1s
echo -e "\e[32mCreating user...\e[0m"
sleep 1s
echo -e "\e[32mDone! \e[0m"
sleep 3s


# Set up MySQL
mysql -u root -p$rootpassword << EOF
CREATE DATABASE $dbname;
CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpassword';
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';
FLUSH PRIVILEGES;
EOF


echo
echo "#######################################"
echo "###      Wordpress Installation     ###"
echo "#######################################"
echo

# Download and install WordPress
sudo mkdir /var/www/html/$sitename
wget -O latest.tar.gz https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz -C /var/www/html/$sitename --strip-components=1
rm latest.tar.gz 

# Configure WordPress
cd /var/www/html/$sitename
sudo cp wp-config-sample.php wp-config.php
sudo sed -i 's/database_name_here/'$dbname'/; s/username_here/'$dbuser'/; s/password_here/'$dbpassword'/' wp-config.php

# Adjust permissions of files and directories
sudo chown -R www-data:www-data /var/www/html/$sitename
sudo find /var/www/html/$sitename -type d -exec chmod 755 {} \;
sudo find /var/www/html/$sitename -type f -exec chmod 644 {} \;


# Cleaning system
unset sitename dbname dbuser confirmation choice choicemysql dbpassword rootpassword passwordconfirm



echo -e "\e[32mWordpress has been installed correctly on your system. Please configure your web server to access the site.\e[0m"