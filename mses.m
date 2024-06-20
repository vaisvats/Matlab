% Load the .mat file
data = pop_loadset('filename', 'sub-039_task-eyesclosed_eeg.set', 'filepath', 'derivatives\sub-039\eeg\');
eeg_data = data.data; % EEG data
fs = data.srate; % Sampling frequency
times = 1:data.pnts; % Time points

% Define frequency bands
bands = {'delta', 'theta', 'alpha', 'beta', 'gamma'};
band_ranges = [1 4; 4 8; 8 13; 13 30; 30 45];

% Time-frequency analysis using wavelet transform
num_channels = size(eeg_data, 1);
num_times = length(times);
pli_matrix = zeros(num_channels, num_channels, num_times);

for b = 1:length(bands)
    band = bands{b};
    freq_range = band_ranges(b, :);
    
    % Precompute wavelet transform for each channel
    wt = cell(num_channels, 1);
    for ch = 1:num_channels
        [wt{ch}, f] = cwt(eeg_data(ch, :), fs, 'FrequencyLimits', freq_range);
    end
    
    for ch1 = 1:num_channels
        for ch2 = ch1+1:num_channels
            wt1 = wt{ch1};
            wt2 = wt{ch2};
            
            % Compute phase differences
            phase_diff = angle(wt1) - angle(wt2);
            
            % Compute PLI
            pli = abs(mean(sign(phase_diff), "all"));
            
            % Interpolate to match the length of times
            %pli = interp1(linspace(freq_range(1), freq_range(2), length(pli)), pli, linspace(1, num_times, num_times));
            
            % Store PLI
            pli_matrix(ch1, ch2, :) = pli;
            pli_matrix(ch2, ch1, :) = pli;
        end
    end
    %matrix=load("PhaseLagIndex\\Sub_001.mat");
    % Plot PLI in time-frequency
    figure;
    imagesc(1, linspace(freq_range(1), freq_range(2), 1), squeeze(mean(matrix, [1, 2])));
    set(gca, 'YDir', 'normal');
    colorbar;
    title(['PLI in Time-Frequency for ' band ' Band']);
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
end
