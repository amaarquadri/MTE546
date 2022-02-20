clear; clc; close all;

original_voltages = load("long_60cm").data;
rotated_voltages = load("rotated_condition_60cm_long.mat").data;
wood_voltages = load("wood_block_long_60cm.mat").data;

f_inv = @(p, x) (p(3) .* x - p(2)) ./ (p(1) - x);
long_model = [0.1565, 54.62, 2.895];

results = zeros(3, 2);
original_distances = f_inv(long_model, original_voltages);
rotated_distances = f_inv(long_model, rotated_voltages);
wood_distances = f_inv(long_model, wood_voltages);


results(1, :) = [mean(original_distances), std(original_distances)];
results(2, :) = [mean(rotated_distances), std(rotated_distances)];
results(3, :) = [mean(wood_distances), std(wood_distances)];
