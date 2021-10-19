function delete_parpool(pp)
    %% Set up parcluster and parpool
    % By default Matlab uses ~/.matlab/local_cluster_jobs/VERSION to do accounting
    % for parallel pools. This leads to race conditions if pools are used on multi-
    % ple nodes at the same time. Therefore we create a node-local directory in /tmp
    % and tweak the parcluster to use this for pool management.
    % (https://scicomp.aalto.fi/_downloads/ad6845f1f03250dbecb72d0f528398df/parpool_parallel.m) 
    %
    % pp: parpool
    % by Kornelius Podranski
    
    %% Clean up parcluster
    % TODO: Encapsulate into try-catch-(final) or onCleanup to guarantee execution
    % At CBS /tmp should be emptied every reboot. So it is not too dramatic if
    % cleaning fails.
    pc = pp.Cluster;
    jobdir = pc.JobStorageLocation;
    delete(gcp('nocreate'))
    clearvars('pp', 'pc');
    rmdir(jobdir, 's');
end