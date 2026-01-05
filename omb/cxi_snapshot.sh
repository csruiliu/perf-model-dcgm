#!/bin/bash
#SBATCH -J OMB_p2p_host
#SBATCH -o OMB_p2p_host-%j.out 
#SBATCH -N 2
#SBATCH -C cpu
#SBATCH -q sow
#SBATCH -t 00:30:00
#SBATCH -A nstaff
#SBATCH --exclusive
##SBATCH -w nid[004074,004138]
#
#The -w option specifies which nodes to use for the test,
#thus controling the number of network hops between them.
#It should be modified for each system because
#the nid-topology differs with the system architechture.
#The nodes identified above are maximally distant
#on Perlmutter's Slingshot network.

#The number of NICs(j) and CPU cores (k) per node
#should be specified here.
j=1   #NICs per node
k=128 #Cores per node

#The paths to OMB and its point-to-point benchmarks
#should be specified here
OMB_DIR=../libexec/osu-micro-benchmarks
OMB_PT2PT=${OMB_DIR}/mpi/pt2pt
OMB_1SIDE=${OMB_DIR}/mpi/one-sided

export RESULTS_DIR=/pscratch/sd/r/ruiliu/osu-micro-benchmarks/results/OMB_${SLURM_JOB_ID}
mkdir -p $RESULTS_DIR

# Time windows for before/after collection (in seconds)
BEFORE_DURATION=10
AFTER_DURATION=10
MESSAGE_SIZE=5243000
#MESSAGE_SIZE=1048576

# Collect baseline counters BEFORE benchmarks
echo "Collecting baseline telemetry for ${BEFORE_DURATION} seconds..."
srun -N 2 --ntasks-per-node=1 ./cxi_snapshot.sh before ${BEFORE_DURATION}

start=$(date +%s.%N)

# srun -N 2 -n 2 ${OMB_PT2PT}/osu_latency -m 8:8

srun -N 2 -n 2 ./cxi_monitor.sh ${OMB_PT2PT}/osu_bibw -m $MESSAGE_SIZE:$MESSAGE_SIZE -i 1000

#srun -N 2 --ntasks-per-node=${j} ${OMB_PT2PT}/osu_mbw_mr -m 16384:16384

#srun -N 2 --ntasks-per-node=${k} ${OMB_PT2PT}/osu_mbw_mr -m 16384:16384

#srun -N 2 -n 2 ${OMB_1SIDE}/osu_get_acc_latency -m 8:8 

end=$(date +%s.%N)

# Collect final counters AFTER benchmarks
echo "Collecting final telemetry for ${AFTER_DURATION} seconds..."
srun -N 2 --ntasks-per-node=1 ./cxi_snapshot.sh after ${AFTER_DURATION}

elapsed=$(printf "%s - %s\n" $end $start | bc -l)

printf "Elapsed Time: %.2f seconds\n" $elapsed > runtime.out
