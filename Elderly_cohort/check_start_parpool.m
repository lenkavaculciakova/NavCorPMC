 function pp = check_start_parpool(n)
    %% Set up parcluster and parpool
    % By default Matlab uses ~/.matlab/local_cluster_jobs/VERSION to do accounting
    % for parallel pools. This leads to race conditions if pools are used on multi-
    % ple nodes at the same time. Therefore we create a node-local directory in /tmp
    % and tweak the parcluster to use this for pool management.
    % (https://scicomp.aalto.fi/_downloads/ad6845f1f03250dbecb72d0f528398df/parpool_parallel.m) 
    %
    % n: number of processes for pool
    % pp: parpool
    % Kornelius Podranski
    
    jobdir = [tempname() 'matlabjobs'];
    while exist(jobdir, 'file')
        jobdir = [tempname() 'matlabjobs'];
    end
    mkdir(jobdir); %TODO: Error handling
    pc = parcluster('local');
    pc.JobStorageLocation = jobdir;
    pc.NumWorkers = n;
    %pc.NumThreads = 1; %Depending on you code you might want to set it differently
    disp(pc)
    
    delete(gcp('nocreate')); %avoid errors if parpool still open
    pp = parpool(pc, n-1); %need to reserve one core for main process
    %pp.IdleTimeout = idleTimeout;
    disp(pp)
 end