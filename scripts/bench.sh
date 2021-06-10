#!/bin/bash

##
# run_pts_tests() - Run phoronix test suite tests
# $1: Name of results file
# $2: Unique identifier for test run
# $3: Description for test run
#
run_pts_tests() {
    local tests="osbench apache build-linux-kernel"
    local results="$1"
    local json="$results.json"
    local id="$2"
    local description="$3"
    local data_dir="data/pts"
    local wrapper="$4"

    # No prompts at beginning
    export PTS_SILENT_MODE=1
    # Run at least 10 times
    export FORCE_MIN_TIMES_TO_RUN=10
    # Always discard first run
    export IGNORE_RUNS=1
    # Set result file name, id, and description
    export TEST_RESULTS_NAME="$name"
    export TEST_RESULTS_IDENTIFIER="$id"
    export TEST_RESULTS_DESCRIPTION="$description"

    # Run benchmarks
    $wrapper pts batch-benchmark $tests
    mkdir -p "$data_dir"
    pts result-file-to-json "$results" > "$data_dir/$json"
}

benchmark_base() {
    run_pts_tests "$1" "base" "Base performance without any security mechanisms" ""
}

benchmark_bpfcontain() {
    # Start the daemon
    sudo bpfcontain daemon start
    run_pts_tests "$1" "bpfcontain-passive" "BPFContain running without doing anything" ""
    run_pts_tests "$1" "bpfcontain-allow" "BPFContain running in allow mode" "bpfcontain run bpfcontain_profiles/complain.yml --"
    run_pts_tests "$1" "bpfcontain-complaining" "BPFContain running in complaining mode" "bpfcontain run bpfcontain_profiles/complain.yml --"
    # Stop the daemon
    sudo bpfcontain daemon stop
}

benchmark_apparmor() {
    # Disable rate limiting
    sudo sysctl -w kernel.printk_ratelimit=0
    # Load profiles
    sudo apparmor_parser -r apparmor_profiles/allow
    sudo apparmor_parser -r -C apparmor_profiles/complain
    run_pts_tests "$1" "apparmor-passive" "AppArmor running without doing anything" ""
    run_pts_tests "$1" "apparmor-allow" "AppArmor running in allow mode" "aa-exec -p ALLOW"
    run_pts_tests "$1" "apparmor-complaining" "AppArmor running in complaining mode" "aa-exec -p COMPLAIN"
    sudo aa-teardown
}

usage() {
    echo "USAGE: $1 [bpfcontain, apparmor]"
    exit -1
}

case $1 in
    base)
        benchmark_base results
        ;;
    bpfcontain)
        benchmark_bpfcontain results
        ;;
    apparmor)
        benchmark_apparmor results
        ;;
    *)
        usage
        ;;
esac
