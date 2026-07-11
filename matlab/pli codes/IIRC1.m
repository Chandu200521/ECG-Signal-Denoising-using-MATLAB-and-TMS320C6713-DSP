clc;
clear all;
close all;
% Load ECG Signal (100.mat)
ecg_folder = 'C:\Users\P CHANDU\OneDrive\Desktop\mit-bih-arrhythmia-database-1.0.0';
data   = load(fullfile(ecg_folder, '100.mat'));
signal = data.signal;
Fs     = double(data.Fs);   % 360 Hz

% --- Take only first channel ---
ecg = signal(:, 1);

% --- Ensure column vector ---
ecg = ecg(:);

% --- Remove DC offset ---
ecg = ecg - mean(ecg);

% --- Normalize ---
ecg = ecg / max(abs(ecg));

% --- Time axis ---
t = (0:length(ecg)-1)' / Fs;

fprintf('ECG loaded: %d samples, Fs = %d Hz\n', length(ecg), Fs);

% STEP 2: Load PLI Noise
pli_folder = 'C:\Users\P CHANDU\OneDrive\Desktop\mit-bih-noise-stress-test-database-1.0.0\old';
pli        = load(fullfile(pli_folder, 'pli_noise_only.mat'));

% --- Choose PLI type ---
noise_signal = pli.pli_50hz;

noise_Fs = double(pli.Fs);

fprintf('PLI loaded: %d samples, Fs = %d Hz\n', length(noise_signal), noise_Fs);

% --- Ensure column vector ---
noise = noise_signal(:);

% STEP 3: Match lengths
min_len      = min(length(ecg), length(noise));
ecg          = ecg(1:min_len);
noise        = noise(1:min_len);
t            = t(1:min_len);

% --- Remove DC offset from noise ---
noise = noise - mean(noise);

% --- Normalize noise ---
noise = noise / max(abs(noise));

% STEP 4: Add PLI noise to ECG
noisy_ecg = ecg + noise;

% --- Normalize noisy ECG ---
noisy_ecg = noisy_ecg / max(abs(noisy_ecg));

fprintf('Noisy ECG created successfully!\n');

% STEP 5: Plot Results
duration = 5;
samples  = 1 : min(duration * Fs, min_len);

figure;   

% Clean ECG
subplot(3,1,1);
plot(t(samples), ecg(samples), 'b', 'LineWidth', 0.8);
grid on;
title('Clean ECG Signal');
xlabel('Time (seconds)');
ylabel('Normalized Amplitude');

% PLI Noise
subplot(3,1,2);
plot(t(samples), noise(samples), 'r', 'LineWidth', 0.8);
grid on;
title('PLI Noise (50 Hz)');
xlabel('Time (seconds)');
ylabel('Amplitude');

% Noisy ECG
subplot(3,1,3);
plot(t(samples), noisy_ecg(samples), 'm', 'LineWidth', 0.8);
grid on;
title('ECG + PLI Noise');
xlabel('Time (seconds)');
ylabel('Amplitude');

% Frequency Spectrum
N = length(noisy_ecg);
Y = fft(noisy_ecg);
f = (0:N-1) * (Fs / N);

%design of filter( chebyshev 1)
f0 = 50;               
wo = f0/(Fs/2);         
bw = wo/35;             
Wn = [wo-bw/2 wo+bw/2];
N = 4;                  % Filter order
Rp = 1;                 % Passband ripple (dB)
[b,a] = cheby1(N,Rp,Wn,'stop');

% --- Apply filter ---
filtered_ecg = filtfilt(b,a,noisy_ecg);

% --- Normalize output ---
filtered_ecg = filtered_ecg/max(abs(filtered_ecg));

fprintf('Noise removed using Chebyshev Type-I Notch Filter!\n');

figure; 

%freq spec plot
subplot(3,1,1);
plot(f(1:N/2), abs(Y(1:N/2)), 'k', 'LineWidth', 0.8);
xlim([0 100]);
grid on;
title('Frequency Spectrum (CHEBYSHEV 1)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xline(50, 'r--', '50 Hz PLI');
sgtitle('ECG Signal + PLI Noise Analysis');
fprintf('Plots generated successfully!\n');


% Before filtering
subplot(3,1,2);
plot(t(samples), ecg(samples), 'r');
title('Original ECG');
xlim([0,5]);
ylim([-0.2,0.6]);
grid on;

% After filtering
subplot(3,1,3);
plot(t(samples), filtered_ecg(samples), 'g');
title('Filtered ECG (50 Hz Removed)');
xlim([0,5]);
ylim([-0.2,0.4]);
grid on;

disp("bandwidth: ");
disp(bw);

%% ---------------- MSE Calculation ----------------

mse_value = mean((ecg - filtered_ecg).^2);

fprintf('MSE = %.8f\n', mse_value);

%% ---------------- RMSE Calculation ----------------

rmse_value = sqrt(mse_value);

fprintf('RMSE = %.8f\n', rmse_value);

%% ---------------- Average Power ----------------

power_clean = mean(ecg.^2);
power_noisy = mean(noisy_ecg.^2);
power_filtered = mean(filtered_ecg.^2);

fprintf('Average Power of Clean ECG    = %.6f\n', power_clean);
fprintf('Average Power of Noisy ECG    = %.6f\n', power_noisy);
fprintf('Average Power of Filtered ECG = %.6f\n', power_filtered);

%% ---------------- Overall Gain ----------------

gain_linear = rms(filtered_ecg) / rms(ecg);
gain_db = 20*log10(gain_linear);

fprintf('Overall Gain (Linear) = %.6f\n', gain_linear);
fprintf('Overall Gain (dB)     = %.4f dB\n', gain_db);

%% ---------------- SNR Calculation ----------------

% -------- Input SNR (Before Filtering) --------

signal_power = mean(ecg.^2);          % Power of clean ECG
noise_power = mean(noise.^2);         % Power of added PLI noise

snr_before = 10*log10(signal_power / noise_power);

fprintf('\n========== SNR RESULTS ==========\n');
fprintf('Signal Power            = %.6f\n', signal_power);
fprintf('PLI Noise Power         = %.6f\n', noise_power);
fprintf('Input SNR               = %.4f dB\n', snr_before);


% -------- Output SNR (After Filtering) --------

% Residual noise present in filtered ECG
residual_noise = filtered_ecg - ecg;

% Remaining noise power after filtering
residual_noise_power = mean(residual_noise.^2);

% Output SNR
snr_after = 10*log10(signal_power / residual_noise_power);

fprintf('\nResidual Noise Power    = %.6f\n', residual_noise_power);
fprintf('Output SNR              = %.4f dB\n', snr_after);
fprintf('SNR Improvement         = %.4f dB\n', snr_after - snr_before);