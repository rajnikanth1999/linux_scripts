echo "This script will install elastic search"
sudo apt update
status=$?
if test $status -eq 0
then
    if [ -f "/usr/share/keyrings/elasticsearch-keyring.gpg" ] 
    then
        echo "file already exists"
        status=$?
    else
        echo "file not found"
        wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
        status=$?
    fi
else
    echo "something is wrong please run the script again"
    return 1
fi
if test $status -eq 0
then
    sudo apt-get install apt-transport-https -y
    status=$?
else
    echo "something is wrong please run the script again"
    return 1
fi
if test $status -eq 0
then
    echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
    status=$?
else
    echo "something is wrong please run the script again"
    return 1
fi
if test $status -eq 0
then
    sudo apt-get update && sudo apt-get install elasticsearch -y
    status=$?
else
    echo "something is wrong please run the script again"
    return 1
fi
if test $status -eq 0 
then 
    echo "Elastic search has installed successfully"
    echo "Starting the elastic search by deamon reloading"
    sudo systemctl daemon-reload
    status=$?
else
    echo "something is wrong please run the script again"
    return 1
fi
if test $status -eq 0
then
    echo "Completed daemon reload"
    sudo systemctl enable elasticsearch.service
    status=$?
    if test $status -eq 0
    then
        echo "Enabled elasticsearch.service"
    else
        echo "elasticsearch is not enabled properly"
        return 1
    fi
    sudo systemctl start elasticsearch.service
    status=$?
    if test $status -eq 0
    then
        echo "Started elasticsearch.service"
    else
        echo "elastic search is not started properly"
        return 1
    fi
    sudo systemctl status elasticsearch.service
    status=$?
    if test $status -eq 0
    then
        echo "status of elasticsearch.service"
    else
        echo "status of elasticsearch.service has messedup"
        return 1
    fi
    status=$?
else
    echo "something is wrong please run the script again"
    return 1
fi
echo "Script executed without any error"