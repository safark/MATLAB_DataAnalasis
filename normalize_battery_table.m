function normalizedTable = normalize_battery_table(rawTable)
% NORMALIZE_BATTERY_TABLE Map source columns to standard battery schema.
% Required output variables:
%   Time_s, PackVoltage_V, Current_A, SOC_pct, Temperature_C

if ~istable(rawTable)
    error("Input must be a MATLAB table.");
end

sourceNames = string(rawTable.Properties.VariableNames);

timeName = find_first_match(sourceNames, ["Time_s", "Time", "time_s", "time"]);
voltageName = find_first_match(sourceNames, ...
    ["PackVoltage_V", "Voltage_V", "Voltage", "PackVoltage"]);
currentName = find_first_match(sourceNames, ...
    ["Current_A", "Current", "PackCurrent_A", "PackCurrent"]);
socName = find_first_match(sourceNames, ...
    ["SOC_pct", "SOC", "SOC_percent", "StateOfCharge"]);
temperatureName = find_first_match(sourceNames, ...
    ["Temperature_C", "Temperature", "Temp_C", "Temp"]);

missingColumns = strings(0, 1);
if strlength(timeName) == 0
    missingColumns(end + 1) = "time";
end
if strlength(voltageName) == 0
    missingColumns(end + 1) = "voltage";
end
if strlength(currentName) == 0
    missingColumns(end + 1) = "current";
end
if strlength(socName) == 0
    missingColumns(end + 1) = "SOC";
end
if strlength(temperatureName) == 0
    missingColumns(end + 1) = "temperature";
end

if ~isempty(missingColumns)
    error("Missing required columns: %s", strjoin(missingColumns, ", "));
end

normalizedTable = table();
normalizedTable.Time_s = to_numeric_column(rawTable.(char(timeName)), "Time_s");
normalizedTable.PackVoltage_V = to_numeric_column(rawTable.(char(voltageName)), "PackVoltage_V");
normalizedTable.Current_A = to_numeric_column(rawTable.(char(currentName)), "Current_A");
normalizedTable.SOC_pct = to_numeric_column(rawTable.(char(socName)), "SOC_pct");
normalizedTable.Temperature_C = to_numeric_column(rawTable.(char(temperatureName)), "Temperature_C");

normalizedTable = rmmissing(normalizedTable);

if isempty(normalizedTable)
    error("No valid numeric rows remain after cleaning the data.");
end

normalizedTable = sortrows(normalizedTable, "Time_s");
end

function matchedName = find_first_match(sourceNames, candidateNames)
matchedName = "";
sourceLower = lower(sourceNames);
candidateLower = lower(candidateNames);

for i = 1:numel(candidateLower)
    idx = find(sourceLower == candidateLower(i), 1, "first");
    if ~isempty(idx)
        matchedName = sourceNames(idx);
        return;
    end
end
end

function numericColumn = to_numeric_column(rawColumn, columnLabel)
if isnumeric(rawColumn)
    numericColumn = double(rawColumn);
elseif iscategorical(rawColumn)
    numericColumn = str2double(string(rawColumn));
elseif isstring(rawColumn) || ischar(rawColumn) || iscellstr(rawColumn)
    numericColumn = str2double(string(rawColumn));
else
    error("Column '%s' must be numeric or text-convertible to numeric.", columnLabel);
end

numericColumn = numericColumn(:);

if all(isnan(numericColumn))
    error("Column '%s' could not be converted to numeric values.", columnLabel);
end
end
