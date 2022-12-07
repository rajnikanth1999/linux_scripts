echo "executing kubernetes installation script"
echo "When you dont have docker installed. This script will install docker as well.Please enter your username when it asks."
echo "If you're installed docker using this script then please exit and relogin to load docker and then execute the script again"
echo "If you're executing this script to install only kubernetes then it might throw an error but dont worry just ececute the script again then it will install and configure the complete kubernetes services."
sleep 10s
sudo apt update
status=$?
if test $status -eq 0
then
    curl -fsSL https://get.docker.com -oget-docker.sh
    status=$?
else
    echo "cant download the docker file"
    exit 1
fi
if docker info
then
    echo "docker is already installed"
else
    sh get-docker.sh
    echo "enter your username"
    read username
    sudo usermod -aG docker $username
    status=$?
    if test $status -eq 0
        then
            echo "docker installation completed"
        echo "since the docker is installed for the first time you need to relogin and execute the script again"
        exit 0
        else
            echo "wrong username"
    fi
fi
sudo su  - <<EOF
echo "This script is now running as a root user"
if go version
then
    echo "go lang is already installed"
else
    echo "Installing go lang"
    wget https://storage.googleapis.com/golang/getgo/installer_linux
    chmod +x ./installer_linux
    ./installer_linux
    source ~/.bash_profile
    go version
    echo "go installed sucessfully"
    status=$?
fi
if [ -d "cri-dockerd" ] 
then
    echo "cri-dockerd already exists"
    cd cri-dockerd
    git pull
    go build -o bin/cri-dockerd
    systemctl daemon-reload
    systemctl enable cri-docker.service
    systemctl enable --now cri-docker.socket
    status=$?
else
    echo "installing dockerd"
    echo "cloning dockerd repository"
    git clone https://github.com/Mirantis/cri-dockerd.git
    cd cri-dockerd
    mkdir bin
    echo "installing cri-dockerd please wait"
    go build -o bin/cri-dockerd
    mkdir -p /usr/local/bin
    install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
    cp -a packaging/systemd/* /etc/systemd/system
    sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
    echo "installed dockerd"
    systemctl daemon-reload
    systemctl enable cri-docker.service
    systemctl enable --now cri-docker.socket
    status=$?
    echo $status
fi
if test $status -eq 0
then 
    echo "started dockerd"
else
    echo "something is wrong. Plese execute the script again" 
fi
if kubectl get nodes
then
    echo "Kubernetes is already installed"
    exit 1
else
    echo "installing kube admin, kubectl, kubelet"
    sudo apt update
    status=$?
fi

if test $status -eq 0
then
    sudo apt-get install -y apt-transport-https ca-certificates curl
    sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    status=$?
    sudo apt-mark hold kubelet kubeadm kubectl
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
    echo "If there is any error here please execute the script again"
    echo "If you execute the script for the first time it is most probably throw an error"
    echo "To execute the script again use 'sh kubernetes_script.sh or use your scripts name if you copy the script to some other file name"
    echo ""
    echo ""
    echo ""
    echo ""
    echo ""
else
    echo "something is wrong. Plese execute the script again" 
    exit 1
fi
if test $status -eq 0
then
    echo "kubernetes is successfully installed"
else
    echo "something is wrong. Plese execute the script again" 
    exit 1
fi
EOF
echo "Now run the kubeadm join command with --cri-socket included to join this node to the master"
echo "enter the kube join command of your master"
read join
sudo="sudo "
joined=$sudo$join
command=" --cri-socket=unix:///var/run/cri-dockerd.sock"
commands=$joined$command
sudo su  - <<EOF
echo $commands
eval $commands
EOF
echo "Your kubernetes node is ready now"