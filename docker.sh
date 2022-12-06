echo "executing docker installation script"
sudo apt update
status=$?
if test $status -eq 0
then
    curl -fsSL https://get.docker.com -oget-docker.sh
else
    echo "cant download the docker file"
fi
docker info
status=$?
if test $status -eq 0
then
    echo "docker is already installed"
else
    sh get-docker.sh
    echo "enter your username"
    read username
    sudo usermod -aG docker $username
fi