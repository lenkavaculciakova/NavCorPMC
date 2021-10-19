%% Function nulls the navigator trace
% used for channels that were detected for failed unwrapping
% the trace is replaced with zeroes, so that the navigator
% correction is not applied to the channel

function [dPhi] = virtual_coil_mean(dPhi, unwrap_fail)
    disp('virtual_coil_mean function');
    channel = 1:size(dPhi,1); % create a vector of channels
    for ch = 1:length(unwrap_fail)
        % remove incorrectly unwrapped channels from the vector
        channel = channel(channel ~= unwrap_fail(ch));
    end
    % calculate virtual coil ref from the remaining channels
    virt_coil_ref = mean(dPhi(channel,:),1);
    
    % rewrite the faulty channel(s) with virtual coil ref 
    for ch = 1:length(unwrap_fail)
        dPhi(unwrap_fail(ch),:) = virt_coil_ref;
    end
end


