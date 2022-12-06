echo "executing kubernetes installation script"
sudo apt update
status=$?
if test $status -eq 0
then
    curl -fsSL https://get.docker.com -oget-docker.sh
    status=$?
else
    echo "cant download the docker file"
    set -e
fi
if test $status -eq 0 
then
    docker info
    status=$?
fi
if test $status -eq 0
then
    echo "docker is already installed"
else
    sh get-docker.sh
    echo "enter your username"
    read username
    sudo usermod -aG docker $username
    echo "since the docker is installed for the first time you need to relogin"
    exit 0
    status=$?
    if test $status -eq 0
        then
            echo "docker installation completed"
        else
            echo "wrong username"
    fi
fi