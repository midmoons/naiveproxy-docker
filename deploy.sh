#!/bin/bash

mkdir caddy

generate_random_string_ll() {
    local length=$1
    local characters='abcdefghijklmnopqrstuvwxyz'
    local result=""

    for (( i=0; i < length; i++ )); do
        local random_index=$((RANDOM % ${#characters}))
        result+=${characters:$random_index:1}
    done

    echo "$result"
}

generate_random_string() {
    local length=$1
    local characters='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local result=""

    for (( i=0; i < length; i++ )); do
        local random_index=$((RANDOM % ${#characters}))
        result+=${characters:$random_index:1}
    done

    echo "$result"
}

generate_random_port() {
    local min_port=1024  # 最小端口号
    local max_port=65535 # 最大端口号

    # 生成随机整数
    local random_number=$((RANDOM % (max_port - min_port + 1) + min_port))

    echo "$random_number"
}

config_env() {
    read -p "输入域名(example.com): " zone
    if [ -z $zone ]; then
        echo "域名输入错误"
        exit 0
    fi

    sub_domain=$(generate_random_string_ll "12")
    read -p "请输入子域名（默认 $sub_domain ）: " isub_domain
    if [[ -n $isub_domain ]]; then
        sub_domain=$isub_domain
    fi

    read -p "请输入Cloudflare api token: " cf_apitoken
    if [ -z $cf_apitoken ]; then
        echo "Cloudflare api token输入错误"
        exit 0
    fi

    npuser=$(generate_random_string "6")
    read -p "请输入用户名（默认 $npuser ）: " inpuser
    if [[ -n $inpuser ]]; then
        npuser=$inpuser
    fi

    nppass=$(generate_random_string "12")
    read -p "请输入密码（默认 $nppass ）: " inppass
    if [[ -n $inppass ]]; then
        nppass=$inppass
    fi

    npport=$(generate_random_port)
    read -p "请输入端口（默认 $npport ）: " inpport
    if [[ -n $inpport ]]; then
        npport=$inpport
    fi

    npdisguise="https://go.dev/"
    read -p "请输入伪装网站（默认 $npdisguise ）: " inpdisguise
    if [[ -n $inpdisguise ]]; then
        npdisguise=$inpdisguise
    fi

    echo "ZONE=$zone" > .env
    echo "SUBDOMAIN=$sub_domain" >> .env
    echo "CF_API_TOKEN=$cf_apitoken" >> .env
    echo "USER=$npuser" >> .env
    echo "PASS=$nppass" >> .env
    echo "PORT=$npport" >> .env
    echo "DISGUISE=$npdisguise" >> .env
}

install_dep() {
    apt update
    apt upgrade -y
    apt autoremove -y
    apt clean

    apt install curl -y
}

install_docker() {
    curl -fsSL https://get.docker.com | sh
}

if [ ! -e ".env" ]; then
    config_env
fi

if ! command -v docker &> /dev/null; then
    install_docker
fi

install_dep

docker_compose_url="https://raw.githubusercontent.com/bankroft/naiveproxy-docker/main/docker-compose.yaml"
caddy_file_url="https://raw.githubusercontent.com/bankroft/naiveproxy-docker/main/caddy/Caddyfile"

curl -o "docker-compose.yaml" -L "$docker_compose_url"
curl -o "caddy/Caddyfile" -L "$caddy_file_url"

docker compose up