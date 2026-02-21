#!/bin/bash

# Determine role based on SLURM_PROCID
if [ "${SLURM_PROCID:-0}" -eq 0 ]; then
  ROLE="SENDER"
else
  ROLE="RECEIVER"
fi

# Log rank and role
echo "$ROLE: Rank $SLURM_PROCID on $(hostname)" >> ${RESULTS_DIR}/runtime.out

# Sampling interval (seconds)
: ${SAMPLE_INTERVAL:=1}
echo "SAMPLE_INTERVAL: $SAMPLE_INTERVAL"

# Telemetry path
TELEM_PATH="/sys/class/cxi/cxi0/device/telemetry"

# Output file
telem_outfile=cxi_monitor.${SLURM_JOB_ID}-$(hostname).txt

# Counter patterns to collect
COUNTER_PATTERNS=(
    "hni_pkts_sent_by_tc_*"
    "hni_pkts_recv_by_tc_*"
    "hni_rx_ok_*"
    "hni_tx_ok_*"
)

if [[ $SLURM_LOCALID -eq 0 ]]; then
    if [ -d "${TELEM_PATH}" ]; then
        (
            while true; do
                timestamp=$(date +%s.%N)
                echo "=== SAMPLE_START $timestamp ==="
                
                cd ${TELEM_PATH}
                
                # Read all matching counters
                for pattern in "${COUNTER_PATTERNS[@]}"; do
                    for file in $pattern; do
                        if [ -f "$file" ]; then
                            echo "$file $(cat $file 2>/dev/null)"
                        fi
                    done
                done
                
                echo "=== SAMPLE_END $timestamp ==="
                sleep $TELEMETRY_INTERVAL
            done
        ) > ${RESULTS_DIR}/$telem_outfile &
        
        telemetry_pid=$!
    else
        echo "Warning: Telemetry path not found on node"
    fi
fi

# Run the actual benchmark
$@

# Stop monitoring
if [[ $SLURM_LOCALID -eq 0 ]]; then
    if [ -n "$telemetry_pid" ]; then
        kill -9 $telemetry_pid
        wait $telemetry_pid 2>/dev/null
    fi
fi
