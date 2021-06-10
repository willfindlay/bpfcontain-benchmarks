#!/bin/bash

##
# run_pts_tests() - Run phoronix test suite tests
# $1: Name of results file
# $2: Unique identifier for test run
# $3: Description for test run
#
run_pts_tests() {
    local tests="osbench"
    local results="$1"
    local json="$results.json"
    local id="$2"
    local description="$3"
    local data_dir="data/pts"
    local wrapper="${4:''}"

    # No prompts at beginning
    export PTS_SILENT_MODE=1
    # Run at least 11 times
    export FORCE_MIN_TIMES_TO_RUN=11
    # Always discard first run
    export IGNORE_RUNS=1
    # Set result file name, id, and description
    export TEST_RESULTS_NAME="$name"
    export TEST_RESULTS_IDENTIFIER="$id"
    export TEST_RESULTS_DESCRIPTION="$description"

    # Run benchmarks
    $wrapper pts batch-benchmark $tests
    mkdir -p "$data_dir"
    pts result-file-to-json "$result" > "$data_dir/$json"
}

benchmark_bpfcontain() {
    bpfcontain daemon start
    run_pts_tests "benches" "bpfcontain-passive" "BPFContain running without doing anything" ""
    run_pts_tests "benches" "bpfcontain-allow" "BPFContain running in allow mode" "bpfcontain run bpfcontain_profiles/complaining.yml"
    run_pts_tests "benches" "bpfcontain-complaining" "BPFContain running in complaining mode" "bpfcontain run bpfcontain_profiles/complaining.yml"
    bpfcontain daemon stop
}

benchmark_apparmor() {
    run_pts_tests "benches" "apparmor-passive" "AppArmor running without doing anything" ""
    run_pts_tests "benches" "apparmor-allow" "AppArmor running in allow mode" "" # TODO: run an apparmor profile
    run_pts_tests "benches" "apparmor-complaining" "AppArmor running in complaining mode" "" # TODO: run an apparmor profile
}
