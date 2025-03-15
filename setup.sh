#!/bin/bash

#####################################################################
# 一旦任何命令返回非零的退出狀態，腳本將立即終止執行，而不會繼續執行後續命令
set -e

#####################################################################
# Color https://blog.csdn.net/qq_42372031/article/details/104137272
# 文字顏色
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_BLUE=$(tput setaf 4)
COLOR_REST=$(tput sgr0) # No Color

# 背景顏色
COLOR_BACKGROUND_RED=$(tput setab 1)
COLOR_BACKGROUND_GREEN=$(tput setab 2)
COLOR_BACKGROUND_YELLOW=$(tput setab 3)
COLOR_BACKGROUND_BLUE_GREEN=$(tput setab 6) # 青色
COLOR_BACKGROUND_WHITE=$(tput setab 7)

########################################
# 檢查 docker-compose 是否存在
# docker-compose 1.29.0 之後的版本，docker-compose 已經被整合到 docker 中，並改為使用 docker compose
# 這邊使用 command -v docker-compose 來判斷是否存在 docker-compose
# https://stackoverflow.com/questions/66514436/difference-between-docker-compose-and-docker-compose
if command -v docker-compose != NULL; then
    dockerCompose="docker-compose"
else
    dockerCompose="docker compose"
fi

RemoveContainer() {
    lastResult=$?
    if [ $lastResult = 16888 ]; then
        echo "$COLOR_BACKGROUND_RED 狀態:$lastResult，中止... $COLOR_REST"
        ${dockerCompose} down
    fi
}
trap RemoveContainer EXIT

#####################################################################
# 先清空畫面
clear

#####################################################################
# 取得資料夾名稱，因資料夾名稱是容器名稱的 prefix
dir=$(pwd)
fullPath="${dir%/}"
containerNamePrefix=${fullPath##*/}
echo "$COLOR_BACKGROUND_BLUE_GREEN 現在位置 - ${containerNamePrefix} $COLOR_REST"

#####################################################################
# 先檢查網段是否存在，如果不存在，則建立網段
networkName=${containerNamePrefix}_network
if [ -z "$(docker network ls | grep $networkName)" ]; then
    docker network create $networkName && echo "$COLOR_BACKGROUND_GREEN 建立網段... 成功 $COLOR_REST"
fi

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
    # Start container
    $dockerCompose up -d --build && echo "$COLOR_BACKGROUND_GREEN 啟動容器...成功 $COLOR_REST"

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
    read -p "請輸入要執行的項目($(tput setaf 2 )1-4$(tput sgr0))[$(tput setaf 3 )2$(tput sgr0)]:" -r user_select
    user_select=${user_select:-2}   # 預設為 2
    user_select_uppercase=$(echo "$user_select" | tr '[:upper:]' '[:lower:]')   # 轉換為小寫

    ########################################
    # 專案初始化並啟動開發環境
    if [ $user_select = 1 ]; then
        # 初始化
        Init 

        # Run default setting
        DefaultSetting

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
        docker exec -it ${containerNamePrefix}_vue_1 yarn && echo "$COLOR_BACKGROUND_GREEN 更新前端所需套件... 成功 $COLOR_REST"
        
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