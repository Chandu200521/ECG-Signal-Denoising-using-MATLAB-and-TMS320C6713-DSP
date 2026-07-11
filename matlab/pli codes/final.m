clc;
clear all;
close all;

%% ==========================================================
% Load Original Clean ECG
%% ==========================================================

ecg_folder = 'C:\Users\P CHANDU\OneDrive\Desktop\mit-bih-arrhythmia-database-1.0.0';
data = load(fullfile(ecg_folder,'100.mat'));

clean_ecg = data.signal(:,1);
Fs = double(data.Fs);

%% ==========================================================
% Load Hardware Output
%% ==========================================================

output_folder = 'C:\Users\P CHANDU\OneDrive\Desktop\outputs';

data1 = load(fullfile(output_folder,'ecg_output_hanning2.mat'));

varName = fieldnames(data1);
hardware_output = data1.(varName{1});

%% ==========================================================
% Load MATLAB Software Output
%% ==========================================================

data2 = load(fullfile(output_folder,'filtered_ecg.mat'));

varName = fieldnames(data2);
software_output = data2.(varName{1});

%% ==========================================================
% Load PLI Noise
%% ==========================================================

pli_folder = 'C:\Users\P CHANDU\OneDrive\Desktop\mit-bih-noise-stress-test-database-1.0.0\old';

pli = load(fullfile(pli_folder,'pli_noise_only.mat'));

varName = fieldnames(pli);
pli_noise = pli.(varName{1});

%% ==========================================================
% Convert to Column Vectors
%% ==========================================================

clean_ecg       = clean_ecg(:);
software_output = software_output(:);
hardware_output = hardware_output(:);
pli_noise       = pli_noise(:);

%% ==========================================================
% Match Lengths
%% ==========================================================

L = min([length(clean_ecg),...
         length(software_output),...
         length(hardware_output),...
         length(pli_noise)]);

clean_ecg       = clean_ecg(1:L);
software_output = software_output(1:L);
hardware_output = hardware_output(1:L);
pli_noise       = pli_noise(1:L);

clean_ecg=clean_ecg-(mean(clean_ecg));
hardware_output=hardware_output-(mean(hardware_output));
%normalize
%=========================
clean_ecg= clean_ecg/ max(abs(clean_ecg));
software_output= software_output/ max(abs(software_output));

pli_noise= pli_noise/ max(abs(pli_noise));

t = (0:L-1)/Fs;

%% ==========================================================
% MSE
%% ==========================================================

mse_sw = mean((clean_ecg-software_output).^2);
mse_hw = mean((clean_ecg-hardware_output).^2);

%% ==========================================================
% RMSE
%% ==========================================================

rmse_sw = sqrt(mse_sw);
rmse_hw = sqrt(mse_hw);


%% ==========================================================
% Correlation
%% ==========================================================

R = corrcoef(clean_ecg,software_output);
corr_sw = R(1,2);

R = corrcoef(clean_ecg,hardware_output);
corr_hw = R(1,2);

%% ==========================================================
% Display Results
%% ==========================================================

fprintf('\n===========================================\n');
fprintf('          PERFORMANCE METRICS\n');
fprintf('===========================================\n\n');

fprintf('MATLAB SOFTWARE OUTPUT\n');
fprintf('----------------------\n');
fprintf('MSE          : %e\n',mse_sw);
fprintf('RMSE         : %e\n',rmse_sw);
fprintf('Correlation  : %.6f\n\n',corr_sw);

fprintf('DSP HARDWARE OUTPUT\n');
fprintf('-------------------\n');
fprintf('MSE          : %e\n',mse_hw);
fprintf('RMSE         : %e\n',rmse_hw);

fprintf('Correlation  : %.6f\n',corr_hw);

%% ==========================================================
% Individual Signals
%% ==========================================================

figure('Color','w');

subplot(3,1,1)
plot(t,clean_ecg)
title('Original Clean ECG')
ylabel('Amplitude')
grid on

subplot(3,1,2)
plot(t,software_output)
title('MATLAB Filtered ECG')
ylabel('Amplitude')
grid on

subplot(3,1,3)
plot(t,hardware_output)
title('DSP Hardware Output')
xlabel('Time (s)')
ylabel('Amplitude')
ylim([-0.5 1]);
xlim([0 3])
grid on

%% ==========================================================
% Overlay Comparison
%% ==========================================================

figure('Color','w');

plot(t,clean_ecg,'k','LineWidth',1.5)
hold on
plot(t,software_output,'b')
plot(t-0.29,3.3*hardware_output,'r')
ylim([-1,1]);

legend('Clean ECG','MATLAB Output','DSP Output')

title('Comparison of ECG Signals')

xlabel('Time (s)')
ylabel('Amplitude')
grid on

%% ==========================================================
% Zoomed Comparison
%% ==========================================================

N = min(1500,L);

figure('Color','w');

plot(t(1:N),clean_ecg(1:N),'k','LineWidth',1.5)
hold on
plot(t(1:N),software_output(1:N),'b')
plot(t(1:N),hardware_output(1:N),'r')

legend('Clean ECG','MATLAB Output','DSP Output')

title('Zoomed Comparison')

xlabel('Time (s)')
ylabel('Amplitude')
grid on;

%% ==========================================================
% PLI Noise Signal
%% ==========================================================

figure('Color','w');

plot(t,pli_noise)

title('Power Line Interference (PLI) Noise')

xlabel('Time (s)')
ylabel('Amplitude')

grid on

%% ==========================================================
% Frequency Spectrum Analysis (FFT)
%% ==========================================================

% FFT Length
NFFT = 2^nextpow2(L);

