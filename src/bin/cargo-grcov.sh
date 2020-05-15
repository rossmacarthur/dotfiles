#!/usr/bin/env bash

usage() {
    cat 1>&2 <<EOF
Builds the project, run's tests, and run's grcov.

USAGE:
    cargo grcov [FLAGS]

FLAGS:
    -o, --open   Open the coverage HTML in the default browser.
    -c, --clean  Whether to run cargo clean before running grcov.
    -h, --help   Show this message and exit.
EOF
}

run() {
    local open=$1
    local clean=$2

    export CARGO_INCREMENTAL=0
    export CARGO_TARGET_DIR=target/grcov
    export RUSTFLAGS="-Zprofile -Ccodegen-units=1 -Copt-level=0 -Clink-dead-code -Coverflow-checks=off -Zpanic_abort_tests -Cpanic=abort"
    export RUSTDOCFLAGS="-Cpanic=abort"

    if [ "$clean" = true ]; then
        cargo +nightly clean
    fi
    cargo +nightly build || return 1
    cargo +nightly test || return 1

    grcov \
        --branch \
        --ignore-not-existing \
        --llvm \
        --source-dir src \
        --output-type html \
        --output-file $CARGO_TARGET_DIR/cov \
        --excl-start 'mod tests \{' \
        --excl-line '#\[derive\(' \
        --excl-br-line '#\[derive\(' \
        $CARGO_TARGET_DIR/debug \
        || return 1


    if [ "$open" = true ]; then
        open $CARGO_TARGET_DIR/cov/index.html
    fi
}


main() {
    local open=false
    local clean=false

    while test $# -gt 0; do
        case $1 in
            --help | -h)
                usage
                exit 0
                ;;
            --clean | -c)
                clean=true
                ;;
            --open | -o)
                open=true
                ;;
            *)
                ;;
        esac
        shift
    done

    run "$open" "$clean" || return 1
}

main "$@" || exit 1
