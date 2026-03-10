function battery_app_gui
% BATTERY_APP_GUI Functional prototype for battery data visualization.
% Week 4 deliverables:
%   - SOC / Voltage / Current / Temperature vs time plotting
%   - basic time-range selection
% Week 5 deliverables:
%   - Load CSV button
%   - Generate synthetic data button
%   - Plot display area
%   - Plot selection dropdown

dataTable = table();

fig = uifigure( ...
    "Name", "Battery Data Visualizer", ...
    "Position", [100, 100, 1120, 680], ...
    "Color", [0.97, 0.97, 0.98]);

uibutton(fig, "push", ...
    "Text", "Load CSV", ...
    "Position", [20, 635, 110, 32], ...
    "ButtonPushedFcn", @onLoadCsv);

uibutton(fig, "push", ...
    "Text", "Generate Synthetic Data", ...
    "Position", [145, 635, 180, 32], ...
    "ButtonPushedFcn", @onGenerateSynthetic);

uilabel(fig, ...
    "Text", "Plot:", ...
    "Position", [350, 640, 35, 22]);

plotDropdown = uidropdown(fig, ...
    "Items", { ...
        'SOC vs Time', ...
        'Voltage vs Time', ...
        'Current vs Time', ...
        'Temperature vs Time'}, ...
    "Value", 'SOC vs Time', ...
    "Position", [390, 635, 180, 32], ...
    "ValueChangedFcn", @onControlsChanged);

uilabel(fig, ...
    "Text", "Start Time (s):", ...
    "Position", [590, 640, 92, 22]);

startTimeField = uieditfield(fig, "numeric", ...
    "Position", [686, 635, 95, 32], ...
    "ValueChangedFcn", @onControlsChanged);

uilabel(fig, ...
    "Text", "End Time (s):", ...
    "Position", [798, 640, 85, 22]);

endTimeField = uieditfield(fig, "numeric", ...
    "Position", [886, 635, 95, 32], ...
    "ValueChangedFcn", @onControlsChanged);

uibutton(fig, "push", ...
    "Text", "Full Range", ...
    "Position", [994, 635, 100, 32], ...
    "ButtonPushedFcn", @onResetRange);

plotAxes = uiaxes(fig, ...
    "Position", [20, 90, 1074, 525], ...
    "Box", "on");
grid(plotAxes, "on");
title(plotAxes, "Load CSV or generate synthetic data to begin");
xlabel(plotAxes, "Time (s)");
ylabel(plotAxes, "Value");

statusLabel = uilabel(fig, ...
    "Text", "Ready.", ...
    "Position", [20, 30, 1074, 30], ...
    "HorizontalAlignment", "left");

tryLoadDefaultSample();

    function tryLoadDefaultSample
        samplePath = fullfile(pwd, 'sample_battery_data.csv');
        if ~isfile(samplePath)
            return;
        end

        try
            loadedTable = readtable(samplePath);
            dataTable = normalize_battery_table(loadedTable);
            syncTimeControlsToData();
            updatePlot();
            statusLabel.Text = "Loaded default sample_battery_data.csv";
        catch
            % Ignore preload errors; user can load/generate manually.
        end
    end

    function onLoadCsv(~, ~)
        [fileName, filePath] = uigetfile("*.csv", "Select Battery CSV");
        if isequal(fileName, 0)
            statusLabel.Text = "CSV load canceled.";
            return;
        end

        fullPath = fullfile(filePath, fileName);

        try
            loadedTable = readtable(fullPath);
            dataTable = normalize_battery_table(loadedTable);
            syncTimeControlsToData();
            updatePlot();
            statusLabel.Text = sprintf("Loaded: %s", fullPath);
        catch ME
            uialert(fig, ME.message, "CSV Load Error");
            statusLabel.Text = "Failed to load CSV.";
        end
    end

    function onGenerateSynthetic(~, ~)
        outputPath = fullfile(pwd, 'sample_battery_data.csv');

        try
            generatedTable = randomized_data_generator(outputPath, false);
            dataTable = normalize_battery_table(generatedTable);
            syncTimeControlsToData();
            updatePlot();
            statusLabel.Text = sprintf("Generated synthetic data: %s", outputPath);
        catch ME
            uialert(fig, ME.message, "Generation Error");
            statusLabel.Text = "Synthetic data generation failed.";
        end
    end

    function onControlsChanged(~, ~)
        if isempty(dataTable)
            return;
        end
        updatePlot();
    end

    function onResetRange(~, ~)
        if isempty(dataTable)
            return;
        end
        syncTimeControlsToData();
        updatePlot();
    end

    function syncTimeControlsToData
        tMin = dataTable.Time_s(1);
        tMax = dataTable.Time_s(end);

        if tMax <= tMin
            tMax = tMin + 1;
        end

        startTimeField.Limits = [tMin, tMax];
        endTimeField.Limits = [tMin, tMax];
        startTimeField.Value = tMin;
        endTimeField.Value = tMax;
    end

    function updatePlot
        if isempty(dataTable)
            cla(plotAxes);
            title(plotAxes, "Load CSV or generate synthetic data to begin");
            xlabel(plotAxes, "Time (s)");
            ylabel(plotAxes, "Value");
            return;
        end

        selectedRange = [startTimeField.Value, endTimeField.Value];
        if selectedRange(1) > selectedRange(2)
            selectedRange = fliplr(selectedRange);
            startTimeField.Value = selectedRange(1);
            endTimeField.Value = selectedRange(2);
        end

        battery_visualization(plotAxes, dataTable, plotDropdown.Value, selectedRange);

        statusLabel.Text = sprintf( ...
            "Displaying %s (%.1f s to %.1f s)", ...
            plotDropdown.Value, selectedRange(1), selectedRange(2));
    end
end
