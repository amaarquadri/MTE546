clear; clc; close all;

for d = 0:10
    for k = 1:50
        for p = 1:20
            if p <= 16
                type = "Training";
            else
                type = "Testing";
            end
            img = get_spectrogram("Handwritten Digits Data/P" + ...
                num2str(p) + "/D" + num2str(d) + "/" + num2str(k) + ...
                "_D" + num2str(d) + ".csv");
            imwrite(img, "Processed Data/" + type + " Data/D" + ...
                num2str(d) + "/P" + num2str(p) + "_" + num2str(k) + ".png");
        end
    end
end

function visualize_trajectory(orientations)
    tp = theaterPlot("XLimit", [-2 2], "YLimit", [-2 2], "ZLimit", [-2 2]);
    op = orientationPlotter(tp, "DisplayName", "Fused Data", ...
        "LocalAxesLength", 2);
    for i = 1:height(orientations)
        plotOrientation(op, orientations(i));
        drawnow;
    end
end

function padded_data = pad_data(data, output_size)
    if mod(output_size - length(data), 2) == 0
        padding = (output_size - length(data)) / 2;
        padded_data = padarray(data, padding, "replicate", "both");
    else
        padding = (output_size - length(data) - 1) / 2;
        padded_data = padarray(data, padding, "replicate", "both");
        padded_data = [padded_data, data(end)];
    end
end

function img = get_spectrogram(file_name)
    dataset = csvread(file_name, 1);
    accel_readings = dataset(:, 1:3);
    gyro_readings = dataset(:, 4:6);
    mag_readings = dataset(:, 7:9);

    fuse = complementaryFilter("SampleRate", 20);
    [orientations, ~] = fuse(accel_readings, gyro_readings, mag_readings);
    [yaws, pitches, rolls] = quat2angle(compact(orientations));

    PADDED_SIZE = 500; % P12, 8_d3
    rolls = pad_data(rolls, PADDED_SIZE);
    pitches = pad_data(pitches, PADDED_SIZE);
    yaws = pad_data(yaws, PADDED_SIZE);

    TARGET_SIZE = 224;
    img = zeros(TARGET_SIZE, TARGET_SIZE, 3);
    img(:, :, 1) = abs(spectrogram(rolls, 54, 52, 446));
    img(:, :, 2) = abs(spectrogram(pitches, 54, 52, 446));
    img(:, :, 3) = abs(spectrogram(yaws, 54, 52, 446));
end
