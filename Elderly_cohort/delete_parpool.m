%  Copyright (c) 2020 Kornelius Podranski
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is intended to be used with MATLAB (The Mathworks, Inc.),
%  which is not part of this program. Therefore this program may be linked
%  to MATLAB libraries and may be redistributed in original or modified form
%  without providing any part of the MATLAB environment, as long as the
%  other terms of the GNU General Public License are adhered to regarding
%  this program.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
