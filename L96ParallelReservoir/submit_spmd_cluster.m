clear;
c = parcluster;

ClusterInfo.setWallTime('8:00:00')
ClusterInfo.setMemUsage('5g')
ClusterInfo.setEmailAddress('jaideeppathak244@gmail.com')

ps = [20];

for iter = 1:length(ps)
    pool_size = ps(iter);
    j = c.batch(@parallel_reservoir_benchmarking_pv,1,{pool_size},'pool', pool_size);
end