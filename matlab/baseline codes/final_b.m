clc;
clear;
close all;

%% ===========================
% Load Original Clean ECG
%% ===========================

ecg_folder = 'C:\Users\P CHANDU\OneDrive\Desktop\mit-bih-arrhythmia-database-1.0.0';
ecg_data = load(fullfile(ecg_folder,'100.mat'));

clean_ecg = ecg_data.signal(:,1);
Fs = double(ecg_data.Fs);

%% ===========================
% Load MATLAB Filter Output
%% ===========================

folder = 'C:\Users\P CHANDU\OneDrive\Desktop\outputs';
data = load(fullfile(folder,'ecg_filtered.mat'));

% Automatically read variable
varName = fieldnames(data);
matlab_output = data.(varName{1});

%% ===========================
% Load DSP Hardware Output
%% ===========================

data = load(fullfile(folder,'ecg_output_4.mat'));


varName = fieldnames(data);
hardware_output = data.(varName{1});

bw_folder = 'C:\Users\P CHANDU\OneDrive\Desktop\mit-bih-noise-stress-test-database-1.0.0\old';

bw_data = load(fullfile(bw_folder,'oldbw.mat'));


bw = bw_data.signal(:,1);

%% ===========================
% Make all vectors column vectors
%% ===========================

clean_ecg = clean_ecg(:);
matlab_output = matlab_output(:);
hardware_output = hardware_output(:);

%% ===========================
% Match Lengths
%% ===========================

L = min([length(clean_ecg), ...
         length(matlab_output), ...
         length(hardware_output)]);

clean_ecg      = clean_ecg(1:L);
matlab_output  = matlab_output(1:L);
hardware_output = hardware_output(1:L);

clean_ecg=clean_ecg-(mean(clean_ecg));

%% ===========================
% Time Axis
%% ===========================

t = (0:L-1)/Fs;

%% ===========================
% Mean Squared Error
%% ===========================

mse_matlab = mean((clean_ecg - matlab_output).^2);

mse_hardware = mean((clean_ecg - hardware_output).^2);

%% ===========================
% Root Mean Squared Error
%% ===========================

rmse_matlab = sqrt(mse_matlab);

rmse_hardware = sqrt(mse_hardware);

% Correlation Coefficient

R = corrcoef(clean_ecg,matlab_output);
corr_matlab = R(1,2);

R = corrcoef(clean_ecg,hardware_output);
corr_hardware = R(1,2);

% Display Results

fprintf('\n==============================\n');
fprintf('Comparison Results\n');
fprintf('==============================\n\n');

fprintf('MATLAB Output\n');
fprintf('-------------\n');
fprintf('MSE              = %e\n',mse_matlab);
fprintf('RMSE             = %e\n',rmse_matlab);
fprintf('Correlation      = %.6f\n\n',corr_matlab);

fprintf('Hardware Output\n');
fprintf('---------------\n');
fprintf('MSE              = %e\n',mse_hardware);
fprintf('RMSE             = %e\n',rmse_hardware);
fprintf('Correlation      = %.6f\n',corr_hardware);

% Plot Entire Signals

figure('Color','w');

subplot(3,1,1)
plot(t,clean_ecg,'k')
title('Original Clean ECG')
ylabel('Amplitude')
ylim([-1,2]);
grid on

subplot(3,1,2)
plot(t,matlab_output,'b')
title('MATLAB Filtered ECG')
ylabel('Amplitude')
ylim([-1,2]);
grid on

subplot(3,1,3)
plot(t,hardware_output,'r')
title('DSP Hardware Output')
xlabel('Time (s)')
ylabel('Amplitude')
ylim([-1,2]);
grid on

% Overlay Plot

figure('Color','w');

plot(t,clean_ecg,'k','LineWidth',1.3)
hold on

plot(t,matlab_output,'b')

plot(t,hardware_output,'r')

legend('Clean ECG','MATLAB Output','Hardware Output')

title('Comparison of Clean, MATLAB and DSP Outputs')

xlabel('Time (s)')
ylim([-1,1.5])
ylabel('Amplitude')

grid on

% Zoomed Comparison

N = min(1500,L);

figure('Color','w');

plot(t(1:N),clean_ecg(1:N),'k','LineWidth',1.5)
hold on

plot(t(1:N),matlab_output(1:N),'b')

plot(t(1:N),hardware_output(1:N),'r')

legend('Clean ECG','MATLAB Output','Hardware Output')

title('Zoomed Comparison')

xlabel('Time (s)')
ylabel('Amplitude')

grid on



%% ===========================
% Match Noise Length
%% ===========================

bw = bw(:);

L_noise = min(length(clean_ecg), length(bw));

clean_ecg = clean_ecg(1:L_noise);
matlab_output = matlab_output(1:L_noise);
hardware_output = hardware_output(1:L_noise);
bw = bw(1:L_noise);

% Create noisy ECG
noisy_ecg = clean_ecg + bw;

%% ===========================
% Frequency Spectrum
%% ===========================

NFFT = 2^nextpow2(L_noise);

f = (0:NFFT/2-1)*Fs/NFFT;

% Clean ECG
X_clean = fft(clean_ecg,NFFT);
P_clean = abs(X_clean(1:NFFT/2))/L_noise;

% Baseline Wander Noise
X_noise = fft(bw,NFFT);
P_noise = abs(X_noise(1:NFFT/2))/L_noise;

% Noisy ECG
X_noisy = fft(noisy_ecg,NFFT);
P_noisy = abs(X_noisy(1:NFFT/2))/L_noise;

% MATLAB Filtered ECG
X_filtered = fft(matlab_output,NFFT);
P_filtered = abs(X_filtered(1:NFFT/2))/L_noise;

%% ===========================
% Plot Frequency Spectra
%% ===========================

figure('Color','w');

subplot(4,1,1)
plot(f,P_clean,'k','LineWidth',1.2)
title('Frequency Spectrum of Clean ECG')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')
xlim([0 20])
grid on

subplot(4,1,2)
plot(f,P_noise,'r','LineWidth',1.2)
title('Frequency Spectrum of Baseline Wander Noise')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')
xlim([0 20])
grid on

subplot(4,1,3)
plot(f,P_noisy,'b','LineWidth',1.2)
title('Frequency Spectrum of Noisy ECG')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')
xlim([0 20])
grid on

subplot(4,1,4)
plot(f,P_filtered,'g','LineWidth',1.2)
title('Frequency Spectrum of MATLAB Filtered ECG')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')
xlim([0 20])
grid on

%% ===========================
% SNR Calculation
%% ===========================

% MATLAB Filtered Output
noise_matlab = matlab_output - clean_ecg;

snr_matlab = 10*log10(sum(clean_ecg.^2) / sum(noise_matlab.^2));

% DSP Hardware Output
noise_hardware = hardware_output - clean_ecg;

snr_hardware = 10*log10(sum(clean_ecg.^2) / sum(noise_hardware.^2));

fprintf('SNR              = %.4f dB\n\n',snr_matlab);