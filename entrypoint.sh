#!/usr/bin/env bash
set -euo pipefail

torrc_file="/torrc"
hs_per_process="${HS_PER_PROCESS:-10}"

function check_torrc_exists() {
    if [[ ! -f "${torrc_file}" ]]
    then
    echo "Missing torrc file."
    exit 1
    fi
}

function check_torrc_is_valid() {
    invalid_lines=$(grep -v '^#\|^HiddenService\(Dir\|Port\)\|^[[:space:]]*$' "${torrc_file}") || true
    if [[ "$invalid_lines" != "" ]]
    then
    echo "Invalid torrc file, only allowed parameters are:"
    echo "HiddenServiceDir"
    echo "HiddenServicePort"
    echo
    echo "Invalid lines:"
    echo "${invalid_lines}"
    exit 1
    fi
}

function clean_service_dir() {
    rm -rf "/etc/services.d/tor-*"
}

function create_tor_service() {
    index="${1}"
    
    service_path="/etc/services.d/tor-${index}"
    run_file="${service_path}/run"
    finish_file="${service_path}/finish"
    
    mkdir -p "${service_path}"
    echo '#!/usr/bin/execlineb -P' >> "${run_file}"
    echo "s6-setuidgid toruser" >> "${run_file}"
    echo "/usr/local/bin/tor -f /torrc-${index}" >> "${run_file}"

    echo '#!/usr/bin/execlineb -S0' >> "${finish_file}"
    echo "s6-svscanctl -t /var/run/s6/services" >> "${finish_file}"

    echo "DataDirectory /tmp/tor-${index}" >> "/torrc-${index}"
    echo "SOCKSPort 0" >> "/torrc-${index}"
}

function main() {
    check_torrc_exists
    check_torrc_is_valid
    clean_service_dir

    hs_index="-1"
    process_index="-1"
    grep -v '^#\|^[[:space:]]*$' "${torrc_file}" | while read -r line
    do
        if [[ "$line" = HiddenServiceDir* ]]
        then
            hs_index=$((hs_index + 1))
            if [[ "$((hs_index % hs_per_process))" = "0" ]]
            then
                process_index=$((process_index + 1))
                create_tor_service $process_index
            fi
        fi
        echo $line >> "/torrc-${process_index}"
    done

    exec /init
}

main