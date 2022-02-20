clear; clc; close all;
t = load("Amodeltime.mat").time;
file_names = ["Amodelmotion", "accelerateddata", "random movement", ...
              "stationary", "fuzzysurface"];

dt = mean(diff(t));
G = [0.5 * dt^2; dt];
Q = G * G' * 250e3;
R = [0.000648578309533081, 0;
     0, 0.000521004497980967];

% simulated results
% different initial state estimates
motion_model = 10 * t + 10;
readings = get_readings(motion_model) + randn(length(t), 2) * R;
state_values_default = get_ekf_trajectory(...
    t, readings, zeros(2, 1), eye(2), Q, R);
state_values_good_estimate = get_ekf_trajectory(...
    t, readings, [10; 10], eye(2), Q, R);
figure; hold on;
plot(t, motion_model);
plot(t, state_values_default(:, 1));
plot(t, state_values_good_estimate(:, 1));
legend(["True Motion", "Bad Initial Estimate", "Good Initial Estimate"]);
xlabel("Time (s)");
ylabel("Position (cm)");
title("Good VS Bad Initial Estimate");

% different sensor noise variances
high_variance_readings = get_readings(motion_model) + ...
    1000 * randn(size(readings)) * R;
state_values_high_sensor_variance = get_ekf_trajectory(...
    t, high_variance_readings, [10; 10], eye(2), Q, R);
figure; hold on;
plot(t, motion_model);
plot(t, state_values_default(:, 1));
plot(t, state_values_high_sensor_variance(:, 1));
legend(["True Motion", "Expected Sensor Noise Variance", ...
    "High Sensor Noise Variance"]);
xlabel("Time (s)");
ylabel("Position (cm)");
title("Expected VS High Sensor Noise Variance");

% different system noise variances
state_values_high_system_variance = get_ekf_trajectory(...
    t, readings, [10; 10], eye(2), 1000 * Q, R);
figure; hold on;
plot(t, motion_model);
plot(t, state_values_default(:, 1));
plot(t, state_values_high_system_variance(:, 1));
legend(["True Motion", "Expected System Noise Variance", ...
    "High System Noise Variance"]);
xlabel("Time (s)");
ylabel("Position (cm)");
title("Expected VS High System Noise Variance");

% different motion models
sinusoidal_motion_model = 30 * sin((2 * pi / 3) * t) + 40;
stationary_motion_model = 40 * ones(size(t));
sinusoidal_readings = get_readings(sinusoidal_motion_model) + ...
    randn(length(t), 2) * R;
stationary_readings = get_readings(stationary_motion_model) + ...
    randn(length(t), 2) * R;
state_values_sinusoidal = get_ekf_trajectory(...
    t, sinusoidal_readings, zeros(2, 1), eye(2), Q, R);
state_values_stationary = get_ekf_trajectory(...
    t, stationary_readings, zeros(2, 1), eye(2), Q, R);
figure; hold on;
plot(t, state_values_default(:, 1));
plot(t, state_values_sinusoidal(:, 1));
plot(t, state_values_stationary(:, 1));
legend(["Linear Motion", "Sinusoidal Motion", "Stationary"]);
xlabel("Time (s)");
ylabel("Position (cm)");
title("Different Motions");

% experimental results
for i = 1:length(file_names)
    readings = load(file_names(i) + ".mat").data;
    if length(t) ~= height(readings)
        error("Sizes don't match!");
    end
    
    state_values = get_ekf_trajectory(...
        t, readings, zeros(2, 1), eye(2), Q, R);
    
    figure; hold on;
    plot(t, state_values(:, 1));
    plot(t, state_values(:, 2));
    legend(["Position", "Velocity"]);
    xlabel("Time (s)");
    ylabel("Position (cm), Velocity (cm/s)");
    title(file_names(i));
    % if i == 1
    %     plot(t, long_sensor(readings(:, 1)));
    %     plot(t, med_sensor(readings(:, 2)));
    % end
end

function state_values = get_ekf_trajectory(t, readings, state, P, Q, R)
    state_values = zeros(length(t), 2);
    state_values(1, :) = state';
    for i = 2:length(t)
        dt = t(i) - t(i - 1);
        if isnan(state(1))
            error("Nan state");
        end

        % prediction step
        state = f(state, dt);
        f_jac = get_f_jac(dt);
        P = f_jac * P * f_jac' + Q;

        % update step
        z = readings(i, :)';
        y = z - h(state);
        h_jac = get_h_jac(state);
        S = h_jac * P * h_jac' + R;
        K = P * h_jac' / S;
        state = state + K * y;
        P = P - K * h_jac * P;

        state_values(i, :) = state';
    end
end

function new_state = f(state, dt)
    new_state = get_f_jac(dt) * state;
end

function jac = get_f_jac(dt)
    jac = [1, dt;
           0 1];
end

function voltages = h(state)
    voltages = get_readings(state(1))';
end

function jac = get_h_jac(state)
    x = state(1);
    jac = [-21666773 / (10 * (200 * x + 579)^2), 0;
           -148129861 / (5 * (1000 * x + 3757)^2), 0];
end

function position = long_sensor(voltage)
    position = (2.895 .* voltage - 54.62) ./ (0.1565 - voltage);
end

function position = med_sensor(voltage)
    position = (3.757 .* voltage - 28.97) ./ (-0.1746 - voltage);
end

function readings = get_readings(motion_model)
    readings = [(0.1565 .* motion_model + 54.62) ./ (motion_model + 2.895) ...
                (-0.1746 .* motion_model + 28.97) ./ (motion_model + 3.757)];
end
