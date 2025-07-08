function run_simulator_gui()
    % Create GUI
    fig = figure('Name', 'Multi-Cell Channel Simulator', 'Position', [200, 200, 500, 500]);

    % Input labels and boxes
    uicontrol('Style', 'text', 'Position', [30 440 150 20], 'String', 'Simulation Time (Tsim)');
    hTsim = uicontrol('Style', 'edit', 'Position', [200 440 100 25], 'String', '10000');

    uicontrol('Style', 'text', 'Position', [30 400 150 20], 'String', 'Arrival Rate (λ)');
    hlambda = uicontrol('Style', 'edit', 'Position', [200 400 100 25], 'String', '0.1');

    uicontrol('Style', 'text', 'Position', [30 360 150 20], 'String', 'Call Duration Rate (μ)');
    hmu = uicontrol('Style', 'edit', 'Position', [200 360 100 25], 'String', num2str(1/180));

    uicontrol('Style', 'text', 'Position', [30 320 150 20], 'String', 'Channels per Cell');
    hchannels = uicontrol('Style', 'edit', 'Position', [200 320 100 25], 'String', '10');

    uicontrol('Style', 'text', 'Position', [30 280 150 20], 'String', 'Handover Probability');
    hhandover = uicontrol('Style', 'edit', 'Position', [200 280 100 25], 'String', '0.5');

    % Run button
    uicontrol('Style', 'pushbutton', 'String', 'Run Simulation', ...
        'Position', [150 220 200 40], ...
        'Callback', @(~,~) runSimulation(...
            str2double(get(hTsim, 'String')), ...
            str2double(get(hlambda, 'String')), ...
            str2double(get(hmu, 'String')), ...
            str2double(get(hchannels, 'String')), ...
            str2double(get(hhandover, 'String')) ...
        ));
end
