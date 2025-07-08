function runSimulation(Tsim, lambda, mu, channels, p_handover)
    % Initialize simulation variables
    currentTime = 0;                     % Current simulation time
    call_id_counter = 0;                % Counter to assign unique call IDs
    blocked_calls = 0;                  % Count of calls blocked at arrival
    dropped_calls = 0;                  % Count of calls dropped during handover
    completed_calls = 0;                % Count of calls completed successfully

    occupied = struct('A', 0, 'B', 0, 'C', 0);  % Channels currently occupied in each cell
    activeCalls = containers.Map('KeyType', 'int32', 'ValueType', 'any');  % Stores active calls
    events = struct('time', {}, 'type', {}, 'call_id', {});                % List of all events
    timeline = [];                    % Log of event timestamps for plotting

    % Schedule the first call arrival event
    nextArrival = currentTime + exprnd(1/lambda);
    events(end+1) = struct('time', nextArrival, 'type', 'arrival', 'call_id', -1);

    % Main simulation loop: runs until all events are processed
    while ~isempty(events)
        [~, idx] = sort([events.time]);    % Sort events chronologically
        events = events(idx);              % Apply sorted order
        event = events(1);                 % Pick the earliest event
        events(1) = [];                    % Remove it from the list

        currentTime = event.time;          % Advance simulation time
        if currentTime > Tsim              % Stop if simulation time is exceeded
            break;
        end

        switch event.type
            case 'arrival'  % New call arrival
                if occupied.A < channels    % Check if a channel is free in Cell A
                    call_id_counter = call_id_counter + 1;
                    call.id = call_id_counter;  % Assign ID
                    call.cell = 'A';            % Initial cell
                    call.handed_over1 = false;  % First handover not yet done
                    call.handed_over2 = false;  % Second handover not yet done

                    call_duration = exprnd(1/mu);       % Generate call duration
                    call.departure_time = currentTime + call_duration; % Departure time

                    if rand < p_handover                % With probability, schedule handovers
                        offset1 = call_duration * (0.3 + 0.1*rand);  % Handover A→B
                        offset2 = call_duration * (0.6 + 0.1*rand);  % Handover B→C
                        call.handover_time1 = currentTime + offset1;
                        call.handover_time2 = currentTime + offset2;
                        events(end+1) = struct('time', call.handover_time1, 'type', 'handover1', 'call_id', call.id);
                        events(end+1) = struct('time', call.handover_time2, 'type', 'handover2', 'call_id', call.id);
                    else
                        call.handover_time1 = inf;
                        call.handover_time2 = inf;
                    end

                    activeCalls(call.id) = call;              % Store call
                    occupied.A = occupied.A + 1;              % Occupy channel in A
                    events(end+1) = struct('time', call.departure_time, 'type', 'departure', 'call_id', call.id); % Schedule departure
                    timeline(end+1, :) = [currentTime, call.id, 1];  % Log arrival
                else
                    blocked_calls = blocked_calls + 1;        % No channel → block call
                end

                nextArrival = currentTime + exprnd(1/lambda); % Schedule next arrival
                events(end+1) = struct('time', nextArrival, 'type', 'arrival', 'call_id', -1);

            case 'handover1'  % Handover from A to B
                if isKey(activeCalls, event.call_id)
                    call = activeCalls(event.call_id);
                    if ~call.handed_over1 && occupied.B < channels
                        call.handed_over1 = true;             % Mark handover 1 done
                        call.cell = 'B';                      % Update cell
                        occupied.A = occupied.A - 1;          % Free A
                        occupied.B = occupied.B + 1;          % Occupy B
                        activeCalls(event.call_id) = call;    % Update call state
                        timeline(end+1, :) = [currentTime, call.id, 2];  % Log handover 1
                    else
                        dropped_calls = dropped_calls + 1;    % Drop if B is full
                        remove(activeCalls, call.id);         % Remove call
                    end
                end

            case 'handover2'  % Handover from B to C
                if isKey(activeCalls, event.call_id)
                    call = activeCalls(event.call_id);
                    if ~call.handed_over2 && call.handed_over1 && occupied.C < channels
                        call.handed_over2 = true;             % Mark handover 2 done
                        call.cell = 'C';                      % Update cell
                        occupied.B = occupied.B - 1;          % Free B
                        occupied.C = occupied.C + 1;          % Occupy C
                        activeCalls(event.call_id) = call;    % Update call state
                        timeline(end+1, :) = [currentTime, call.id, 3];  % Log handover 2
                    else
                        dropped_calls = dropped_calls + 1;    % Drop if C is full
                        remove(activeCalls, call.id);         % Remove call
                    end
                end

            case 'departure'  % Call completes or ends
                if isKey(activeCalls, event.call_id)
                    call = activeCalls(event.call_id);
                    occupied.(call.cell) = occupied.(call.cell) - 1;  % Free up current cell
                    completed_calls = completed_calls + 1;           % Count completion
                    remove(activeCalls, call.id);                    % Remove from active calls
                    timeline(end+1, :) = [currentTime, call.id, 4];  % Log departure
                end
        end
    end

    % Display results
    fprintf('\n--- Simulation Completed ---\n');
    fprintf('Completed Calls: %d\n', completed_calls);
    fprintf('Blocked Calls: %d\n', blocked_calls);
    fprintf('Dropped Calls: %d\n', dropped_calls);

    %% Plot Utilization Over Time
    time_step = 100;                           % Sampling interval for plotting
    t_range = 0:time_step:Tsim;                % Time range for plotting
    uA = zeros(size(t_range)); uB = uA; uC = uA;  % Utilization arrays

    % Re-run timeline to reconstruct occupancy history for plotting
    occupied = struct('A', 0, 'B', 0, 'C', 0);  % Reset occupancy
    activeCalls = containers.Map('KeyType', 'int32', 'ValueType', 'any'); % Reset active calls
    idx = 1;                                   % Index for timeline processing

    for t = t_range
        while idx <= size(timeline, 1) && timeline(idx, 1) <= t
            e = timeline(idx, :);
            if e(3) == 1  % arrival
                occupied.A = occupied.A + 1;
            elseif e(3) == 2  % handover1
                occupied.A = occupied.A - 1;
                occupied.B = occupied.B + 1;
            elseif e(3) == 3  % handover2
                occupied.B = occupied.B - 1;
                occupied.C = occupied.C + 1;
            elseif e(3) == 4  % departure
                % Free last occupied cell
                if occupied.C > 0
                    occupied.C = occupied.C - 1;
                elseif occupied.B > 0
                    occupied.B = occupied.B - 1;
                else
                    occupied.A = max(occupied.A - 1, 0);
                end
            end
            idx = idx + 1;
        end
        % Store utilization at time t
        uA(t/time_step + 1) = occupied.A / channels;
        uB(t/time_step + 1) = occupied.B / channels;
        uC(t/time_step + 1) = occupied.C / channels;
    end

    % Plot the utilization over time
    figure;
    plot(t_range, uA, 'r', t_range, uB, 'g', t_range, uC, 'b', 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Utilization');
    legend('Cell A', 'Cell B', 'Cell C');
    title('Channel Utilization Over Time');
    grid on;

    %% Plot Event Timeline
    figure;
    hold on;
    colors = {'ko', 'go', 'bo', 'rx'};               % Marker styles for events
    labels = {'Arrival', 'Handover 1', 'Handover 2', 'Departure'};
    for i = 1:4
        eventTimes = timeline(timeline(:,3)==i, 1);  % Time of each event type
        callIDs = timeline(timeline(:,3)==i, 2);     % Call ID for event
        scatter(eventTimes, callIDs, 36, colors{i}, 'DisplayName', labels{i});  % Plot event
    end
    xlabel('Time (s)');
    ylabel('Call ID');
    title('Event Timeline');
    legend;
    grid on;
    hold off;
end
