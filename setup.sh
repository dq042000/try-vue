#!/bin/bash

set -e

RemoveContainer () {
    lastResult=$?
    echo $lastResult
    if [ $lastResult -ne 0 ] && [ $lastResult -ne 130 ] && [ $lastResult -ne 16888 ]
    then
        echo "\033[0;101m安裝過程有錯誤，移除所有容器。\e[0m"
        echo "\033[0;101m第一次安裝請執行: sh setup.sh -init\e[0m"
        docker-compose down
    elif [ $lastResult -ne 16888 ]
    then
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

# 啟動服務
StartServices () {
    # 第一次安裝
    if [ "$1" = '-init' ]
    then
        # Install node modules
        docker exec -it ${containerNamePrefix}_vite_1 yarn && echo "\e[1;42m安裝前端所需套件... 成功\e[0m\n"
    fi

    # 測試啟動正式環境
    if [ "$1" = '-testbuild' ]
    then
        # Start build
        echo "\033[43m測試啟動正式環境\e[0m \n"
        docker exec -it ${containerNamePrefix}_vite_1 yarn build
        return 16888

    # 啟動開發環境
    else
        # Start develop
        echo "\033[43m啟動開發環境\e[0m \n"
        docker exec -it ${containerNamePrefix}_vite_1 yarn dev
    fi
}

# 啟動服務
# 第一次執行: sh setup.sh -init
# 測試啟動正式環境: sh setup.sh -testbuild
# 啟動開發環境: sh setup.sh
StartServices "$@"