function reportPath = export_battery_report(dataTable, timeRange_s, outputFile)
% EXPORT_BATTERY_REPORT Generate a published HTML report for battery data.
%   reportPath = export_battery_report(dataTable, timeRange_s, outputFile)
%   creates a MATLAB published report with section headers, summary
%   statistics, and labeled plots for the selected time range.

if nargin < 2
    timeRange_s = [];
end

if nargin < 3 || strlength(string(outputFile)) == 0
    outputFile = fullfile(pwd, "battery_report.html");
end

outputFile = char(string(outputFile));
summary = summarize_battery_data(dataTable, timeRange_s);
timeRange_s = summary.AppliedRange_s;

[outputDir, reportBaseName, ~] = fileparts(outputFile);
if strlength(string(outputDir)) == 0
    outputDir = pwd;
end
if strlength(string(reportBaseName)) == 0
    reportBaseName = 'battery_report';
end

outputDir = char(string(outputDir));
reportBaseName = char(string(reportBaseName));
reportPath = fullfile(outputDir, [reportBaseName, '.html']);

if ~isfolder(outputDir)
    mkdir(outputDir);
end

projectRoot = fileparts(mfilename("fullpath"));
tempDir = tempname;
mkdir(tempDir);

cleanupObject = onCleanup(@() cleanup_temp_dir(tempDir)); %#ok<NASGU>

matFile = fullfile(tempDir, 'battery_report_context.mat');
scriptBaseName = matlab.lang.makeValidName(reportBaseName);
if strlength(string(scriptBaseName)) == 0
    scriptBaseName = 'battery_report';
end
scriptFile = fullfile(tempDir, [char(scriptBaseName), '.m']);

save(matFile, "dataTable", "timeRange_s", "projectRoot");
write_publish_script(scriptFile, matFile, projectRoot);

options = struct( ...
    "format", "html", ...
    "outputDir", outputDir, ...
    "showCode", false, ...
    "useNewFigure", true);

addpath(tempDir);

publish([char(scriptBaseName), '.m'], options);
generatedPath = fullfile(outputDir, [char(scriptBaseName), '.html']);
if ~isfile(generatedPath)
    error("Published report was not created: %s", generatedPath);
end

if ~strcmpi(generatedPath, reportPath)
    if isfile(reportPath)
        delete(reportPath);
    end
    copyfile(generatedPath, reportPath);
end
end

function write_publish_script(scriptFile, matFile, projectRoot)
lines = {
    '%% Battery Data Report'
    '% This report was generated from the Battery Data Visualizer GUI.'
    '% It summarizes the selected time window and includes one labeled section for each plot.'
    ''
    ['load(', matlab_char_literal(matFile), ', ''dataTable'', ''timeRange_s'', ''projectRoot'');']
    ['addpath(', matlab_char_literal(projectRoot), ');']
    'summary = summarize_battery_data(dataTable, timeRange_s);'
    ''
    '%% Summary'
    '% These metrics describe the currently selected time range from the GUI.'
    'fprintf(''Report generated: %s\n'', datestr(now, 0));'
    'fprintf(''Displayed range: %.1f s to %.1f s (duration: %.1f s)\n'', summary.AppliedRange_s(1), summary.AppliedRange_s(2), summary.Duration_s);'
    'fprintf(''Samples in range: %d\n'', summary.SampleCount);'
    'fprintf(''Voltage: min %.2f V, max %.2f V, average %.2f V\n'', summary.MinVoltage_V, summary.MaxVoltage_V, summary.AverageVoltage_V);'
    'fprintf(''Current: min %.2f A, max %.2f A, average %.2f A\n'', summary.MinCurrent_A, summary.MaxCurrent_A, summary.AverageCurrent_A);'
    'fprintf(''Temperature: min %.2f C, max %.2f C, average %.2f C\n'', summary.MinTemperature_C, summary.MaxTemperature_C, summary.AverageTemperature_C);'
    'fprintf(''SOC: start %.2f %%, end %.2f %%, delta %.2f %%\n'', summary.SOCStart_pct, summary.SOCEnd_pct, summary.SOCDelta_pct);'
    ''
    '%% State of Charge Plot'
    '% State of charge over the selected time range.'
    'figure(''Color'', ''w'', ''Position'', [100, 100, 900, 420]);'
    'ax = axes(''Parent'', gcf);'
    'battery_visualization(ax, dataTable, "SOC vs Time", summary.AppliedRange_s);'
    'fprintf(''SOC started at %.2f %% and ended at %.2f %%.\n'', summary.SOCStart_pct, summary.SOCEnd_pct);'
    ''
    '%% Voltage Plot'
    '% Pack voltage behavior over the selected time range.'
    'figure(''Color'', ''w'', ''Position'', [100, 100, 900, 420]);'
    'ax = axes(''Parent'', gcf);'
    'battery_visualization(ax, dataTable, "Voltage vs Time", summary.AppliedRange_s);'
    'fprintf(''Voltage ranged from %.2f V to %.2f V with an average of %.2f V.\n'', summary.MinVoltage_V, summary.MaxVoltage_V, summary.AverageVoltage_V);'
    ''
    '%% Current Plot'
    '% Pack current behavior over the selected time range.'
    'figure(''Color'', ''w'', ''Position'', [100, 100, 900, 420]);'
    'ax = axes(''Parent'', gcf);'
    'battery_visualization(ax, dataTable, "Current vs Time", summary.AppliedRange_s);'
    'fprintf(''Current ranged from %.2f A to %.2f A with an average of %.2f A.\n'', summary.MinCurrent_A, summary.MaxCurrent_A, summary.AverageCurrent_A);'
    ''
    '%% Temperature Plot'
    '% Battery temperature over the selected time range.'
    'figure(''Color'', ''w'', ''Position'', [100, 100, 900, 420]);'
    'ax = axes(''Parent'', gcf);'
    'battery_visualization(ax, dataTable, "Temperature vs Time", summary.AppliedRange_s);'
    'fprintf(''Temperature ranged from %.2f C to %.2f C with an average of %.2f C.\n'', summary.MinTemperature_C, summary.MaxTemperature_C, summary.AverageTemperature_C);'
    };

fid = fopen(scriptFile, 'w');
if fid == -1
    error("Unable to create temporary publish script: %s", scriptFile);
end

fileCloser = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, "%s\n", lines{:});
end

function value = matlab_char_literal(textValue)
value = ['''', strrep(char(string(textValue)), '''', ''''''), ''''];
end

function cleanup_temp_dir(tempDir)
pathEntries = strsplit(path, pathsep);
if any(strcmpi(pathEntries, tempDir))
    rmpath(tempDir);
end

if isfolder(tempDir)
    rmdir(tempDir, "s");
end
end
