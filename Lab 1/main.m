clear; clc; close all;
long_distances = 20:10:150;
med_distances = 10:5:80;
short_distances = min(30, 4:4:32);
distances_array = {long_distances, med_distances, short_distances};
sensor_names = ["long", "med", "short"];
capital_sensor_names = ["Long", "Medium", "Short"];

% sensor models derived using the Curve Fitting Toolbox
f = @(p, x) (p(1) .*x + p(2)) ./ (x + p(3));
sensor_models = {[0.1565, 54.62, 2.895], ... 
    [-0.1746, 28.97, 3.757], ...
    [-0.1548, 15.05, 2.174]};

long_reference_voltages = [2.51, 2, 1.5, 1.25, 1.05, 0.9, 0.8, 0.7, 0.6, 0.55, 0.53, 0.5, 0.49, 0.489];
med_reference_voltages = [2.25, 1.6, 1.3, 1, 0.85, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.495, 0.493, 0.49, 0.488];
short_reference_voltages = [2.71, 1.58, 1.06, 0.801, 0.67, 0.55, 0.48, 0.42];
reference_voltages = {long_reference_voltages, med_reference_voltages, short_reference_voltages};

std_vals = [];
var_vals = [];
chi2_vals = [];
for i = 1:3
    sensor_distances = distances_array{i};
    sensor_voltages = zeros(1, length(sensor_distances));
    
    for j = 1:length(sensor_distances)
        dataset = load(sensor_names(i) + "_" + int2str(sensor_distances(j)) + "cm.mat").data;
        sensor_voltages(j) = mean(dataset);
        [h, p, stats] = chi2gof(dataset);
        chi2_vals = [chi2_vals, stats.chi2stat];
        std_vals = [std_vals, std(dataset)];
        var_vals = [var_vals, std(dataset)^2];
        
        % Plot a histogram with a normal distribution overlayed
        figure;
        histfit(dataset);
        xlabel("Voltage (V)");
        ylabel("Probability Density");
        title(capital_sensor_names(i) + " " + int2str(sensor_distances(j)) + "cm");
    end
    
    % Plot the data points and the model that is fit to them
    sensor_model = sensor_models{i};
    xs = sensor_distances(1):0.1:sensor_distances(end);
    ys = f(sensor_model, xs);
    figure;
    scatter(sensor_distances, sensor_voltages); hold on;
    plot(xs, ys);
    plot(sensor_distances, reference_voltages{i});
    title(capital_sensor_names(i) + " Sensor");
    xlabel("Distance (cm)");
    ylabel("Voltage (V)");
    legend(["Data Points", "Best Fit", "Datasheet Curve"]);
    
    % Calculate mean and max errors between the model and the data points
    errors = f(sensor_model, sensor_distances) - sensor_voltages;
    disp(capital_sensor_names(i) + "Data:");
    disp(["Mean Error: ", mean(errors)]);
    disp(["Max Error: ", max(errors)]);
    disp(["Max Difference between Reference Model", max(abs(sensor_voltages - reference_voltages{i}))]);
end
