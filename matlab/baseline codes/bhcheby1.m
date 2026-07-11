clc;
clear all;
close all;

% 1. LOAD CLEAN ECG SIGNAL

ecg_folder = 'C:\Users\P CHANDU\OneDrive\Desktop\mit-bih-arrhythmia-database-1.0.0';

ecg_data = load(fullfile(ecg_folder,'100.mat'));                                                                                                                                                                                                                                                                                                                                                                                                                                                      
9=                              vb


ecg_clean = ecg_data.signal(:,1);

Fs = double(ecg_data.Fs);

% 2. LOAD BASELINE WANDER NOISE                

bw_folder = 'C:\Users\P CHANDU\OneDrive\Desktop\mit-bih-noise-stress-test-database-1.0.0\old';

bw_data = load(fullfile(bw_folder,'oldbw.mat'));

bw = bw_data.signal(:,1);

L = min(length(ecg_clean),length(bw));

ecg_clean = ecg_clean(1:L);
bw = bw(1:L);

% 4. ADD BASELINE WANDER TO ECG

ecg_noisy = ecg_clean + bw;

t = (0:L-1)/Fs;

N = 3000;

figure;

subplot(3,1,1);
plot(t(1:N),ecg_clean(1:N));
title('Clean ECG Signal');
ylabel('Amplitude');
grid on;

subplot(3,1,2);
plot(t(1:N),bw(1:N));
title('Baseline Wander Noise');
ylabel('Amplitude');
grid on;

subplot(3,1,3);
plot(t(1:N),ecg_noisy(1:N));
title('ECG with Baseline Wander');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% 7. FFT ANALYSIS

Nfft = length(ecg_noisy);

ECG_FFT = fft(ecg_clean);
BW_FFT = fft(bw);
NOISY_FFT = fft(ecg_noisy);

f = (0:Nfft-1)*(Fs/Nfft);

ECG_mag = abs(ECG_FFT)/Nfft;
BW_mag = abs(BW_FFT)/Nfft;
NOISY_mag = abs(NOISY_FFT)/Nfft;

% 8. PLOT FFTS

figure;

subplot(3,1,1);
plot(f,ECG_mag);
title('FFT of Clean ECG');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 0.5]);
ylim([0 0.5]);
grid on;

subplot(3,1,2);
plot(f,BW_mag);
title('FFT of Baseline Wander');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 0.5]);
ylim([0 0.5]);
grid on;

subplot(3,1,3);
plot(f,NOISY_mag);
title('FFT of Noisy ECG');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 0.5]);
ylim([0 0.5]);
grid on;

% 9. CHEBYSHEV TYPE-I HIGH PASS FILTER DESIGN

order = 6;

Rp = 0.5;

fc = 0.5;

Wn = fc/(Fs/2);

[z,p,k] = cheby1(order,Rp,Wn,'high');

[sos,g] = zp2sos(z,p,k);

[b,a] = zp2tf(z,p,k);

disp(' ');
disp('Chebyshev Type-I Coefficients');

disp('Numerator Coefficients (b)');
disp(b);

disp('Denominator Coefficients (a)');
disp(a);

disp('SOS Matrix');
disp(sos);

disp('Overall Gain');
disp(g);

% 11. FREQUENCY RESPONSE

figure;

freqz(sos,1024,Fs);

title(['Chebyshev Type-I HPF (Order=',...
       num2str(order),...
       ', Rp=',num2str(Rp),' dB)']);

ecg_filtered = filtfilt(sos,g,ecg_noisy);

figure;

subplot(3,1,1);
plot(t(1:N),ecg_clean(1:N));
title('Original Clean ECG');
ylabel('Amplitude');
grid on;

subplot(3,1,2);
plot(t(1:N),ecg_noisy(1:N));
title('Noisy ECG');
ylabel('Amplitude');
grid on;

subplot(3,1,3);
plot(t(1:N),ecg_filtered(1:N));
title('Filtered ECG');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% 14. FFT OF FILTERED ECG

FILTERED_FFT = fft(ecg_filtered);

FILTERED_mag = abs(FILTERED_FFT)/Nfft;

figure;

plot(f,FILTERED_mag);

title('FFT of Filtered ECG');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

xlim([0 50]);
grid on;

% 15. PSD ANALYSIS

figure;
pwelch(ecg_noisy,[],[],[],Fs);
title('PSD of Noisy ECG');

figure;
pwelch(ecg_filtered,[],[],[],Fs);
title('PSD of Filtered ECG');




% 17. AVERAGE POWER

power_clean = mean(ecg_clean.^2);

power_noisy = mean(ecg_noisy.^2);

power_filtered = mean(ecg_filtered.^2);

disp(' ');
disp('POWER RESULTS');

disp(['Average Power of Clean ECG = ',...
      num2str(power_clean)]);

disp(['Average Power of Noisy ECG = ',...
      num2str(power_noisy)]);

disp(['Average Power of Filtered ECG = ',...
      num2str(power_filtered)]);


mse_value = mean((ecg_clean - ecg_filtered).^2);

rmse_value = sqrt(mse_value);

disp(['MSE = ', num2str(mse_value)]);
disp(['RMSE = ', num2str(rmse_value)]);

%% ---------------- SNR Calculation ----------------

% -------- Input SNR (Before Filtering) --------

% Power of clean ECG
signal_power = mean(ecg_clean.^2);

% Power of added Baseline Wander noise
noise_power = mean(bw.^2);

% Input SNR
snr_before = 10*log10(signal_power / noise_power);

fprintf('\n========== SNR RESULTS ==========\n');
fprintf('Signal Power                = %.6f\n', signal_power);
fprintf('Baseline Wander Power       = %.6f\n', noise_power);
fprintf('Input SNR                   = %.4f dB\n', snr_before);


% -------- Output SNR (After Filtering) --------

% Residual noise/error remaining after filtering
residual_noise = ecg_filtered - ecg_clean;

% Residual noise power
residual_noise_power = mean(residual_noise.^2);

% Output SNR
snr_after = 10*log10(signal_power / residual_noise_power);

fprintf('\nResidual Noise Power        = %.6f\n', residual_noise_power);
fprintf('Output SNR                 = %.4f dB\n', snr_after);
fprintf('SNR Improvement            = %.4f dB\n', snr_after - snr_before);
