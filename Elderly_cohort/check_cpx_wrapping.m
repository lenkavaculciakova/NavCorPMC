%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function checks if the unwrapping of the phases worked
%  It returns a vector containing channel numbers that were
%  not unwrapped correctly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [unwrap_fail, failed_win_pos, failed_win_pos_per_channel, movwin_size] = check_cpx_wrapping(dPhi, TR, tolerance)
    % ! TR in msec
    unwrap_fail = [];
    failed_win_pos = [];
    failed_win_pos_per_channel = [];
    movwin_size = round(30 / (TR.*1e-3)); % look at 30 sec intervals
    no_intervals = round(length(dPhi(1,:))/movwin_size);
    
    for channel=1:size(dPhi,1)
        size(dPhi,1);
        counter = 0;
        for window = 1:(no_intervals)
            scale = ((window-1)*movwin_size+1):(window*movwin_size);            
            if(abs(max(dPhi(channel,scale)) - min(dPhi(channel,scale))) > tolerance)
                counter = counter +1;
                unwrap_fail = [unwrap_fail, channel];
                failed_win_pos = [failed_win_pos, scale];
            end
            
            if (window == no_intervals)
                scale = scale + (length(dPhi(channel,:))-scale(end));
                if(abs(max(dPhi(channel,scale)) - min(dPhi(channel,scale))) > tolerance)
                    counter = counter +1;
                    unwrap_fail = [unwrap_fail, channel];
                    failed_win_pos = [failed_win_pos, scale];
               end
            end            
            if (window ~= 1 && window ~= no_intervals)
                scale = scale - round(movwin_size/2);
                if(abs(max(dPhi(channel,scale)) - min(dPhi(channel,scale))) > tolerance)
                    counter = counter +1;
                    unwrap_fail = [unwrap_fail, channel];
                    failed_win_pos = [failed_win_pos, scale];
                end
            end  
        end
        failed_win_pos_per_channel = [failed_win_pos_per_channel, counter];
    end
    unwrap_fail = unique(unwrap_fail);
    failed_win_pos_per_channel(failed_win_pos_per_channel == 0) = [];
end
