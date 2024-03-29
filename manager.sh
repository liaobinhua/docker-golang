#!/bin/bash
#################################
# Author:BinhuaLiao
# Created Time:Fri Jul  5 12:02:14 2019
# File Name:manager.sh
# Description:
#################################

set -e

prj_dir=$(cd $(dirname $0); pwd -P)

image_version='latest'
image_name="binhua/go1.12.6:$image_version"

env='prod'
app_name='go-box'
container_name='go-box'

function link_node_modules() {
    if [ -d "$1/node_modules" ]; then
        run_cmd "rm $1/node_modules"
    fi
    run_cmd "ln -sf /opt/node_npm_data/node_modules $1"
}

function build_image() {
    docker build -t $image_name $prj_dir/docker
}

function run() {
    local src_dir_in_host="$prj_dir/src"
    #link_node_modules $src_dir_in_host
    local uid=`id -u`
    local args=$(base_docker_args $env $container_name)
    args="$args -v $src_dir_in_host:/opt/src"
    #args="$args -p 3000:3000"
    #args="$args -p 8545:8545"
    args="$args -w /opt/src"
    local cmd_args='tail -f /dev/null'
    local cmd="docker run -d $args $image_name $cmd_args"
    run_cmd "$cmd"
}

function stop() {
    stop_container $container_name
}

function restart() {
    stop
    run
}

function attach() {
    local cmd="docker exec $docker_run_fg_mode $container_name bash"
    run_cmd "$cmd"
}

function help() {
	cat <<-EOF
        Valid options are:
            build_image
            run
            stop
            restart
            attach
            
            help                      show this help message and exit
EOF
}

source "$prj_dir/apuppy/bash-files/base.sh"
action=${1:-help}
$action "$@"
