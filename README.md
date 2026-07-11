# ECG-Signal-Denoising-using-MATLAB-and-TMS320C6713-DSP
Implemented real-time ECG denoising using FIR and IIR filters for Baseline Wander (BW) and Power Line Interference (PLI) removal. Designed and evaluated filters in MATLAB using SNR and MSE, then deployed the best filters on the TMS320C6713 DSP using Code Composer Studio and validated hardware results against MATLAB.
# ECG Signal Denoising using MATLAB and TMS320C6713 DSP

## Overview

This project presents the design, analysis, and real-time implementation of digital filters for ECG signal denoising. The objective is to remove two common types of noise affecting ECG signals—Baseline Wander (BW) and 50 Hz Power-Line Interference (PLI). The filters were designed and evaluated in MATLAB, and the optimal filters were implemented on the Texas Instruments TMS320C6713 DSP processor for real-time signal processing. The performance of both software and hardware implementations was compared using Signal-to-Noise Ratio (SNR) and Mean Squared Error (MSE).

---

## Features

- ECG signal denoising using FIR and IIR digital filters
- Removal of Baseline Wander (BW) and 50 Hz Power-Line Interference (PLI)
- MATLAB-based filter design and analysis
- Implementation on TMS320C6713 DSP
- Performance evaluation using SNR and MSE
- Comparison of MATLAB and DSP hardware outputs

---

## Filters Implemented

### FIR Filters
- Hamming Window
- Hanning Window
- Rectangular Window
- Blackmann Window

### IIR Filters
- Butterworth
- Chebyshev Type-I
- Chebyshev Type-II

---

## Hardware

- Texas Instruments TMS320C6713 DSK
- USB JTAG Emulator

---

## Software

- MATLAB
- Code Composer Studio (CCS)
- Embedded C

---

## Performance Evaluation

The filtering performance was evaluated using:

- Signal-to-Noise Ratio (SNR)
- Mean Squared Error (MSE)

The best-performing filters were selected for hardware implementation based on these evaluation metrics.

---


## Results

The designed filters effectively reduced baseline wander and power-line interference from ECG signals. The selected filters were successfully implemented on the TMS320C6713 DSP processor for real-time processing. Hardware results were compared with MATLAB simulations, demonstrating comparable denoising performance.

---

## Future Scope

- Adaptive filtering techniques
- FPGA implementation
- Wireless ECG monitoring systems
- AI-assisted ECG analysis
- Real-time biomedical signal processing applications

---

## Skills Demonstrated

- Digital Signal Processing (DSP)
- MATLAB
- Embedded C
- FIR & IIR Filter Design
- Biomedical Signal Processing
- Texas Instruments TMS320C6713 DSP
- Code Composer Studio (CCS)
- Performance Evaluation (SNR & MSE)

---

## Dataset

The ECG signal used in this project was obtained from the **MIT-BIH Arrhythmia Database**.

https://physionet.org/content/mitdb/1.0.0/

---

## Author

**Purre H N S Chandra Shekar**

B.E. Electronics and Communication Engineering  
JNTUH University College of Engineering Sultanpur
