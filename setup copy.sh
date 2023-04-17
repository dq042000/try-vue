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
    echo "$COLOR_BACKGROUND_YELLOW ${lastResult}$COLOR_REST"
    if [ $lastResult -ne 0 ] && [ $lastResult -ne 130 ] && [ $lastResult -ne 16888 ]
    then
        echo "$COLOR_BACKGROUND_RED 啟動專案過程有錯誤，移除所有容器。$COLOR_REST"
        docker-compose down
    elif [ $lastResult -ne 16888 ]
    then
        echo "$COLOR_BACKGROUND_RED Aborting...$COLOR_REST"
        docker-compose down
    fi
}
trap RemoveContainer EXIT

# 取得資料夾名稱，因資料夾名稱是容器名稱的 prefix
dir=$(pwd)
fullPath="${dir%/}";
containerNamePrefix=${fullPath##*/}

echo "$COLOR_BACKGROUND_BLUE_GREEN 現在位置 - ${containerNamePrefix}$COLOR_REST \n"

# Copy config files
cp env-sample .env
cp docker-compose.yml.sample docker-compose.yml
cp .docker/nginx/default.conf.dist .docker/nginx/default.conf
cp web/vite/.env-sample web/vite/.env
echo "$COLOR_BACKGROUND_YELLOW 複製 Config 檔案...成功$COLOR_REST \n"

# 讀取「.env」
. ${dir}/.env

# 預設設定
DefaultSetting() {
    # Copy php config files
    cp web/${PHP_DIRECTORY}/config/autoload/local.php.dist web/${PHP_DIRECTORY}/config/autoload/local.php
    cp web/${PHP_DIRECTORY}/config/autoload/oauth.local.php.dist web/${PHP_DIRECTORY}/config/autoload/oauth.local.php
    cp web/${PHP_DIRECTORY}/config/autoload/doctrine.local.php.dist web/${PHP_DIRECTORY}/config/autoload/doctrine.local.php
    cp web/${PHP_DIRECTORY}/config/autoload/module.doctrine-mongo-odm.local.php.dist web/${PHP_DIRECTORY}/config/autoload/module.doctrine-mongo-odm.local.php
    echo "$COLOR_BACKGROUND_YELLOW 複製 專案 Config 檔案...成功$COLOR_REST \n"

    # Start container
    docker-compose up -d --build && echo "$COLOR_BACKGROUND_GREEN 啟動容器...成功$COLOR_REST"
}

# 開始執行
echo $COLOR_YELLOW"(1) 專案初始化"$COLOR_REST;
echo $COLOR_YELLOW"(2) 啟動開發環境"$COLOR_REST;
echo $COLOR_YELLOW"(3) 模擬啟動正式環境"$COLOR_REST;
echo $COLOR_YELLOW"(4) 匯入資料庫 $COLOR_GREEN(確保匯入前將資料庫清空及匯入檔案放置: ./web/api/data/sql) $COLOR_YELLOW"$COLOR_REST;
echo $COLOR_YELLOW"(5) 執行 Migrate"$COLOR_REST;
read -p "請輸入要執行的項目(1-5)[2]:" -r user_select
user_select=${user_select:-2}

########################################
# 第一次安裝
if [ $user_select = 1 ]; then
    # Run default setting
    DefaultSetting

    # Install php packages
    docker exec -it ${containerNamePrefix}_api_1 composer install && echo "$COLOR_BACKGROUND_GREEN 安裝 php 相關套件... 成功$COLOR_REST"

    # Install node modules
    docker exec -it ${containerNamePrefix}_vite_1 yarn && echo "$COLOR_BACKGROUND_GREEN 安裝前端所需套件... 成功$COLOR_REST\n"

    # Cache disabled
    docker exec -it ${containerNamePrefix}_api_1 composer development-enable && echo "$COLOR_BACKGROUND_GREEN 取消 Cache 功能... 成功$COLOR_REST"

    # Change permission
    sudo chmod 777 -R web/${PHP_DIRECTORY}/data

    # Start container
    docker-compose down && echo "$COLOR_BACKGROUND_GREEN 停止容器...成功$COLOR_REST"
    docker-compose up -d --build && echo "$COLOR_BACKGROUND_GREEN 啟動容器...成功$COLOR_REST"
    docker exec -it ${containerNamePrefix}_api_1 bin/cli.sh base:install && echo "$COLOR_BACKGROUND_GREEN 安裝 DB... 成功$COLOR_REST"
    docker exec -it ${containerNamePrefix}_api_1 bin/cli.sh base:edu-school-sync

    # Start develop
    docker exec -it ${containerNamePrefix}_vite_1 yarn dev

    echo "$COLOR_BACKGROUND_YELLOW 專案初始化... 成功$COLOR_REST \n"
    return 16888

########################################
# 啟動開發環境
elif [ $user_select = 2 ]; then
    # Run default setting
    DefaultSetting

    # Update php packages
    docker exec -it ${containerNamePrefix}_api_1 composer update && echo "$COLOR_BACKGROUND_GREEN 更新 php 相關套件... 成功$COLOR_REST"

    # Update node modules
    docker exec -it ${containerNamePrefix}_vite_1 yarn && echo "$COLOR_BACKGROUND_GREEN 更新前端所需套件... 成功$COLOR_REST\n"

    # Start develop
    docker exec -it ${containerNamePrefix}_vite_1 yarn dev

    echo "$COLOR_BACKGROUND_YELLOW 啟動開發環境\e[0m \n"
    return 16888

########################################
# 測試啟動正式環境
elif [ $user_select = 3 ]; then
    # Run default setting
    DefaultSetting

    # Update php packages
    docker exec -it ${containerNamePrefix}_api_1 composer update && echo "$COLOR_BACKGROUND_GREEN 更新 php 相關套件... 成功$COLOR_REST"

    # Update node modules
    docker exec -it ${containerNamePrefix}_vite_1 yarn && echo "$COLOR_BACKGROUND_GREEN 更新前端所需套件... 成功$COLOR_REST\n"

    # Start build
    docker exec -it ${containerNamePrefix}_vite_1 yarn build

    echo "$COLOR_BACKGROUND_YELLOW 測試啟動正式環境... 成功$COLOR_REST \n"
    return 16888

########################################
# 匯入資料庫
elif [ $user_select = 4 ]; then
    # 存放SQL位置
    dirSQL=web/${PHP_DIRECTORY}/data/sql
    for fileLevelOne in "$dirSQL"/*
    do
        for fileLevelTwo in "$fileLevelOne"
        do
            # 取得檔案名稱
            fileLevelTwoName=$(basename "${fileLevelTwo}")

            # 只允許副檔名為「.sql」
            if [ "${fileLevelTwoName##*.}" = "sql" ]; then
                env LANG=zh_TW.UTF-8 cat $FILE2 | docker exec -i ${containerNamePrefix}_mysqldb_1 mysql -u${MYSQL_ROOT_USER} -p${MYSQL_ROOT_PASSWORD} -h${MYSQL_HOST} ${MYSQL_DATABASE}
                echo "$COLOR_BACKGROUND_GREEN ${fileLevelTwo}... 成功$COLOR_REST\n"
            fi
        done
    done
    echo "$COLOR_BACKGROUND_YELLOW 資料匯入完成\e[0m \n"
    return 16666

########################################
# Migrate
elif [ $user_select = 5 ]; then
    # 開始執行
    echo $COLOR_YELLOW"(1) 執行 workbench export + migrate"$COLOR_REST;
    echo $COLOR_YELLOW"(2) 執行 workbench export"$COLOR_REST;
    echo $COLOR_YELLOW"(3) 產生 migrate 檔案"$COLOR_REST;
    echo $COLOR_YELLOW"(4) 執行 migrate"$COLOR_REST;
    echo $COLOR_YELLOW"(5) 還原 migrate"$COLOR_REST;
    read -p "請輸入要執行的項目(1-5):" migrate_select
    if [ $migrate_select = 1 ]; then
        read -p "$(echo $COLOR_GREEN"確定要執行嗎？ (yes/no) "$COLOR_REST"["$COLOR_YELLOW"yes"$COLOR_REST"]")" user_confirm
        user_confirm=${user_confirm:-yes}   # 預設為yes

        # yes 就執行
        if [ "$user_confirm" = 'yes' ] || [ "$user_confirm" = 'YES' ]; then
            rm -f ${dir}/web/data/temp/*
            docker exec -ti ${containerNamePrefix}_php_1 sh bin/export.sh ${MIGRATION_FILE}
            cp ${dir}/web/data/temp/*.php ${dir}/web/module/Base/src/Entity/
            docker exec -ti ${containerNamePrefix}_php_1 sh bin/doctrine.sh migrations:diff
            docker exec -ti ${containerNamePrefix}_php_1 sh bin/doctrine.sh migrations:migrate --no-interaction
            rm -f ${dir}/web/data/temp/*
        fi
    fi

    if [ $migrate_select = 2 ]; then
        read -p "$(echo $COLOR_GREEN"確定要執行嗎？ (yes/no) "$COLOR_REST"["$COLOR_YELLOW"yes"$COLOR_REST"]")" user_confirm
        user_confirm=${user_confirm:-yes}   # 預設為yes

        # yes 就執行
        if [ "$user_confirm" = 'yes' ] || [ "$user_confirm" = 'YES' ]; then
            rm -f ${dir}/web/data/temp/*
            docker exec -ti ${containerNamePrefix}_php_1 sh bin/export.sh ${MIGRATION_FILE}
        fi
    fi

    if [ $migrate_select = 3 ]; then
        read -p "$(echo $COLOR_GREEN"確定要執行嗎？ (yes/no) "$COLOR_REST"["$COLOR_YELLOW"yes"$COLOR_REST"]")" user_confirm
        user_confirm=${user_confirm:-yes}   # 預設為yes

        # yes 就執行
        if [ "$user_confirm" = 'yes' ] || [ "$user_confirm" = 'YES' ]; then
            cp ${dir}/web/data/temp/*.php ${dir}/web/module/Base/src/Entity/
            docker exec -ti ${containerNamePrefix}_php_1 sh bin/doctrine.sh migrations:diff
        fi
    fi

    if [ $migrate_select = 4 ]; then
        read -p "$(echo "請輸入要 "$COLOR_YELLOW"migrate"$COLOR_REST" 的版本號碼 ["$COLOR_YELLOW"ex.Version20221202033436"$COLOR_REST"]"):" version_number
        read -p "$(echo $COLOR_GREEN"確定要 migrate 嗎？ (yes/no) "$COLOR_REST"["$COLOR_YELLOW"yes"$COLOR_REST"]")" user_answer
        user_answer=${user_answer:-yes}   # 預設為yes

        # yes 就執行
        if [ "$user_answer" = 'yes' ] || [ "$user_answer" = 'YES' ]; then
            docker exec -ti ${containerNamePrefix}_php_1 bin/doctrine.sh migrations:migrate "${migrations_paths}${version_number}"
            # or 
            # docker exec -ti ${containerNamePrefix}_php_1 bin/doctrine.sh migrations:execute "Application\${version_number}" --up
        fi
    fi

    if [ $migrate_select = 5 ]; then
        read -p "$(echo "請輸入要 "$COLOR_RED"還原"$COLOR_REST" 的版本號碼 ["$COLOR_YELLOW"ex.Version20221202033436"$COLOR_REST"]"):" version_number
        if [ -z "$version_number" ]; then
            echo "${COLOR_RED}請輸入版本號碼${COLOR_REST}"
        else
            read -p "$(echo $COLOR_GREEN"確定要 "$COLOR_REST$COLOR_RED"還原"$COLOR_REST$COLOR_GREEN" 嗎？ (yes/no) "$COLOR_REST"["$COLOR_YELLOW"yes"$COLOR_REST"]")" user_answer
            user_answer=${user_answer:-yes}   # 預設為yes

            # yes 就執行
            if [ "$user_answer" = 'yes' ] || [ "$user_answer" = 'YES' ]; then
                docker exec -ti ${containerNamePrefix}_php_1 bin/doctrine.sh migrations:execute "${migrations_paths}${version_number}" --down
            fi
        fi
    fi

    echo "$COLOR_BACKGROUND_YELLOW Migrate... 成功$COLOR_REST \n"
    return 16888
else
    return 99
fi