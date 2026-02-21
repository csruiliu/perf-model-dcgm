#!/bin/bash

# Script to collect telemetry counters for a time window
# Usage: ./cxi_snapshot.sh <prefix> <duration>
# Example: ./cxi_snapshot.sh before 5

PREFIX=$1
DURATION=${2:-5}  # Default 5 seconds if not specified

if [ -z "$PREFIX" ]; then
    echo "Usage: $0 <prefix> [duration_seconds]"
    exit 1
fi

TELEM_PATH="/sys/class/cxi/cxi0/device/telemetry"
: ${SAMPLE_INTERVAL:=1}
echo "SAMPLE_INTERVAL: $SAMPLE_INTERVAL"

# Output file
snapshot_file=cxi_snapshot.${PREFIX}.${SLURM_JOB_ID}-$(hostname).txt

# Counter patterns to collect
COUNTER_PATTERNS=(
    "hni_pkts_sent_by_tc_*"
    "hni_pkts_recv_by_tc_*"
    "hni_rx_ok_*"
    "hni_tx_ok_*"
)

if [ -d "${TELEM_PATH}" ]; then
    start_time=$(date +%s.%N)
    end_time=$(echo "$start_time + $DURATION" | bc)
    
    echo "Collecting '${PREFIX}' telemetry on node ${SLURM_NODEID} for ${DURATION} seconds..."
    
    (
        while true; do
            current_time=$(date +%s.%N)
            
            # Check if we've exceeded the duration
            if (( $(echo "$current_time >= $end_time" | bc -l) )); then
                break
            fi
            
            echo "=== SAMPLE_START $current_time ==="
            
            cd ${TELEM_PATH}
            
            # Read all matching counters
            for pattern in "${COUNTER_PATTERNS[@]}"; do
                for file in $pattern; do
                    if [ -f "$file" ]; then
                        echo "$file $(cat $file 2>/dev/null)"
                    fi
                done
            done
            
            echo "=== SAMPLE_END $current_time ==="
            sleep $SAMPLE_INTERVAL
        done
    ) > ${RESULTS_DIR}/$snapshot_file
    
    echo "Snapshot '${PREFIX}' collection complete on node ${SLURM_NODEID}"
else
    echo "Warning: Telemetry path not found on node ${SLURM_NODEID}"
fi
