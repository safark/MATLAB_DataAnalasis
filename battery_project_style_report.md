# Report about the independent study:
Battery Data Visualization and Automated Reporting Tool in MATLAB

Section Number: [Section Number]  
Course: [Course Name]  
Semester: [Semester]

Done by: [Your Name]  
Supervised by: [Instructor or Supervisor Name]

## Contents
Abstract  
Problem Statement or Objectives  
Background and Project Type  
Dataset Description  
Data Acquisition Challenges  
System Overview  
Main GUI Design  
Battery Visualization and Time-Range Filtering  
Shared Summary Metrics  
Published HTML Report Export  
Results  
Conclusion  
Project Impact  
Future Plans  
Summary: Reflection on the Project  
Project Overview

## Abstract
This project presents a MATLAB-based battery data visualization and reporting application designed to make battery analysis more interactive, organized, and easier to document. The main goal of the project is to allow a user to load battery data from a CSV file or generate synthetic battery data, visualize key battery variables over time, inspect a selected operating interval, and export the findings into a formatted HTML report. Unlike a simple plotting script, this system combines data preprocessing, graphical user interface design, reusable analysis functions, and report publishing in a single workflow.

An important contribution of this project is the addition of a report export feature directly inside the graphical interface. Once data is loaded and a time range is selected, the application can summarize the visible battery behavior and generate a clean report that contains labeled sections and plots. This makes the tool suitable not only for exploratory analysis, but also for technical presentations, documentation, and classroom demonstrations.

## Problem Statement or Objectives
The motivation behind this project is to create a simple but effective MATLAB application for battery data analysis that can be used by someone who may not want to work directly with code each time they need a plot or a report. In many technical workflows, battery data is stored in CSV format, but turning that raw data into readable plots and summary statistics still takes multiple manual steps. This project addresses that issue by building a GUI that centralizes those actions.

The main objectives of the project are to:

Provide an easy way to load real battery CSV files or generate sample battery data for testing.
Display battery behavior using clearly labeled plots for state of charge, voltage, current, and temperature.
Allow the user to focus on a selected time interval instead of always analyzing the entire dataset.
Compute useful summary metrics for the visible data range.
Export the selected analysis to a structured HTML report using MATLAB publishing tools.

## Background and Project Type
This project is mainly focused on data analysis, scientific visualization, GUI application design, and automated technical reporting. It is not a machine learning project; instead, it emphasizes practical engineering workflow support. MATLAB is a strong environment for this type of work because it provides built-in tools for table processing, plotting, UI development, and publishing reports.

The application is built around a modular design. The GUI handles interaction with the user, the visualization function handles plotting, the summary function computes reusable statistics, the normalization function standardizes imported data, and the export function creates the final report. This structure improves clarity and makes the project easier to maintain, explain, and extend.

## Dataset Description
The application expects battery data organized around five core variables:

Time_s: time in seconds  
PackVoltage_V: pack voltage in volts  
Current_A: pack current in amperes  
SOC_pct: state of charge in percent  
Temperature_C: battery temperature in degrees Celsius

To support testing and demonstration, the project includes a synthetic dataset generator. The generator creates a two-hour battery profile sampled once per second, which produces 7201 rows of data from 0 to 7200 seconds. The generated signal includes charging and discharging segments, state-of-charge evolution, voltage behavior based on a simple model, and temperature growth based on a thermal approximation. This default dataset makes it possible to demonstrate the complete application even when no external CSV file is available.

Another useful feature of the project is that imported CSV files do not need to use exactly the same variable names. The normalization step can detect common alternatives such as `Time`, `Voltage`, `Current`, `SOC`, or `Temperature`, then map them into the standardized format expected by the rest of the application.

## Data Acquisition Challenges
One challenge in battery data analysis is that CSV files coming from different sources often use inconsistent column names, text-formatted numeric values, or missing entries. If these issues are not handled carefully, the plots and computed metrics may become misleading or the application may fail to run. This project addresses that challenge through a normalization and cleaning step that converts supported columns into numeric form, removes missing rows, and sorts the final table by time.

Another challenge is the availability of realistic battery test data for demonstrations. To solve this, the project includes a synthetic data generator. Although synthetic data is useful for development and teaching, it may not perfectly match real battery physics. For example, the simplified thermal model can produce temperature values that are more useful for visualization than for physical accuracy. This limitation is important to recognize when presenting the generated results.

## System Overview
The project is divided into several MATLAB files, each with a specific role:

`battery_app_gui.m` creates the full graphical user interface and coordinates user actions.  
`normalize_battery_table.m` cleans imported data and standardizes variable names.  
`randomized_data_generator.m` creates a sample battery dataset for testing.  
`battery_visualization.m` plots the selected battery variable over the chosen time interval.  
`summarize_battery_data.m` computes reusable statistics for the currently visible range.  
`export_battery_report.m` generates a published HTML report from the selected dataset and range.

This separation of responsibilities keeps the project readable and makes the final workflow more robust. Instead of placing all logic inside one large script, the system shares common operations across files, which helps the GUI and exported report stay consistent with one another.

## Main GUI Design
The main interface was created with MATLAB UI components such as `uifigure`, `uiaxes`, `uibutton`, `uidropdown`, `uieditfield`, `uilabel`, and `uipanel`. The GUI allows the user to load a CSV file, generate synthetic data, choose which battery variable to plot, specify a start time and end time, reset the selection to the full range, and export the current view to a report.

The layout is organized so that the plot occupies the larger left side of the interface, while the battery summary panel is displayed on the right side. This gives the user a clear visual balance between trends in the graph and numerical indicators in the summary panel. A status label at the bottom communicates whether the application is ready, loading data, or exporting a report.

SCREENSHOT OF MAIN GUI HERE

