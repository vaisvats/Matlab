% Define parameters
num_channels = 19;
num_bands = 5;
subject_range = 37:65; % Updated range of subjects

% Initialize a cell array to hold the sum of data for each band
sum_data = cell(num_bands, 1);
for b = 1:num_bands
    sum_data{b} = zeros(num_channels, num_channels);
end

% Initialize a cell array to hold the count of valid entries for each band
count_data = cell(num_bands, 1);
for b = 1:num_bands
    count_data{b} = zeros(num_channels, num_channels);
end

% Load data from each subject file
for subj = subject_range
    filename = sprintf('PhaseLagIndex3/Sub_%03d.mat', subj);
    
    % Check if the file exists
    if exist(filename, 'file')
        loaded_data = load(filename);
        
        % Assuming the data variable inside the .mat file is named 'data'
        data = loaded_data.pli_matices;
        
        % % Check if the data is in cell format with the correct dimensions
        % if ~iscell(data) || length(data) ~= num_bands
        %     error('Data format is not as expected for subject %d', subj);
        %end
        
        for b = 1:num_bands
            current_data = data{b};
            
            % % Check if the current_data has the correct dimensions
            % if size(current_data, 1) ~= num_channels || size(current_data, 2) ~= num_channels
            %     error('Data dimensions do not match expected dimensions for band %d of subject %d', b, subj);
            % end
            
            % Sum the data
            sum_data{b} = sum_data{b} + current_data;
            
            % Count the entries
            count_data{b} = count_data{b} + 1;
        end
    else
        warning('File %s does not exist. Skipping this subject.', filename);
    end
end

% Initialize a cell array to hold the averaged data for each band
avg_data = cell(num_bands, 1);

% Compute the average for each band
for b = 1:num_bands
    avg_data{b} = sum_data{b} ./ count_data{b};
end
reshapedCellArray = reshape(avg_data, 1, []);
% Save the averaged data into a new .mat file
save('averaged_data.mat', 'reshapedCellArray');
