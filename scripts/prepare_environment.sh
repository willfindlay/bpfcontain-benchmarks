#!/usr/bin/env bash

# Based on some helpful tips for benchmarking consistency:
# https://easyperf.net/blog/2019/08/02/Perf-measurement-environment-on-Linux#1-disable-turboboost

usage() {
    echo "$0 [FLAGS...]"
    echo ""
    echo "FLAGS:"
    echo "    -c configure the environment for benchmarking"
    echo "    -u undo configuration changes"
    echo "    -h show this help message"
}

main() {
    while getopts ":huc" arg; do
      case $arg in
        h) usage
           exit
           ;;
        u) undo_changes
           exit
           ;;
        c) configure_environment
           exit
           ;;
        :)
          echo "$0: Must supply an argument to -$OPTARG." >&2
          exit 1
          ;;
        ?)
          echo "Invalid option: -${OPTARG}."
          exit 2
          ;;
      esac
    done

    usage
    exit 1
}

configure_environment() {
    # Disable turbo boost
    echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo

    # Set scaling governor to performance
    for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    do
      echo performance > $i
    done

    # Disable ASLR
    echo 0 > /proc/sys/kernel/randomize_va_space

    # Disable SMT hyperthreading
    for f in /sys/devices/system/cpu/cpu*/topology/thread_siblings_list
    do
        smt=$(cat "$f" | awk -F '[-,]' '{ print $2 }')
        echo 0 > "/sys/devices/system/cpu/cpu$smt/online"
    done
}

undo_changes() {
    # Enable turbo boost
    echo 0 > /sys/devices/system/cpu/intel_pstate/no_turbo

    # Set scaling governor to powersave
    for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    do
      echo powersave > $i
    done

    # Enable ASLR
    echo 2 > /proc/sys/kernel/randomize_va_space

    # Enable SMT hyperthreading
    for f in /sys/devices/system/cpu/cpu*/topology/thread_siblings_list
    do
        smt=$(cat "$f" | awk -F '[-,]' '{ print $2 }')
        echo 1 > "/sys/devices/system/cpu/cpu$smt/online"
    done
}

main $@
