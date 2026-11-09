# Hexacopter Blade Wear Detection & Predictive Maintenance 

[![Platform: MATLAB](https://img.shields.io/badge/Platform-MATLAB-orange.svg)](#tech-stack--tools)
[![Hardware: Pixhawk / DJI F550](https://img.shields.io/badge/UAV-DJI%20F550%20%7C%20Pixhawk%20ArduPilot-blue.svg)](#1-experimental-setup--dataset)
[![Focus: Predictive Maintenance & XAI](https://img.shields.io/badge/Focus-Fault%20Diagnosis%20%26%20XAI-brightgreen.svg)](#5-explainable-ai-xai)

An end-to-end **Predictive Maintenance and Fault Diagnosis** pipeline developed in **MATLAB** to detect and classify propeller blade wear on a hexacopter UAV using onboard flight log telemetry. 

beyond high-accuracy fault classification (up to **94.55%**), this project places a strong emphasis on **Explainable AI (XAI)**, linking black-box and white-box machine learning predictions to physically interpretable aerodynamic and vibrational phenomena.

>  **Full Technical Documentation:** You can read the complete 60-page technical report (in Italian), including spectral plots, confusion matrices, and full decision tree rules, here: **[Rilevamento Usura Pale — Technical Report (PDF)](./Rilevamento_usura_pale_Ricci_Sebastianelli_.pdf)**.

---

## 1. Experimental Setup & Dataset

Flight data were acquired during experimental measurement campaigns at the **LAIR Laboratory** (*Università Politecnica delle Marche - UNIVPM*) using a dedicated UAV platform:
* **Airframe:** DJI F550 Hexacopter
* **Flight Controller:** Pixhawk running a custom high-frequency **ArduPilot** firmware
* **Dataset Structure:** 18 flight logs across 3 operating health conditions:
  * **Class 0 (`NO_FAULT`):** 6 nominal flights with healthy blades.
  * **Class 5 (`FAULT_M_5%`):** 6 flights with minor blade wear (5% blade length cut across motors M1–M6).
  * **Class 10 (`FAULT_M_10%`):** 6 flights with severe blade wear (10% blade length cut across motors M1–M6).

### Monitored Telemetry Variables
36 heterogeneous signals were extracted from 6 ArduPilot log structures:
* **`IMU` (Inertial Measurement Unit — up to 350 Hz):** Tri-axial linear accelerations (`acc_x`, `acc_y`, `acc_z` $[m/s^2]$) and angular velocities (`gyr_x`, `gyr_y`, `gyr_z` $[rad/s]$).
* **`PWM` (Motor Commands):** Control effort signals sent by the autopilot to motors 1–6 (`pwm_1` ... `pwm_6`).
* **`ESC` (Electronic Speed Controllers):** Motor rotational speeds (`esc_1` ... `esc_6` $[RPM]$) and absorbed currents (`cur_1` ... `cur_6` $[A]$).
* **`ATTITUDE`:** Actual vs. desired Euler angles (`roll`, `pitch`, `yaw` and `roll_des`, `pitch_des`, `yaw_des` $[deg]$).
* **`XKF1` (Extended Kalman Filter):** Estimated NED linear velocities (`vn`, `ve`, `vd` $[m/s]$).
* **`VIBE`:** Pre-filtered onboard vibration metrics along the three axes (`vibe_x`, `vibe_y`, `vibe_z`).

---

##  2. Signal Pre-Processing & Feature Engineering
[Raw ArduPilot Logs] ──> [350 Hz ZOH Sync] ──> [1s Frame Windowing] ──> [Time & PSD Features] ──> [ANOVA vs. Kruskal-Wallis] ──> [ML & XAI]

1. **Temporal Synchronization (`timetable`):** Because onboard sensors sample at different asynchronous rates, all signals were resampled to a common high-frequency base of **$F_s = 350\text{ Hz}$** using **Zero-Order Hold (`zero_order_hold`)** interpolation to preserve discrete control states (PWM) and prevent artificial aliasing on raw IMU vibrations.
2. **Frame Policy Segmentation:** Continuous flight logs were segmented into non-overlapping **1-second windows (350 samples/frame)**, balancing spectral resolution with local signal stationarity.
3. **Feature Extraction (*Diagnostic Feature Designer*):**
   * **Time-Domain Features (All Signals):** `Mean`, `Std`, `RMS`, `PeakValue`, `CrestFactor`, `ShapeFactor`, `ImpulseFactor`, `Kurtosis`, `Skewness`, and `ClearanceFactor` (specifically sensitive to rotating machinery faults).
   * **Frequency-Domain Features (High-Frequency IMU Signals):** Power Spectral Density (PSD) estimated via **Welch's Method** (resonances concentrated between $10\text{ Hz}$ and $100\text{ Hz}$). Extracted the top 2 most energetic spectral peaks (`PeakAmp1`, `PeakAmp2`, `PeakFreq1`, `PeakFreq2`) and total `BandPower`.
4. **Statistical Feature Selection (Top 20 Features):**
   * **Parametric Set:** Ranked via **One-Way ANOVA** ($F$-score, mean comparison).
   * **Non-Parametric Set:** Ranked via **Kruskal-Wallis** ($\chi^2$ statistic, median comparison, robust to non-Gaussian distributions and outliers).

---

## 3. Classification & Experimental Results

Five supervised classifiers were evaluated under a **10-Split Stratified Repeated Holdout (90% Train / 10% Test)** cross-validation protocol across two scenarios:
* **Binary Scenario (Fault Detection):** Healthy (`0`) vs. Damaged (`1`).
* **Multi-Class Scenario (Severity Diagnosis):** Healthy (`0`) vs. 5% Wear (`5`) vs. 10% Wear (`10`).

### Performance Comparison (Mean Accuracy $\pm$ Std Dev across 10 Splits)

| Classifier | Scenario | One-Way ANOVA (Top 20) | Kruskal-Wallis (Top 20) |
| :--- | :---: | :---: | :---: |
| **Neural Network (NN)** | **2 Classes**<br>3 Classes | 94.47% ± 2.08%<br>91.29% ± 3.47% | **94.55% ± 1.51%**<br>**91.82% ± 2.57%** |
| **Random Forest (RF)** | **2 Classes**<br>3 Classes | 94.24% ± 1.64%<br>91.74% ± 2.21% | **94.55% ± 1.46%**<br>91.74% ± 2.59% |
| **Support Vector Machine (SVM)** | **2 Classes**<br>3 Classes | 91.74% ± 2.20%<br>90.68% ± 3.68% | 94.32% ± 1.39%<br>91.74% ± 1.69% |
| **K-Nearest Neighbors (KNN, $K=10$)** | **2 Classes**<br>3 Classes | 92.80% ± 2.32%<br>90.68% ± 2.48% | 93.18% ± 1.68%<br>88.79% ± 2.52% |
| **Decision Tree (DT)** | **2 Classes**<br>3 Classes | 92.20% ± 1.60%<br>85.98% ± 2.93% | 92.58% ± 2.20%<br>86.89% ± 3.01% |

> **Key Takeaway:** Features selected via the non-parametric **Kruskal-Wallis** test consistently outperformed or matched ANOVA while significantly **reducing variance (Std Dev)** across splits—demonstrating superior robustness against real-world flight noise and outliers.

---

## 4. Explainable AI (XAI) for Maintenance Decision Support

In safety-critical UAV maintenance, black-box alarms are insufficient. Dedicated XAI techniques were implemented for each model architecture to extract physical insights:

* **Decision Tree — Direct Rule Extraction:** Exported explicit `if-then-else` navigation tables showing how root splits rely heavily on `vibe_y/PeakValue`, `vibe_x/PeakValue`, and `vibe_y/RMS`.
* **Neural Network — Global Surrogate Decision Tree:** Trained a post-hoc white-box surrogate tree to approximate the black-box Neural Network predictions, achieving **97.82% fidelity** (121 nodes) and making the NN decision boundaries fully auditable.
* **Random Forest — Out-Of-Bag (OOB) & Local Gini Importance:** Analyzed global feature permutation and local node-level Gini decrease across individual trees (`Tree A` and `Tree B`), highlighting the interplay between vibration energy (`vibe_x`, `vibe_y`) and autopilot compensation (`pwm_5`, `pwm_1`).
* **SVM — Permutation Feature Importance:** Quantified accuracy drop under feature shuffling for the non-linear polynomial kernel SVM.
* **KNN — Local Neighborhood & Euclidean Distance Case Study:** Inspected nearest training flights and feature-wise distance contributions (`ClearanceFactor`, `ImpulseFactor`, `PeakAmp2`) for local anomaly justification.

---

## Tech Stack & Tools

* **Environment:** MATLAB
* **Toolboxes:** Predictive Maintenance Toolbox (*Diagnostic Feature Designer*), Statistics and Machine Learning Toolbox (*Classification Learner*)
* **Flight Stack:** ArduPilot / Pixhawk Telemetry Logs

---

## Authors & Academic Context

Developed for the **Preventive Maintenance** (*Manutenzione Preventiva*) course — M.Sc. in **Computer and Automation Engineering** at **Università Politecnica delle Marche (UNIVPM)**, A.Y. 2025–2026, under the supervision of **Prof. Alessandro Freddi**.

* **Nicola Sebastianelli** — [GitHub](https://github.com/Sebastianelli-Nicola)
* **Ettore Ricci** — [Github](https://github.com/EttoreRii)
