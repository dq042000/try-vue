#!/bin/bash

set -e

RemoveContainer () {
    lastResult=$?
    echo $lastResult
    if [ $lastResult -ne 0 ] && [ $lastResult -ne 130 ]
    then
        echo "\033[0;101m安裝過程有錯誤，移除所有容器\e[0m"
        docker-compose down
    else
        echo "\033[0;101mAborting...\e[0m"
        docker-compose down
    fi
}
trap RemoveContainer EXIT

# 取得資料夾名稱，因資料夾名稱是容器名稱的 prefix
dir=$(pwd)
fullPath="${dir%/}";
containerNamePrefix=${fullPath##*/}

echo "\033[46m現在位置 - ${containerNamePrefix}\e[0m \n"

# Copy config files
cp docker-compose.yml.sample docker-compose.yml

# Start container
docker-compose up -d --build && echo "\e[1;42m啟動容器...成功\e[0m"

# 第一次安裝
InstallDB () {    
    if [ "$1" != '-nodb' ]
    then
        # Install node modules
        docker exec -it ${containerNamePrefix}_vite_1 yarn && echo "\e[1;42m安裝前端所需套件... 成功\e[0m\n"
    fi
}

# 安裝 DB (如果沒有傳參數 -nodb，就執行安裝 DB)
InstallDB "$@"

# Start develop
echo "\033[43m啟動開發環境\e[0m \n"
docker exec -it ${containerNamePrefix}_vite_1 yarn dev