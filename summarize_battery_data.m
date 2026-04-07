function summary = summarize_battery_data(dataTable, timeRange_s)
% SUMMARIZE_BATTERY_DATA Compute range-filtered battery metrics.
%   summary = summarize_battery_data(dataTable, timeRange_s) returns a
%   struct with the displayed data subset, applied range, and key metrics.

if nargin < 2
    timeRange_s = [];
end

if ~istable(dataTable) || isempty(dataTable)
    error("dataTable must be a non-empty MATLAB table.");
end

requiredNames = ["Time_s", "PackVoltage_V", "Current_A", "SOC_pct", "Temperature_C"];
missingNames = requiredNames(~ismember(requiredNames, string(dataTable.Properties.VariableNames)));
if ~isempty(missingNames)
    error("dataTable is missing required columns: %s", strjoin(missingNames, ", "));
end

time_s = double(dataTable.Time_s(:));
if isempty(time_s) || any(~isfinite(time_s))
    error("Time_s must contain finite numeric values.");
end

appliedRange_s = resolve_time_range(time_s, timeRange_s);
mask = (time_s >= appliedRange_s(1)) & (time_s <= appliedRange_s(2));
if ~any(mask)
    mask = true(size(time_s));
    appliedRange_s = [min(time_s), max(time_s)];
end

displayedData = dataTable(mask, :);

summary = struct();
summary.AppliedRange_s = appliedRange_s;
summary.DisplayedData = displayedData;
summary.SampleCount = height(displayedData);
summary.Duration_s = appliedRange_s(2) - appliedRange_s(1);

summary.MinVoltage_V = min(displayedData.PackVoltage_V);
summary.MaxVoltage_V = max(displayedData.PackVoltage_V);
summary.AverageVoltage_V = mean(displayedData.PackVoltage_V);

summary.MinCurrent_A = min(displayedData.Current_A);
summary.MaxCurrent_A = max(displayedData.Current_A);
summary.AverageCurrent_A = mean(displayedData.Current_A);

summary.MinTemperature_C = min(displayedData.Temperature_C);
summary.MaxTemperature_C = max(displayedData.Temperature_C);
summary.AverageTemperature_C = mean(displayedData.Temperature_C);

summary.SOCStart_pct = displayedData.SOC_pct(1);
summary.SOCEnd_pct = displayedData.SOC_pct(end);
summary.SOCDelta_pct = summary.SOCEnd_pct - summary.SOCStart_pct;
end

function appliedRange_s = resolve_time_range(time_s, timeRange_s)
tMin = min(time_s);
tMax = max(time_s);

if nargin < 2 || isempty(timeRange_s)
    appliedRange_s = [tMin, tMax];
    return;
end

if numel(timeRange_s) ~= 2 || any(~isfinite(timeRange_s))
    error("timeRange_s must be [startTime, endTime].");
end

appliedRange_s = sort(double(timeRange_s(:)).');
appliedRange_s(1) = max(appliedRange_s(1), tMin);
appliedRange_s(2) = min(appliedRange_s(2), tMax);

if appliedRange_s(1) > appliedRange_s(2)
    appliedRange_s = [tMin, tMax];
end
end
