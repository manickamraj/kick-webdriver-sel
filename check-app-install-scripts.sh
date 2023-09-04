#!/bin/bash

# Function to check if given command exist !!
is_Command_Exist(){
    local arg="$1"
    type "$arg" &> /dev/null
    return $?
}

# Function to check if given application exist !!
is_App_Exist(){
    local arg="$1"
    dpkg -l | grep "$arg" &> /dev/null
    return $?	
}

# Function to check if given directory exist !!
is_Dir_Exist(){
    local arg="$1"
    ls -d "$arg" &> /dev/null
    return $?	
}

# Install Function
install_package(){
    local arg="$1"
    sudo apt-get install -y "$arg"
}

# Check Java exist or not?
if is_Command_Exist "java"; then
    echo "Java is installed in this ubuntu"
else
    echo "Java is not installed"
    install_package "openjdk-8-jdk";
fi

# Check Maven exist or not?
if is_Command_Exist "mvn"; then
    echo "Maven is installed in this ubuntu"
else
    echo "mvn is not installed"
    install_package "maven";
fi

# Check xvfb exist or not?
if is_App_Exist "xvfb"; then
    echo "xvfb is installed in this ubuntu"
else
    echo "xvfb is not installed"
    install_package "xvfb";
    Xvfb :99 &
    export DISPLAY=:99	
fi

# Check Chrome exist or not?
if is_App_Exist "chrome"; then
    echo "Chrome is installed in this ubuntu"
else
    echo "Chrome is not installed"
    wget http://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_114.0.5735.198-1_amd64.deb
    sudo dpkg -i google-chrome-stable_114.0.5735.198-1_amd64.deb
    sudo apt --fix-broken install	
fi

#Clone or Pull WebDriver scripts
if is_Dir_Exist "webdriver-tests"; then
    echo "Latest scripts are pulled from git"
    cd webdriver-tests/
    git pull
    cd ..
else
    echo "Fresh scripts are cloned from git"
    git clone https://github.com/TestLeafInc/webdriver-tests
fi


# Executing webdriver scripts and pushing the results to S3 bucket
    cd webdriver-tests	
    mvn clean test
    aws s3 sync reports/ s3://ubuntu-autoreports