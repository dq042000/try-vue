#!/bin/bash

set -e

# color https://blog.csdn.net/qq_42372031/article/details/104137272
COLOR_RED='\e[0;31m';
COLOR_GREEN='\e[0;32m';
COLOR_YELLOW='\e[0;33m';
COLOR_BLUE='\e[0;34m';
COLOR_REST='\e[0m'; # No Color
COLOR_BACKGROUND_RED='\e[0;101m';
COLOR_BACKGROUND_GREEN='\e[1;42m';
COLOR_BACKGROUND_YELLOW='\e[1;43m';
COLOR_BACKGROUND_BLUE_GREEN='\e[46m'; # 青色

RemoveContainer () {
    lastResult=$?
    if [ $lastResult -ne 0 ] && [ $lastResult -ne 130 ] && [ $lastResult -ne 16888 ]; then
        echo "$COLOR_BACKGROUND_RED 狀態:$lastResult, 啟動專案過程有錯誤，移除所有容器。 $COLOR_REST"
        docker-compose down
    elif [ $lastResult = 16888 ]; then
        echo "$COLOR_BACKGROUND_RED 中止... $COLOR_REST"
        docker-compose down
    fi
}
trap RemoveContainer EXIT

# 初始化
Init() {
    # 取得資料夾名稱，因資料夾名稱是容器名稱的 prefix
    dir=$(pwd)
    fullPath="${dir%/}";
    containerNamePrefix=${fullPath##*/}
    echo "$COLOR_BACKGROUND_BLUE_GREEN 現在位置 - ${containerNamePrefix} $COLOR_REST"

    # Copy config files
    cp env-sample .env
    cp docker-compose.yml.sample docker-compose.yml
    echo "$COLOR_BACKGROUND_YELLOW 複製 Config 檔案...成功 $COLOR_REST"

    # 讀取「.env」
    . ${dir}/.env
}

# 預設設定
DefaultSetting() {
    Init # 初始化

    # Start container
    docker-compose up -d --build && echo "$COLOR_BACKGROUND_GREEN 啟動容器...成功 $COLOR_REST"

    # Install node modules
    docker exec -it ${containerNamePrefix}_vue_1 yarn && echo "$COLOR_BACKGROUND_GREEN 安裝前端所需套件... 成功 $COLOR_REST"
}

# 主選單
MainMenu() {
    clear
    echo $COLOR_YELLOW"======= 選單 =========================="$COLOR_REST;
    echo $COLOR_YELLOW"|    (1) 專案初始化並啟動開發環境     |"$COLOR_REST;
    echo $COLOR_YELLOW"|    (2) 啟動開發環境                 |"$COLOR_REST;
    echo $COLOR_YELLOW"|    (3) 模擬啟動正式環境             |"$COLOR_REST;
    echo $COLOR_YELLOW"|    (4) 更新 npm 套件                |"$COLOR_REST;
    echo $COLOR_YELLOW"|    (Q) 離開                         |"$COLOR_REST;
    echo $COLOR_YELLOW"======================================="$COLOR_REST;
    read -p "請輸入要執行的項目($(tput setaf 2 )1-5$(tput sgr0))[$(tput setaf 3 )2$(tput sgr0)]:" -r user_select
    user_select=${user_select:-2}   # 預設為 2
    user_select_uppercase=$(echo "$user_select" | tr '[:upper:]' '[:lower:]')   # 轉換為小寫

    ########################################
    # 專案初始化並啟動開發環境
    if [ $user_select = 1 ]; then
        # Run default setting
        DefaultSetting

        # Change permission
        sudo chmod 777 -R web/${PHP_DIRECTORY}/data

        # Start develop
        docker exec -it ${containerNamePrefix}_vue_1 yarn dev

        echo "$COLOR_BACKGROUND_YELLOW 專案初始化並啟動開發環境... 成功 $COLOR_REST"
        return 16888

    ########################################
    # 啟動開發環境
    elif [ $user_select = 2 ]; then
        # Run default setting
        DefaultSetting

        # Start develop
        docker exec -it ${containerNamePrefix}_vue_1 yarn dev

        echo "$COLOR_BACKGROUND_YELLOW 啟動開發環境... 成功 $COLOR_REST"
        return 16888

    ########################################
    # 模擬啟動正式環境
    elif [ $user_select = 3 ]; then
        # Run default setting
        DefaultSetting

        # Start build
        docker exec -it ${containerNamePrefix}_vue_1 yarn build

        echo "$COLOR_BACKGROUND_YELLOW 模擬啟動正式環境... 成功 $COLOR_REST"
        return 16888

    ########################################
    # 更新 npm 套件
    elif [ $user_select = 4 ]; then
        # Update node modules
        docker exec -it ${containerNamePrefix}_vite_1 yarn && echo "$COLOR_BACKGROUND_GREEN 更新前端所需套件... 成功 $COLOR_REST"
        return 0

    ########################################
    # 離開
    elif [ "$user_select_uppercase" = 'q' ]; then
        clear
        return 0

    else
        echo "$COLOR_BACKGROUND_RED 請輸入要執行的指令... $COLOR_REST"
        return 0
    fi
}

MainMenu # 開始執行主選單