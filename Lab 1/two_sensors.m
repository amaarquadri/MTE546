clear; clc; close all;
distances = 20:10:70;

f_inv = @(p, x) (p(3) .* x - p(2)) ./ (p(1) - x);
long_model = [0.1565, 54.62, 2.895];
med_model = [-0.1746, 28.97, 3.757];

results = zeros(length(distances), 3);
for i = 1:length(distances)
    dataset = load("two_" + int2str(distances(i)) + "cm.mat").data;
    long_voltages = dataset(:, 1);
    med_voltages = dataset(:, 2);
    long_distances = f_inv(long_model, long_voltages);
    med_distances = f_inv(med_model, med_voltages);
    results(i, 1:2) = [mean(long_distances), mean(med_distances)];
end
results(:, 3) = (results(:, 1) + results(:, 2)) / 2;