% Frequency Axis
f = Fs*(0:(NFFT/2))/NFFT;

% ----- Clean ECG -----
X_clean = fft(clean_ecg,NFFT);
P_clean = abs(X_clean/NFFT);
P_clean = P_clean(1:NFFT/2+1);
P_clean(2:end-1) = 2*P_clean(2:end-1);

% ----- MATLAB Output -----
X_sw = fft(software_output,NFFT);
P_sw = abs(X_sw/NFFT);
P_sw = P_sw(1:NFFT/2+1);
P_sw(2:end-1) = 2*P_sw(2:end-1);

% ----- DSP Hardware Output -----
X_hw = fft(hardware_output,NFFT);
P_hw = abs(X_hw/NFFT);
P_hw = P_hw(1:NFFT/2+1);
P_hw(2:end-1) = 2*P_hw(2:end-1);

% ----- PLI Noise -----
X_pli = fft(pli_noise,NFFT);
P_pli = abs(X_pli/NFFT);
P_pli = P_pli(1:NFFT/2+1);
P_pli(2:end-1) = 2*P_pli(2:end-1);

% Plot Frequency Spectra

figure('Color','w');

subplot(4,1,1)
plot(f,P_clean,'k','LineWidth',1)
title('Frequency Spectrum of Original Clean ECG')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 Fs/2])
grid on

subplot(4,1,2)
plot(f,P_sw,'b','LineWidth',1)
title('Frequency Spectrum of MATLAB Filtered ECG')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 Fs/2])
grid on

subplot(4,1,3)
plot(f,P_hw,'r','LineWidth',1)
title('Frequency Spectrum of DSP Hardware Output')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 Fs/2])
grid on

%% ==========================================================
% Frequency Spectrum Analysis (FFT)
%% ==========================================================

% FFT Length
NFFT = 2^nextpow2(L);

% Frequency Axis
f = Fs*(0:(NFFT/2))/NFFT;

% ----- Clean ECG -----
X_clean = fft(clean_ecg,NFFT);
P_clean = abs(X_clean/NFFT);
P_clean = P_clean(1:NFFT/2+1);
P_clean(2:end-1) = 2*P_clean(2:end-1);

% ----- MATLAB Output -----
X_sw = fft(software_output,NFFT);
P_sw = abs(X_sw/NFFT);
P_sw = P_sw(1:NFFT/2+1);
P_sw(2:end-1) = 2*P_sw(2:end-1);

% ----- DSP Hardware Output -----
X_hw = fft(hardware_output,NFFT);
P_hw = abs(X_hw/NFFT);
P_hw = P_hw(1:NFFT/2+1);
P_hw(2:end-1) = 2*P_hw(2:end-1);

% ----- PLI Noise -----
X_pli = fft(pli_noise,NFFT);
P_pli = abs(X_pli/NFFT);
P_pli = P_pli(1:NFFT/2+1);
P_pli(2:end-1) = 2*P_pli(2:end-1);

%% ==========================================================
% Plot Frequency Spectra
%% ==========================================================

figure('Color','w');

subplot(4,1,1)
plot(f,P_clean,'k','LineWidth',1)
title('Frequency Spectrum of Original Clean ECG')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 Fs/2])
grid on

subplot(4,1,2)
plot(f,P_sw,'b','LineWidth',1)
title('Frequency Spectrum of MATLAB Filtered ECG')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 Fs/2])
grid on

subplot(4,1,3)
plot(f,P_hw,'r','LineWidth',1)
title('Frequency Spectrum of DSP Hardware Output')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 Fs/2])
grid on

subplot(4,1,4)
plot(f,P_pli,'m','LineWidth',1)
title('Frequency Spectrum of PLI Noise')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 Fs/2])
grid on


noisy_ecg = clean_ecg + pli_noise;


NFFT = 2^nextpow2(L);
f = Fs*(0:(NFFT/2))/NFFT;

X_noisy = fft(noisy_ecg, NFFT);

P_noisy = abs(X_noisy/NFFT);
P_noisy = P_noisy(1:NFFT/2+1);
P_noisy(2:end-1) = 2*P_noisy(2:end-1);

figure('Color','w');

plot(f, P_noisy,'LineWidth',1.5)
title('Frequency Spectrum of Noisy ECG (Clean ECG + PLI)')
xlabel('Frequency (Hz)')
ylabel('Magnitude')
xlim([0 Fs/2])
grid on

%% ==========================================================
% SNR Calculation
%% ==========================================================

% MATLAB Software Output
noise_sw = software_output - clean_ecg;
snr_sw = 10*log10(sum(clean_ecg.^2)/sum(noise_sw.^2));

% DSP Hardware Output
noise_hw = hardware_output - clean_ecg;
snr_hw = 10*log10(sum(clean_ecg.^2)/sum(noise_hw.^2));

fprintf('\n===========================================\n');
fprintf('          PERFORMANCE METRICS\n');
fprintf('===========================================\n\n');

fprintf('MATLAB SOFTWARE OUTPUT\n');
fprintf('----------------------\n');
fprintf('MSE          : %e\n',mse_sw);
fprintf('RMSE         : %e\n',rmse_sw);
fprintf('Correlation  : %.6f\n',corr_sw);
fprintf('SNR          : %.4f dB\n\n',snr_sw);

fprintf('DSP HARDWARE OUTPUT\n');
fprintf('-------------------\n');
fprintf('MSE          : %e\n',mse_hw);
fprintf('RMSE         : %e\n',rmse_hw);
fprintf('Correlation  : %.6f\n',corr_hw);
fprintf('SNR          : %.4f dB\n',snr_hw);