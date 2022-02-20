clear; clc; close all;
distances = [20, 30, 130];

f_inv = @(p, x) (p(3) .* x - p(2)) ./ (p(1) - x);
long_model = [0.1565, 54.62, 2.895];

results = zeros(3, 4);
for i = 1:length(distances)
    baud9800_dataset = load("long_" + int2str(distances(i)) + "cm.mat").data;
    baud39200_dataset = load("long_" + int2str(distances(i)) + "_39200.mat").data;
    baud9800_distances = f_inv(long_model, baud9800_dataset);
    baud39200_distances = f_inv(long_model, baud39200_dataset);
    results(i, :) = [mean(baud9800_distances), std(baud9800_distances), ...
        mean(baud39200_distances), std(baud39200_distances)];
end
    