## Battery Visualization and Time-Range Filtering
The visualization part of the project supports four plot modes: SOC vs Time, Voltage vs Time, Current vs Time, and Temperature vs Time. A dropdown menu lets the user switch between them without reloading the dataset. This makes it easy to move from a high-level battery charge view to electrical or thermal behavior using the same interface.

The user can also type a start time and end time in seconds. The application then filters the displayed data to that interval and automatically updates both the plot and the summary values. If the entered range is reversed, the program corrects it by sorting the values. If the selected range falls outside the dataset, the application safely falls back to the available limits.

SCREENSHOT OF PLOT SELECTION AND TIME RANGE FILTER HERE

## Shared Summary Metrics
One of the strongest design choices in this project is the use of a shared summary function. The file `summarize_battery_data.m` computes the statistics for the currently displayed interval, including sample count, duration, minimum and maximum voltage, minimum and maximum current, average current, minimum and maximum temperature, average temperature, starting SOC, ending SOC, and SOC change.

These values are not only shown in the summary panel of the GUI, but are also reused during report generation. This is important because it guarantees that the values seen by the user in the application match the values written in the exported HTML report. Reusing the same logic in both places avoids duplication and reduces the chance of inconsistency.

SCREENSHOT OF BATTERY SUMMARY PANEL HERE

## Published HTML Report Export
The report export feature is implemented in `export_battery_report.m`. When the user clicks the Export Data button, the GUI collects the current time range and dataset, then passes them to the export helper. The helper creates a temporary MATLAB script, injects report sections and plotting commands, and calls MATLAB's `publish` function to generate a structured HTML file.

The published report includes a report title, a summary section, and a separate labeled section for each plot type. Because the report is generated from the same dataset and selected time window used in the GUI, it acts as a consistent snapshot of the current analysis. This improves the professionalism of the project and makes it much easier to share results.

SCREENSHOT OF EXPORTED HTML REPORT HERE

## Results
### Loading and normalization results
The application successfully supports both real CSV imports and internally generated sample data. The normalization step improves flexibility by allowing the program to accept related input column names and convert them into the required battery schema. This makes the project more practical in real situations where data files do not always follow one naming convention.

### Synthetic dataset generation results
Using the built-in generator, the project creates a full battery dataset with 7201 samples across a 7200-second interval. The generated profile includes alternating charge, rest, and discharge segments. This gives the user visible changes in current, voltage, state of charge, and temperature, which is helpful when demonstrating the plotting and export features of the application.

### Visualization and summary results
When the default synthetic dataset is loaded over the full range, the exported report shows that the voltage ranges from approximately 338.73 V to 373.86 V, with an average of 358.04 V. The current ranges from about -43.03 A to 63.07 A, with an average of 0.41 A. The state of charge starts at 60.00% and ends at 59.17%, giving a net change of -0.83% across the full interval. The reported temperature ranges from 25.07 C to 268.69 C, which reflects the behavior of the simplified synthetic thermal model used for demonstration purposes.

### Reporting results
The HTML report generation works as an effective extension of the GUI. Instead of leaving the user with on-screen plots only, the project produces a document that contains the selected range, metric summaries, and all four plot sections in a structured format. This turns the application into both an analysis tool and a reporting tool.

SCREENSHOT OF SOC VS TIME REPORT SECTION HERE

SCREENSHOT OF VOLTAGE REPORT SECTION HERE

SCREENSHOT OF CURRENT REPORT SECTION HERE

SCREENSHOT OF TEMPERATURE REPORT SECTION HERE

## Conclusion
This project demonstrates how MATLAB can be used to build a complete engineering workflow around battery data. Rather than stopping at raw plotting, the system supports data loading, preprocessing, plotting, interval-based analysis, metric calculation, and report generation inside a single application. The result is a tool that is more accessible, more organized, and more useful for technical communication.

The addition of the Export Data feature is especially important because it gives the user a polished output that can be saved and shared. This makes the project more valuable for presentations, coursework, and documentation tasks where it is not enough to simply view the data on screen.

## Project Impact
This project improves the usability of battery data analysis by giving the user an interface-driven workflow instead of a script-only workflow. It reduces the effort required to inspect different time intervals, compare multiple battery variables, and create a record of the findings. In an educational setting, it also provides a strong example of how GUI design, modular programming, and technical reporting can be combined inside MATLAB.

## Future Plans
With more time, this project could be extended in several useful directions. The synthetic data model could be improved to better reflect realistic battery thermal dynamics. Additional battery health metrics such as energy throughput, power, efficiency, or anomaly flags could be added to the summary panel and report. The export feature could also be expanded to support PDF output, richer formatting, or automatic screenshot capture from the GUI.

Another useful future improvement would be to add input validation messages that are even more descriptive for the user, along with support for larger battery test datasets, multiple battery channels, or side-by-side comparison of different test runs.

## Summary: Reflection on the Project
I enjoyed working on this project because it combines practical programming with a user-facing result. It was satisfying to move beyond a basic plotting script and build a tool that feels more complete and easier to use. One of the most useful lessons from this work was understanding how modular design makes the application easier to maintain and explain.

What I found most valuable was the connection between the GUI and the reporting system. By sharing the same summary logic between the on-screen interface and the exported HTML report, the project became more reliable and professional. If I continue developing this project, I would focus on making the battery model more realistic and expanding the export options.

## Project Overview
This project focuses on the analysis and presentation of battery data using MATLAB. A graphical user interface was developed to let users load data, generate synthetic examples, visualize key variables, inspect custom time ranges, and review summary statistics. The project was then extended with an HTML report export feature based on MATLAB publishing, allowing the current analysis view to be saved in a clean and structured format. Overall, the project shows how a modular MATLAB application can support both interactive exploration and formal documentation of battery behavior.
