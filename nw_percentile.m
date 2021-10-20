function perc_val = nw_percentile(cdat,dim,perc)
% function perc_val = nw_percentile(cdat,dim,perc)
% calculates percentile for a vector of complex-valued numbers
% based on the magnitude of the scalars
% input: cdat = matrix of data; dim = dimension of aggregating;
% perc = percentile
% output: value for percentile
% Nik Weiskopf, MPI-CBS, 31/7/20


if length(size(cdat)) > 2
    error('only up to 2 dimensions');
end

if dim == 1
    cdat=cdat;
elseif dim == 2
    cdat = cdat';
end

for nr=1:size(cdat,2)
    vec=cdat(:,nr);
    [y,index] = sort(abs(vec),1,'ascend');
    
    n=round(perc/100*length(y));
    if n==0
        perc_val(nr)=vec(index(1));
    else
        perc_val(nr) = vec(index(n));
    end
end