function plottedRange_s = battery_visualization(ax, dataTable, plotType, timeRange_s)
% BATTERY_VISUALIZATION Plot battery data series using one entry point.
%   plottedRange_s = battery_visualization(ax, dataTable, plotType, timeRange_s)
%   supports:
%     - "SOC vs Time"
%     - "Voltage vs Time"
%     - "Current vs Time"
%     - "Temperature vs Time"

if nargin < 4
    timeRange_s = [];
end

switch string(plotType)
    case "SOC vs Time"
        plottedRange_s = plot_series( ...
            ax, dataTable, "SOC_pct", timeRange_s, ...
            "SOC (%)", "SOC vs Time", [0.00, 0.45, 0.74]);
    case "Voltage vs Time"
        plottedRange_s = plot_series( ...
            ax, dataTable, "PackVoltage_V", timeRange_s, ...
            "Voltage (V)", "Voltage vs Time", [0.85, 0.33, 0.10]);
    case "Current vs Time"
        plottedRange_s = plot_series( ...
            ax, dataTable, "Current_A", timeRange_s, ...
            "Current (A)", "Current vs Time", [0.47, 0.67, 0.19]);
    case "Temperature vs Time"
        plottedRange_s = plot_series( ...
            ax, dataTable, "Temperature_C", timeRange_s, ...
            "Temperature (C)", "Temperature vs Time", [0.49, 0.18, 0.56]);
    otherwise
        error("Unsupported plot type: %s", string(plotType));
end
end

function plottedRange_s = plot_series(ax, dataTable, yVarName, ...
    timeRange_s, yAxisLabel, plotTitle, lineColor)
if nargin < 4 || isempty(timeRange_s)
    timeRange_s = [];
end

if ~istable(dataTable)
    error("dataTable must be a MATLAB table.");
end

if ~ismember("Time_s", string(dataTable.Properties.VariableNames))
    error("dataTable must include a 'Time_s' column.");
end

if ~ismember(yVarName, string(dataTable.Properties.VariableNames))
    error("dataTable must include a '%s' column.", yVarName);
end

time_s = dataTable.Time_s;
y = dataTable.(char(yVarName));

if ~isnumeric(time_s) || ~isnumeric(y)
    error("'Time_s' and '%s' columns must be numeric.", yVarName);
end

[mask, plottedRange_s] = build_time_mask(time_s, timeRange_s);

plot(ax, time_s(mask), y(mask), "LineWidth", 1.6, "Color", lineColor);
grid(ax, "on");
box(ax, "on");
xlabel(ax, "Time (s)");
ylabel(ax, yAxisLabel);
title(ax, plotTitle);
xlim(ax, plottedRange_s);
end

function [mask, appliedRange_s] = build_time_mask(time_s, timeRange_s)
time_s = double(time_s(:));

if isempty(time_s)
    error("Time column is empty.");
end

tMin = min(time_s);
tMax = max(time_s);

if nargin < 2 || isempty(timeRange_s)
    appliedRange_s = [tMin, tMax];
else
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

mask = (time_s >= appliedRange_s(1)) & (time_s <= appliedRange_s(2));

if ~any(mask)
    mask = true(size(time_s));
    appliedRange_s = [tMin, tMax];
end
end
