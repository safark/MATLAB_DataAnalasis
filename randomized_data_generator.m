function T = randomized_data_generator(outputCsvPath, showPreviewPlot)
% RANDOMIZED_DATA_GENERATOR Generate synthetic battery dataset.
%   T = RANDOMIZED_DATA_GENERATOR() generates synthetic data and writes
%   sample_battery_data.csv in the current folder.
%
%   T = RANDOMIZED_DATA_GENERATOR(outputCsvPath, showPreviewPlot) controls
%   output CSV path and optional quick preview plot.

if nargin < 1 || isempty(outputCsvPath)
    outputCsvPath = fullfile(pwd, 'sample_battery_data.csv');
end

if nargin < 2 || isempty(showPreviewPlot)
    showPreviewPlot = false;
end

%% Time setup
dt = 1;                          % seconds
time_duration = 2 * 3600;        % 2 hours in seconds
time_column_vector = (0:dt:time_duration).';
N = numel(time_column_vector);

%% Battery parameters
pack_capacity = 100;             % Ah
initial_soc_percentage = 60;     % %
minimum_pack_voltage = 300;      % V
maximum_pack_voltage = 420;      % V
internal_resistance = 0.08;      % ohm

%% Thermal parameters
normal_temperature = 23;         % deg C
initial_temp = 25;               % deg C
cooling_time = 450;              % seconds

%% Noise settings
noise_current = 1.0;
noise_voltage = 0.30;
noise_temperature = 0.10;

rng(7);

%% Current profile
I = zeros(N, 1);
segments = [
    0     1200   50
    1200  1500   0
    1500  2700  -40
    2700  3000   0
    3000  4200   60
    4200  4500   0
    4500  7200  -30
];

for k = 1:size(segments, 1)
    start_t = segments(k, 1);
    end_t = segments(k, 2);
    current_value = segments(k, 3);

    if k < size(segments, 1)
        idx = (time_column_vector >= start_t) & (time_column_vector < end_t);
    else
        idx = (time_column_vector >= start_t) & (time_column_vector <= end_t);
    end

    I(idx) = current_value;
end

I = I + noise_current * randn(N, 1);

%% SOC model (coulomb counting)
soc_percentage = zeros(N, 1);
soc_percentage(1) = initial_soc_percentage;

for i = 2:N
    dSOC = -(I(i - 1) / (pack_capacity * 3600)) * dt * 100;
    soc_percentage(i) = soc_percentage(i - 1) + dSOC;
    soc_percentage(i) = max(0, min(100, soc_percentage(i)));
end

%% Voltage model
soc_fraction = soc_percentage / 100;
OCV = minimum_pack_voltage + ...
      (maximum_pack_voltage - minimum_pack_voltage) .* soc_fraction;

PackVoltage = OCV - I * internal_resistance;
PackVoltage = PackVoltage + noise_voltage * randn(N, 1);

%% Temperature model
Temperature = zeros(N, 1);
Temperature(1) = initial_temp;
k_heat = 0.002;

for i = 2:N
    heat = k_heat * (I(i - 1)^2) * internal_resistance;
    cooling = (Temperature(i - 1) - normal_temperature) / cooling_time;
    dT = (heat - cooling) * dt;
    Temperature(i) = Temperature(i - 1) + dT;
end

Temperature = Temperature + noise_temperature * randn(N, 1);

%% Output table
time_column_vector = time_column_vector(:);
PackVoltage = PackVoltage(:);
I = I(:);
soc_percentage = soc_percentage(:);
Temperature = Temperature(:);

rowCounts = [ ...
    numel(time_column_vector), ...
    numel(PackVoltage), ...
    numel(I), ...
    numel(soc_percentage), ...
    numel(Temperature)];
if any(rowCounts ~= rowCounts(1))
    error(['Generator size mismatch [Time, Voltage, Current, SOC, Temp] = [%d, %d, %d, %d, %d].'], ...
        rowCounts(1), rowCounts(2), rowCounts(3), rowCounts(4), rowCounts(5));
end

T = table( ...
    time_column_vector, PackVoltage, I, soc_percentage, Temperature, ...
    'VariableNames', ...
    {'Time_s', 'PackVoltage_V', 'Current_A', 'SOC_pct', 'Temperature_C'});

if ~isempty(outputCsvPath)
    writetable(T, outputCsvPath);
end

if showPreviewPlot
    figure('Name', 'Synthetic Battery Data Preview');
    subplot(3, 1, 1);
    plot(time_column_vector / 60, I);
    ylabel('Current (A)');
    title('Current Profile');

    subplot(3, 1, 2);
    plot(time_column_vector / 60, soc_percentage);
    ylabel('SOC (%)');

    subplot(3, 1, 3);
    plot(time_column_vector / 60, PackVoltage);
    ylabel('Voltage (V)');
    xlabel('Time (min)');
end

if ~isempty(outputCsvPath)
    fprintf('Sample battery data generated: %s\n', outputCsvPath);
else
    fprintf('Sample battery data generated.\n');
end
end
