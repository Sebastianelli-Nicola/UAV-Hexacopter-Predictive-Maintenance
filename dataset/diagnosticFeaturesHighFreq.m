function [featureTable,outputTable] = diagnosticFeaturesHighFreq(inputData)
%DIAGNOSTICFEATURES recreates results in Diagnostic Feature Designer.
%
% Input:
%  inputData: A table or a cell array of tables/matrices containing the
%  data as those imported into the app.
%
% Output:
%  featureTable: A table containing all features and condition variables.
%  outputTable: A table containing the computation results.
%
% This function computes spectra:
%  acc_x_ps/SpectrumData
%  acc_y_ps/SpectrumData
%  acc_z_ps/SpectrumData
%  gyr_x_ps/SpectrumData
%  gyr_y_ps/SpectrumData
%  gyr_z_ps/SpectrumData
%
% This function computes features:
%  acc_x_sigstats/ClearanceFactor
%  acc_x_sigstats/CrestFactor
%  acc_x_sigstats/ImpulseFactor
%  acc_x_sigstats/Kurtosis
%  acc_x_sigstats/Mean
%  acc_x_sigstats/PeakValue
%  acc_x_sigstats/RMS
%  acc_x_sigstats/SINAD
%  acc_x_sigstats/SNR
%  acc_x_sigstats/ShapeFactor
%  acc_x_sigstats/Skewness
%  acc_x_sigstats/Std
%  acc_x_sigstats/THD
%  acc_y_sigstats/ClearanceFactor
%  acc_y_sigstats/CrestFactor
%  acc_y_sigstats/ImpulseFactor
%  acc_y_sigstats/Kurtosis
%  acc_y_sigstats/Mean
%  acc_y_sigstats/PeakValue
%  acc_y_sigstats/RMS
%  acc_y_sigstats/SINAD
%  acc_y_sigstats/SNR
%  acc_y_sigstats/ShapeFactor
%  acc_y_sigstats/Skewness
%  acc_y_sigstats/Std
%  acc_y_sigstats/THD
%  acc_z_sigstats/ClearanceFactor
%  acc_z_sigstats/CrestFactor
%  acc_z_sigstats/ImpulseFactor
%  acc_z_sigstats/Kurtosis
%  acc_z_sigstats/Mean
%  acc_z_sigstats/PeakValue
%  acc_z_sigstats/RMS
%  acc_z_sigstats/SINAD
%  acc_z_sigstats/SNR
%  acc_z_sigstats/ShapeFactor
%  acc_z_sigstats/Skewness
%  acc_z_sigstats/Std
%  acc_z_sigstats/THD
%  gyr_x_sigstats/ClearanceFactor
%  gyr_x_sigstats/CrestFactor
%  gyr_x_sigstats/ImpulseFactor
%  gyr_x_sigstats/Kurtosis
%  gyr_x_sigstats/Mean
%  gyr_x_sigstats/PeakValue
%  gyr_x_sigstats/RMS
%  gyr_x_sigstats/SINAD
%  gyr_x_sigstats/SNR
%  gyr_x_sigstats/ShapeFactor
%  gyr_x_sigstats/Skewness
%  gyr_x_sigstats/Std
%  gyr_x_sigstats/THD
%  gyr_y_sigstats/ClearanceFactor
%  gyr_y_sigstats/CrestFactor
%  gyr_y_sigstats/ImpulseFactor
%  gyr_y_sigstats/Kurtosis
%  gyr_y_sigstats/Mean
%  gyr_y_sigstats/PeakValue
%  gyr_y_sigstats/RMS
%  gyr_y_sigstats/SINAD
%  gyr_y_sigstats/SNR
%  gyr_y_sigstats/ShapeFactor
%  gyr_y_sigstats/Skewness
%  gyr_y_sigstats/Std
%  gyr_y_sigstats/THD
%  gyr_z_sigstats/ClearanceFactor
%  gyr_z_sigstats/CrestFactor
%  gyr_z_sigstats/ImpulseFactor
%  gyr_z_sigstats/Kurtosis
%  gyr_z_sigstats/Mean
%  gyr_z_sigstats/PeakValue
%  gyr_z_sigstats/RMS
%  gyr_z_sigstats/SINAD
%  gyr_z_sigstats/SNR
%  gyr_z_sigstats/ShapeFactor
%  gyr_z_sigstats/Skewness
%  gyr_z_sigstats/Std
%  gyr_z_sigstats/THD
%  pwm_1_sigstats/ClearanceFactor
%  pwm_1_sigstats/CrestFactor
%  pwm_1_sigstats/ImpulseFactor
%  pwm_1_sigstats/Kurtosis
%  pwm_1_sigstats/Mean
%  pwm_1_sigstats/PeakValue
%  pwm_1_sigstats/RMS
%  pwm_1_sigstats/SINAD
%  pwm_1_sigstats/SNR
%  pwm_1_sigstats/ShapeFactor
%  pwm_1_sigstats/Skewness
%  pwm_1_sigstats/Std
%  pwm_1_sigstats/THD
%  pwm_2_sigstats/ClearanceFactor
%  pwm_2_sigstats/CrestFactor
%  pwm_2_sigstats/ImpulseFactor
%  pwm_2_sigstats/Kurtosis
%  pwm_2_sigstats/Mean
%  pwm_2_sigstats/PeakValue
%  pwm_2_sigstats/RMS
%  pwm_2_sigstats/SINAD
%  pwm_2_sigstats/SNR
%  pwm_2_sigstats/ShapeFactor
%  pwm_2_sigstats/Skewness
%  pwm_2_sigstats/Std
%  pwm_2_sigstats/THD
%  pwm_3_sigstats/ClearanceFactor
%  pwm_3_sigstats/CrestFactor
%  pwm_3_sigstats/ImpulseFactor
%  pwm_3_sigstats/Kurtosis
%  pwm_3_sigstats/Mean
%  pwm_3_sigstats/PeakValue
%  pwm_3_sigstats/RMS
%  pwm_3_sigstats/SINAD
%  pwm_3_sigstats/SNR
%  pwm_3_sigstats/ShapeFactor
%  pwm_3_sigstats/Skewness
%  pwm_3_sigstats/Std
%  pwm_3_sigstats/THD
%  pwm_4_sigstats/ClearanceFactor
%  pwm_4_sigstats/CrestFactor
%  pwm_4_sigstats/ImpulseFactor
%  pwm_4_sigstats/Kurtosis
%  pwm_4_sigstats/Mean
%  pwm_4_sigstats/PeakValue
%  pwm_4_sigstats/RMS
%  pwm_4_sigstats/SINAD
%  pwm_4_sigstats/SNR
%  pwm_4_sigstats/ShapeFactor
%  pwm_4_sigstats/Skewness
%  pwm_4_sigstats/Std
%  pwm_4_sigstats/THD
%  pwm_5_sigstats/ClearanceFactor
%  pwm_5_sigstats/CrestFactor
%  pwm_5_sigstats/ImpulseFactor
%  pwm_5_sigstats/Kurtosis
%  pwm_5_sigstats/Mean
%  pwm_5_sigstats/PeakValue
%  pwm_5_sigstats/RMS
%  pwm_5_sigstats/SINAD
%  pwm_5_sigstats/SNR
%  pwm_5_sigstats/ShapeFactor
%  pwm_5_sigstats/Skewness
%  pwm_5_sigstats/Std
%  pwm_5_sigstats/THD
%  pwm_6_sigstats/ClearanceFactor
%  pwm_6_sigstats/CrestFactor
%  pwm_6_sigstats/ImpulseFactor
%  pwm_6_sigstats/Kurtosis
%  pwm_6_sigstats/Mean
%  pwm_6_sigstats/PeakValue
%  pwm_6_sigstats/RMS
%  pwm_6_sigstats/SINAD
%  pwm_6_sigstats/SNR
%  pwm_6_sigstats/ShapeFactor
%  pwm_6_sigstats/Skewness
%  pwm_6_sigstats/Std
%  pwm_6_sigstats/THD
%  esc_1_sigstats/ClearanceFactor
%  esc_1_sigstats/CrestFactor
%  esc_1_sigstats/ImpulseFactor
%  esc_1_sigstats/Kurtosis
%  esc_1_sigstats/Mean
%  esc_1_sigstats/PeakValue
%  esc_1_sigstats/RMS
%  esc_1_sigstats/SINAD
%  esc_1_sigstats/SNR
%  esc_1_sigstats/ShapeFactor
%  esc_1_sigstats/Skewness
%  esc_1_sigstats/Std
%  esc_1_sigstats/THD
%  esc_2_sigstats/ClearanceFactor
%  esc_2_sigstats/CrestFactor
%  esc_2_sigstats/ImpulseFactor
%  esc_2_sigstats/Kurtosis
%  esc_2_sigstats/Mean
%  esc_2_sigstats/PeakValue
%  esc_2_sigstats/RMS
%  esc_2_sigstats/SINAD
%  esc_2_sigstats/SNR
%  esc_2_sigstats/ShapeFactor
%  esc_2_sigstats/Skewness
%  esc_2_sigstats/Std
%  esc_2_sigstats/THD
%  esc_3_sigstats/ClearanceFactor
%  esc_3_sigstats/CrestFactor
%  esc_3_sigstats/ImpulseFactor
%  esc_3_sigstats/Kurtosis
%  esc_3_sigstats/Mean
%  esc_3_sigstats/PeakValue
%  esc_3_sigstats/RMS
%  esc_3_sigstats/SINAD
%  esc_3_sigstats/SNR
%  esc_3_sigstats/ShapeFactor
%  esc_3_sigstats/Skewness
%  esc_3_sigstats/Std
%  esc_3_sigstats/THD
%  esc_4_sigstats/ClearanceFactor
%  esc_4_sigstats/CrestFactor
%  esc_4_sigstats/ImpulseFactor
%  esc_4_sigstats/Kurtosis
%  esc_4_sigstats/Mean
%  esc_4_sigstats/PeakValue
%  esc_4_sigstats/RMS
%  esc_4_sigstats/SINAD
%  esc_4_sigstats/SNR
%  esc_4_sigstats/ShapeFactor
%  esc_4_sigstats/Skewness
%  esc_4_sigstats/Std
%  esc_4_sigstats/THD
%  esc_5_sigstats/ClearanceFactor
%  esc_5_sigstats/CrestFactor
%  esc_5_sigstats/ImpulseFactor
%  esc_5_sigstats/Kurtosis
%  esc_5_sigstats/Mean
%  esc_5_sigstats/PeakValue
%  esc_5_sigstats/RMS
%  esc_5_sigstats/SINAD
%  esc_5_sigstats/SNR
%  esc_5_sigstats/ShapeFactor
%  esc_5_sigstats/Skewness
%  esc_5_sigstats/Std
%  esc_5_sigstats/THD
%  esc_6_sigstats/ClearanceFactor
%  esc_6_sigstats/CrestFactor
%  esc_6_sigstats/ImpulseFactor
%  esc_6_sigstats/Kurtosis
%  esc_6_sigstats/Mean
%  esc_6_sigstats/PeakValue
%  esc_6_sigstats/RMS
%  esc_6_sigstats/SINAD
%  esc_6_sigstats/SNR
%  esc_6_sigstats/ShapeFactor
%  esc_6_sigstats/Skewness
%  esc_6_sigstats/Std
%  esc_6_sigstats/THD
%  cur_1_sigstats/ClearanceFactor
%  cur_1_sigstats/CrestFactor
%  cur_1_sigstats/ImpulseFactor
%  cur_1_sigstats/Kurtosis
%  cur_1_sigstats/Mean
%  cur_1_sigstats/PeakValue
%  cur_1_sigstats/RMS
%  cur_1_sigstats/SINAD
%  cur_1_sigstats/SNR
%  cur_1_sigstats/ShapeFactor
%  cur_1_sigstats/Skewness
%  cur_1_sigstats/Std
%  cur_1_sigstats/THD
%  cur_2_sigstats/ClearanceFactor
%  cur_2_sigstats/CrestFactor
%  cur_2_sigstats/ImpulseFactor
%  cur_2_sigstats/Kurtosis
%  cur_2_sigstats/Mean
%  cur_2_sigstats/PeakValue
%  cur_2_sigstats/RMS
%  cur_2_sigstats/SINAD
%  cur_2_sigstats/SNR
%  cur_2_sigstats/ShapeFactor
%  cur_2_sigstats/Skewness
%  cur_2_sigstats/Std
%  cur_2_sigstats/THD
%  cur_3_sigstats/ClearanceFactor
%  cur_3_sigstats/CrestFactor
%  cur_3_sigstats/ImpulseFactor
%  cur_3_sigstats/Kurtosis
%  cur_3_sigstats/Mean
%  cur_3_sigstats/PeakValue
%  cur_3_sigstats/RMS
%  cur_3_sigstats/SINAD
%  cur_3_sigstats/SNR
%  cur_3_sigstats/ShapeFactor
%  cur_3_sigstats/Skewness
%  cur_3_sigstats/Std
%  cur_3_sigstats/THD
%  cur_4_sigstats/ClearanceFactor
%  cur_4_sigstats/CrestFactor
%  cur_4_sigstats/ImpulseFactor
%  cur_4_sigstats/Kurtosis
%  cur_4_sigstats/Mean
%  cur_4_sigstats/PeakValue
%  cur_4_sigstats/RMS
%  cur_4_sigstats/SINAD
%  cur_4_sigstats/SNR
%  cur_4_sigstats/ShapeFactor
%  cur_4_sigstats/Skewness
%  cur_4_sigstats/Std
%  cur_4_sigstats/THD
%  cur_5_sigstats/ClearanceFactor
%  cur_5_sigstats/CrestFactor
%  cur_5_sigstats/ImpulseFactor
%  cur_5_sigstats/Kurtosis
%  cur_5_sigstats/Mean
%  cur_5_sigstats/PeakValue
%  cur_5_sigstats/RMS
%  cur_5_sigstats/SINAD
%  cur_5_sigstats/SNR
%  cur_5_sigstats/ShapeFactor
%  cur_5_sigstats/Skewness
%  cur_5_sigstats/Std
%  cur_5_sigstats/THD
%  cur_6_sigstats/ClearanceFactor
%  cur_6_sigstats/CrestFactor
%  cur_6_sigstats/ImpulseFactor
%  cur_6_sigstats/Kurtosis
%  cur_6_sigstats/Mean
%  cur_6_sigstats/PeakValue
%  cur_6_sigstats/RMS
%  cur_6_sigstats/SINAD
%  cur_6_sigstats/SNR
%  cur_6_sigstats/ShapeFactor
%  cur_6_sigstats/Skewness
%  cur_6_sigstats/Std
%  cur_6_sigstats/THD
%  roll_sigstats/ClearanceFactor
%  roll_sigstats/CrestFactor
%  roll_sigstats/ImpulseFactor
%  roll_sigstats/Kurtosis
%  roll_sigstats/Mean
%  roll_sigstats/PeakValue
%  roll_sigstats/RMS
%  roll_sigstats/SINAD
%  roll_sigstats/SNR
%  roll_sigstats/ShapeFactor
%  roll_sigstats/Skewness
%  roll_sigstats/Std
%  roll_sigstats/THD
%  pitch_sigstats/ClearanceFactor
%  pitch_sigstats/CrestFactor
%  pitch_sigstats/ImpulseFactor
%  pitch_sigstats/Kurtosis
%  pitch_sigstats/Mean
%  pitch_sigstats/PeakValue
%  pitch_sigstats/RMS
%  pitch_sigstats/SINAD
%  pitch_sigstats/SNR
%  pitch_sigstats/ShapeFactor
%  pitch_sigstats/Skewness
%  pitch_sigstats/Std
%  pitch_sigstats/THD
%  yaw_sigstats/ClearanceFactor
%  yaw_sigstats/CrestFactor
%  yaw_sigstats/ImpulseFactor
%  yaw_sigstats/Kurtosis
%  yaw_sigstats/Mean
%  yaw_sigstats/PeakValue
%  yaw_sigstats/RMS
%  yaw_sigstats/SINAD
%  yaw_sigstats/SNR
%  yaw_sigstats/ShapeFactor
%  yaw_sigstats/Skewness
%  yaw_sigstats/Std
%  yaw_sigstats/THD
%  roll_des_sigstats/ClearanceFactor
%  roll_des_sigstats/CrestFactor
%  roll_des_sigstats/ImpulseFactor
%  roll_des_sigstats/Kurtosis
%  roll_des_sigstats/Mean
%  roll_des_sigstats/PeakValue
%  roll_des_sigstats/RMS
%  roll_des_sigstats/SINAD
%  roll_des_sigstats/SNR
%  roll_des_sigstats/ShapeFactor
%  roll_des_sigstats/Skewness
%  roll_des_sigstats/Std
%  roll_des_sigstats/THD
%  pitch_des_sigstats/ClearanceFactor
%  pitch_des_sigstats/CrestFactor
%  pitch_des_sigstats/ImpulseFactor
%  pitch_des_sigstats/Kurtosis
%  pitch_des_sigstats/Mean
%  pitch_des_sigstats/PeakValue
%  pitch_des_sigstats/RMS
%  pitch_des_sigstats/SINAD
%  pitch_des_sigstats/SNR
%  pitch_des_sigstats/ShapeFactor
%  pitch_des_sigstats/Skewness
%  pitch_des_sigstats/Std
%  pitch_des_sigstats/THD
%  yaw_des_sigstats/ClearanceFactor
%  yaw_des_sigstats/CrestFactor
%  yaw_des_sigstats/ImpulseFactor
%  yaw_des_sigstats/Kurtosis
%  yaw_des_sigstats/Mean
%  yaw_des_sigstats/PeakValue
%  yaw_des_sigstats/RMS
%  yaw_des_sigstats/SINAD
%  yaw_des_sigstats/SNR
%  yaw_des_sigstats/ShapeFactor
%  yaw_des_sigstats/Skewness
%  yaw_des_sigstats/Std
%  yaw_des_sigstats/THD
%  vn_sigstats/ClearanceFactor
%  vn_sigstats/CrestFactor
%  vn_sigstats/ImpulseFactor
%  vn_sigstats/Kurtosis
%  vn_sigstats/Mean
%  vn_sigstats/PeakValue
%  vn_sigstats/RMS
%  vn_sigstats/SINAD
%  vn_sigstats/SNR
%  vn_sigstats/ShapeFactor
%  vn_sigstats/Skewness
%  vn_sigstats/Std
%  vn_sigstats/THD
%  ve_sigstats/ClearanceFactor
%  ve_sigstats/CrestFactor
%  ve_sigstats/ImpulseFactor
%  ve_sigstats/Kurtosis
%  ve_sigstats/Mean
%  ve_sigstats/PeakValue
%  ve_sigstats/RMS
%  ve_sigstats/SINAD
%  ve_sigstats/SNR
%  ve_sigstats/ShapeFactor
%  ve_sigstats/Skewness
%  ve_sigstats/Std
%  ve_sigstats/THD
%  vd_sigstats/ClearanceFactor
%  vd_sigstats/CrestFactor
%  vd_sigstats/ImpulseFactor
%  vd_sigstats/Kurtosis
%  vd_sigstats/Mean
%  vd_sigstats/PeakValue
%  vd_sigstats/RMS
%  vd_sigstats/SINAD
%  vd_sigstats/SNR
%  vd_sigstats/ShapeFactor
%  vd_sigstats/Skewness
%  vd_sigstats/Std
%  vd_sigstats/THD
%  vibe_x_sigstats/ClearanceFactor
%  vibe_x_sigstats/CrestFactor
%  vibe_x_sigstats/ImpulseFactor
%  vibe_x_sigstats/Kurtosis
%  vibe_x_sigstats/Mean
%  vibe_x_sigstats/PeakValue
%  vibe_x_sigstats/RMS
%  vibe_x_sigstats/SINAD
%  vibe_x_sigstats/SNR
%  vibe_x_sigstats/ShapeFactor
%  vibe_x_sigstats/Skewness
%  vibe_x_sigstats/Std
%  vibe_x_sigstats/THD
%  vibe_y_sigstats/ClearanceFactor
%  vibe_y_sigstats/CrestFactor
%  vibe_y_sigstats/ImpulseFactor
%  vibe_y_sigstats/Kurtosis
%  vibe_y_sigstats/Mean
%  vibe_y_sigstats/PeakValue
%  vibe_y_sigstats/RMS
%  vibe_y_sigstats/SINAD
%  vibe_y_sigstats/SNR
%  vibe_y_sigstats/ShapeFactor
%  vibe_y_sigstats/Skewness
%  vibe_y_sigstats/Std
%  vibe_y_sigstats/THD
%  vibe_z_sigstats/ClearanceFactor
%  vibe_z_sigstats/CrestFactor
%  vibe_z_sigstats/ImpulseFactor
%  vibe_z_sigstats/Kurtosis
%  vibe_z_sigstats/Mean
%  vibe_z_sigstats/PeakValue
%  vibe_z_sigstats/RMS
%  vibe_z_sigstats/SINAD
%  vibe_z_sigstats/SNR
%  vibe_z_sigstats/ShapeFactor
%  vibe_z_sigstats/Skewness
%  vibe_z_sigstats/Std
%  vibe_z_sigstats/THD
%  acc_x_ps_spec/PeakAmp1
%  acc_x_ps_spec/PeakFreq1
%  acc_x_ps_spec/BandPower
%  acc_y_ps_spec/PeakAmp1
%  acc_y_ps_spec/PeakFreq1
%  acc_y_ps_spec/BandPower
%  acc_z_ps_spec/PeakAmp1
%  acc_z_ps_spec/PeakFreq1
%  acc_z_ps_spec/BandPower
%  gyr_x_ps_spec/PeakAmp1
%  gyr_x_ps_spec/PeakFreq1
%  gyr_x_ps_spec/BandPower
%  gyr_y_ps_spec/PeakAmp1
%  gyr_y_ps_spec/PeakFreq1
%  gyr_y_ps_spec/BandPower
%  gyr_z_ps_spec/PeakAmp1
%  gyr_z_ps_spec/PeakFreq1
%  gyr_z_ps_spec/BandPower
%
% Frame Policy:
%  Frame name: FRM_1
%  Frame size: 1 seconds
%  Frame rate: 1 seconds
%
% Organization of the function:
% 1. Compute signals/spectra/features
% 2. Extract computed features into a table
%
% Modify the function to add or remove data processing, feature generation
% or ranking operations.

% Auto-generated by MATLAB on 03-Feb-2026 02:02:39

% Create output ensemble.
outputEnsemble = workspaceEnsemble(inputData,'DataVariables',["acc_x";"acc_y";"acc_z";"gyr_x";"gyr_y";"gyr_z";"pwm_1";"pwm_2";"pwm_3";"pwm_4";"pwm_5";"pwm_6";"esc_1";"esc_2";"esc_3";"esc_4";"esc_5";"esc_6";"cur_1";"cur_2";"cur_3";"cur_4";"cur_5";"cur_6";"roll";"pitch";"yaw";"roll_des";"pitch_des";"yaw_des";"vn";"ve";"vd";"vibe_x";"vibe_y";"vibe_z"],'ConditionVariables',"faultCode");

% Reset the ensemble to read from the beginning of the ensemble.
reset(outputEnsemble);

% Append new frame policy name to DataVariables.
outputEnsemble.DataVariables = [outputEnsemble.DataVariables;"FRM_1"];

% Set SelectedVariables to select variables to read from the ensemble.
outputEnsemble.SelectedVariables = ["acc_x","acc_y","acc_z","gyr_x","gyr_y","gyr_z","pwm_1","pwm_2","pwm_3","pwm_4","pwm_5","pwm_6","esc_1","esc_2","esc_3","esc_4","esc_5","esc_6","cur_1","cur_2","cur_3","cur_4","cur_5","cur_6","roll","pitch","yaw","roll_des","pitch_des","yaw_des","vn","ve","vd","vibe_x","vibe_y","vibe_z"];

% Initialize a cell array to store all the results.
allMembersResult = {};

% Loop through all ensemble members to read and write data.
while hasdata(outputEnsemble)
    % Read one member.
    member = read(outputEnsemble);

    % Read signals.
    acc_x_full = readMemberData(member,"acc_x",["Time","acc_x"]);
    acc_y_full = readMemberData(member,"acc_y",["Time","acc_y"]);
    acc_z_full = readMemberData(member,"acc_z",["Time","acc_z"]);
    gyr_x_full = readMemberData(member,"gyr_x",["Time","gyr_x"]);
    gyr_y_full = readMemberData(member,"gyr_y",["Time","gyr_y"]);
    gyr_z_full = readMemberData(member,"gyr_z",["Time","gyr_z"]);
    pwm_1_full = readMemberData(member,"pwm_1",["Time","pwm_1"]);
    pwm_2_full = readMemberData(member,"pwm_2",["Time","pwm_2"]);
    pwm_3_full = readMemberData(member,"pwm_3",["Time","pwm_3"]);
    pwm_4_full = readMemberData(member,"pwm_4",["Time","pwm_4"]);
    pwm_5_full = readMemberData(member,"pwm_5",["Time","pwm_5"]);
    pwm_6_full = readMemberData(member,"pwm_6",["Time","pwm_6"]);
    esc_1_full = readMemberData(member,"esc_1",["Time","esc_1"]);
    esc_2_full = readMemberData(member,"esc_2",["Time","esc_2"]);
    esc_3_full = readMemberData(member,"esc_3",["Time","esc_3"]);
    esc_4_full = readMemberData(member,"esc_4",["Time","esc_4"]);
    esc_5_full = readMemberData(member,"esc_5",["Time","esc_5"]);
    esc_6_full = readMemberData(member,"esc_6",["Time","esc_6"]);
    cur_1_full = readMemberData(member,"cur_1",["Time","cur_1"]);
    cur_2_full = readMemberData(member,"cur_2",["Time","cur_2"]);
    cur_3_full = readMemberData(member,"cur_3",["Time","cur_3"]);
    cur_4_full = readMemberData(member,"cur_4",["Time","cur_4"]);
    cur_5_full = readMemberData(member,"cur_5",["Time","cur_5"]);
    cur_6_full = readMemberData(member,"cur_6",["Time","cur_6"]);
    roll_full = readMemberData(member,"roll",["Time","roll"]);
    pitch_full = readMemberData(member,"pitch",["Time","pitch"]);
    yaw_full = readMemberData(member,"yaw",["Time","yaw"]);
    roll_des_full = readMemberData(member,"roll_des",["Time","roll_des"]);
    pitch_des_full = readMemberData(member,"pitch_des",["Time","pitch_des"]);
    yaw_des_full = readMemberData(member,"yaw_des",["Time","yaw_des"]);
    vn_full = readMemberData(member,"vn",["Time","vn"]);
    ve_full = readMemberData(member,"ve",["Time","ve"]);
    vd_full = readMemberData(member,"vd",["Time","vd"]);
    vibe_x_full = readMemberData(member,"vibe_x",["Time","vibe_x"]);
    vibe_y_full = readMemberData(member,"vibe_y",["Time","vibe_y"]);
    vibe_z_full = readMemberData(member,"vibe_z",["Time","vibe_z"]);

    % Get the frame intervals.
    lowerBound = min([acc_x_full.Time(1),acc_y_full.Time(1),acc_z_full.Time(1),gyr_x_full.Time(1),gyr_y_full.Time(1),gyr_z_full.Time(1),pwm_1_full.Time(1),pwm_2_full.Time(1),pwm_3_full.Time(1),pwm_4_full.Time(1),pwm_5_full.Time(1),pwm_6_full.Time(1),esc_1_full.Time(1),esc_2_full.Time(1),esc_3_full.Time(1),esc_4_full.Time(1),esc_5_full.Time(1),esc_6_full.Time(1),cur_1_full.Time(1),cur_2_full.Time(1),cur_3_full.Time(1),cur_4_full.Time(1),cur_5_full.Time(1),cur_6_full.Time(1),roll_full.Time(1),pitch_full.Time(1),yaw_full.Time(1),roll_des_full.Time(1),pitch_des_full.Time(1),yaw_des_full.Time(1),vn_full.Time(1),ve_full.Time(1),vd_full.Time(1),vibe_x_full.Time(1),vibe_y_full.Time(1),vibe_z_full.Time(1)]);
    upperBound = max([acc_x_full.Time(end),acc_y_full.Time(end),acc_z_full.Time(end),gyr_x_full.Time(end),gyr_y_full.Time(end),gyr_z_full.Time(end),pwm_1_full.Time(end),pwm_2_full.Time(end),pwm_3_full.Time(end),pwm_4_full.Time(end),pwm_5_full.Time(end),pwm_6_full.Time(end),esc_1_full.Time(end),esc_2_full.Time(end),esc_3_full.Time(end),esc_4_full.Time(end),esc_5_full.Time(end),esc_6_full.Time(end),cur_1_full.Time(end),cur_2_full.Time(end),cur_3_full.Time(end),cur_4_full.Time(end),cur_5_full.Time(end),cur_6_full.Time(end),roll_full.Time(end),pitch_full.Time(end),yaw_full.Time(end),roll_des_full.Time(end),pitch_des_full.Time(end),yaw_des_full.Time(end),vn_full.Time(end),ve_full.Time(end),vd_full.Time(end),vibe_x_full.Time(end),vibe_y_full.Time(end),vibe_z_full.Time(end)]);
    fullIntervals = frameintervals([lowerBound upperBound],1,1,'FrameUnit',"seconds");
    intervals = fullIntervals;

    % Initialize a table to store frame results.
    frames = table;

    % Loop through all frame intervals and compute results.
    for ct = 1:height(intervals)
        % Get all input variables.
        acc_x = acc_x_full(acc_x_full.Time>=intervals{ct,1}&acc_x_full.Time<intervals{ct,2},:);
        acc_y = acc_y_full(acc_y_full.Time>=intervals{ct,1}&acc_y_full.Time<intervals{ct,2},:);
        acc_z = acc_z_full(acc_z_full.Time>=intervals{ct,1}&acc_z_full.Time<intervals{ct,2},:);
        gyr_x = gyr_x_full(gyr_x_full.Time>=intervals{ct,1}&gyr_x_full.Time<intervals{ct,2},:);
        gyr_y = gyr_y_full(gyr_y_full.Time>=intervals{ct,1}&gyr_y_full.Time<intervals{ct,2},:);
        gyr_z = gyr_z_full(gyr_z_full.Time>=intervals{ct,1}&gyr_z_full.Time<intervals{ct,2},:);
        pwm_1 = pwm_1_full(pwm_1_full.Time>=intervals{ct,1}&pwm_1_full.Time<intervals{ct,2},:);
        pwm_2 = pwm_2_full(pwm_2_full.Time>=intervals{ct,1}&pwm_2_full.Time<intervals{ct,2},:);
        pwm_3 = pwm_3_full(pwm_3_full.Time>=intervals{ct,1}&pwm_3_full.Time<intervals{ct,2},:);
        pwm_4 = pwm_4_full(pwm_4_full.Time>=intervals{ct,1}&pwm_4_full.Time<intervals{ct,2},:);
        pwm_5 = pwm_5_full(pwm_5_full.Time>=intervals{ct,1}&pwm_5_full.Time<intervals{ct,2},:);
        pwm_6 = pwm_6_full(pwm_6_full.Time>=intervals{ct,1}&pwm_6_full.Time<intervals{ct,2},:);
        esc_1 = esc_1_full(esc_1_full.Time>=intervals{ct,1}&esc_1_full.Time<intervals{ct,2},:);
        esc_2 = esc_2_full(esc_2_full.Time>=intervals{ct,1}&esc_2_full.Time<intervals{ct,2},:);
        esc_3 = esc_3_full(esc_3_full.Time>=intervals{ct,1}&esc_3_full.Time<intervals{ct,2},:);
        esc_4 = esc_4_full(esc_4_full.Time>=intervals{ct,1}&esc_4_full.Time<intervals{ct,2},:);
        esc_5 = esc_5_full(esc_5_full.Time>=intervals{ct,1}&esc_5_full.Time<intervals{ct,2},:);
        esc_6 = esc_6_full(esc_6_full.Time>=intervals{ct,1}&esc_6_full.Time<intervals{ct,2},:);
        cur_1 = cur_1_full(cur_1_full.Time>=intervals{ct,1}&cur_1_full.Time<intervals{ct,2},:);
        cur_2 = cur_2_full(cur_2_full.Time>=intervals{ct,1}&cur_2_full.Time<intervals{ct,2},:);
        cur_3 = cur_3_full(cur_3_full.Time>=intervals{ct,1}&cur_3_full.Time<intervals{ct,2},:);
        cur_4 = cur_4_full(cur_4_full.Time>=intervals{ct,1}&cur_4_full.Time<intervals{ct,2},:);
        cur_5 = cur_5_full(cur_5_full.Time>=intervals{ct,1}&cur_5_full.Time<intervals{ct,2},:);
        cur_6 = cur_6_full(cur_6_full.Time>=intervals{ct,1}&cur_6_full.Time<intervals{ct,2},:);
        roll = roll_full(roll_full.Time>=intervals{ct,1}&roll_full.Time<intervals{ct,2},:);
        pitch = pitch_full(pitch_full.Time>=intervals{ct,1}&pitch_full.Time<intervals{ct,2},:);
        yaw = yaw_full(yaw_full.Time>=intervals{ct,1}&yaw_full.Time<intervals{ct,2},:);
        roll_des = roll_des_full(roll_des_full.Time>=intervals{ct,1}&roll_des_full.Time<intervals{ct,2},:);
        pitch_des = pitch_des_full(pitch_des_full.Time>=intervals{ct,1}&pitch_des_full.Time<intervals{ct,2},:);
        yaw_des = yaw_des_full(yaw_des_full.Time>=intervals{ct,1}&yaw_des_full.Time<intervals{ct,2},:);
        vn = vn_full(vn_full.Time>=intervals{ct,1}&vn_full.Time<intervals{ct,2},:);
        ve = ve_full(ve_full.Time>=intervals{ct,1}&ve_full.Time<intervals{ct,2},:);
        vd = vd_full(vd_full.Time>=intervals{ct,1}&vd_full.Time<intervals{ct,2},:);
        vibe_x = vibe_x_full(vibe_x_full.Time>=intervals{ct,1}&vibe_x_full.Time<intervals{ct,2},:);
        vibe_y = vibe_y_full(vibe_y_full.Time>=intervals{ct,1}&vibe_y_full.Time<intervals{ct,2},:);
        vibe_z = vibe_z_full(vibe_z_full.Time>=intervals{ct,1}&vibe_z_full.Time<intervals{ct,2},:);

        % Initialize a table to store results for one frame interval.
        frame = intervals(ct,:);

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = acc_x.acc_x;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            acc_x_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            acc_x_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({acc_x_sigstats},'VariableNames',{'acc_x_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = acc_y.acc_y;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            acc_y_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            acc_y_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({acc_y_sigstats},'VariableNames',{'acc_y_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = acc_z.acc_z;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            acc_z_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            acc_z_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({acc_z_sigstats},'VariableNames',{'acc_z_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = gyr_x.gyr_x;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            gyr_x_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            gyr_x_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({gyr_x_sigstats},'VariableNames',{'gyr_x_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = gyr_y.gyr_y;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            gyr_y_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            gyr_y_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({gyr_y_sigstats},'VariableNames',{'gyr_y_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = gyr_z.gyr_z;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            gyr_z_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            gyr_z_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({gyr_z_sigstats},'VariableNames',{'gyr_z_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = pwm_1.pwm_1;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_1_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_1_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({pwm_1_sigstats},'VariableNames',{'pwm_1_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = pwm_2.pwm_2;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_2_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_2_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({pwm_2_sigstats},'VariableNames',{'pwm_2_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = pwm_3.pwm_3;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_3_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_3_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({pwm_3_sigstats},'VariableNames',{'pwm_3_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = pwm_4.pwm_4;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_4_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_4_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({pwm_4_sigstats},'VariableNames',{'pwm_4_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = pwm_5.pwm_5;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_5_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_5_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({pwm_5_sigstats},'VariableNames',{'pwm_5_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = pwm_6.pwm_6;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_6_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pwm_6_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({pwm_6_sigstats},'VariableNames',{'pwm_6_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = esc_1.esc_1;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_1_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_1_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({esc_1_sigstats},'VariableNames',{'esc_1_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = esc_2.esc_2;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_2_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_2_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({esc_2_sigstats},'VariableNames',{'esc_2_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = esc_3.esc_3;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_3_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_3_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({esc_3_sigstats},'VariableNames',{'esc_3_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = esc_4.esc_4;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_4_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_4_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({esc_4_sigstats},'VariableNames',{'esc_4_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = esc_5.esc_5;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_5_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_5_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({esc_5_sigstats},'VariableNames',{'esc_5_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = esc_6.esc_6;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_6_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            esc_6_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({esc_6_sigstats},'VariableNames',{'esc_6_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = cur_1.cur_1;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_1_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_1_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({cur_1_sigstats},'VariableNames',{'cur_1_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = cur_2.cur_2;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_2_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_2_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({cur_2_sigstats},'VariableNames',{'cur_2_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = cur_3.cur_3;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_3_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_3_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({cur_3_sigstats},'VariableNames',{'cur_3_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = cur_4.cur_4;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_4_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_4_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({cur_4_sigstats},'VariableNames',{'cur_4_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = cur_5.cur_5;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_5_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_5_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({cur_5_sigstats},'VariableNames',{'cur_5_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = cur_6.cur_6;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_6_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            cur_6_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({cur_6_sigstats},'VariableNames',{'cur_6_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = roll.roll;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            roll_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            roll_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({roll_sigstats},'VariableNames',{'roll_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = pitch.pitch;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pitch_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pitch_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({pitch_sigstats},'VariableNames',{'pitch_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = yaw.yaw;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            yaw_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            yaw_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({yaw_sigstats},'VariableNames',{'yaw_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = roll_des.roll_des;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            roll_des_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            roll_des_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({roll_des_sigstats},'VariableNames',{'roll_des_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = pitch_des.pitch_des;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pitch_des_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            pitch_des_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({pitch_des_sigstats},'VariableNames',{'pitch_des_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = yaw_des.yaw_des;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            yaw_des_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            yaw_des_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({yaw_des_sigstats},'VariableNames',{'yaw_des_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = vn.vn;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            vn_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            vn_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({vn_sigstats},'VariableNames',{'vn_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = ve.ve;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            ve_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            ve_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({ve_sigstats},'VariableNames',{'ve_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = vd.vd;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            vd_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            vd_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({vd_sigstats},'VariableNames',{'vd_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = vibe_x.vibe_x;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            vibe_x_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            vibe_x_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({vibe_x_sigstats},'VariableNames',{'vibe_x_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = vibe_y.vibe_y;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            vibe_y_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            vibe_y_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({vibe_y_sigstats},'VariableNames',{'vibe_y_sigstats'})];

        %% SignalFeatures
        try
            % Compute signal features.
            inputSignal = vibe_z.vibe_z;
            ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
            CrestFactor = peak2rms(inputSignal);
            ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
            Kurtosis = kurtosis(inputSignal);
            Mean = mean(inputSignal,'omitnan');
            PeakValue = max(abs(inputSignal));
            RMS = rms(inputSignal,'omitnan');
            SINAD = sinad(inputSignal);
            SNR = snr(inputSignal);
            ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
            Skewness = skewness(inputSignal);
            Std = std(inputSignal,'omitnan');
            THD = thd(inputSignal);

            % Concatenate signal features.
            featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];

            % Store computed features in a table.
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            vibe_z_sigstats = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,13);
            featureNames = {'ClearanceFactor','CrestFactor','ImpulseFactor','Kurtosis','Mean','PeakValue','RMS','SINAD','SNR','ShapeFactor','Skewness','Std','THD'};
            vibe_z_sigstats = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({vibe_z_sigstats},'VariableNames',{'vibe_z_sigstats'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";

            % Compute effective sampling rate.
            tNumeric = time2num(acc_x.Time,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = acc_x.acc_x;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Set Welch spectrum parameters.
            L = fix(length(x)/4.5);
            noverlap = fix(L*50/100);
            win = hamming(L);

            % Compute the power spectrum.
            f = linspace(0,175,1000);
            f = f*funitconv('Hz','cycles/TimeUnit','seconds');
            [ps,f] = pwelch(x,win,noverlap,f(:),Fs);
            ps = 2*ps;
            w = 2*pi*f;

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            acc_x_ps = ps;
        catch
            acc_x_ps = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({acc_x_ps},'VariableNames',{'acc_x_ps'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";

            % Compute effective sampling rate.
            tNumeric = time2num(acc_y.Time,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = acc_y.acc_y;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Set Welch spectrum parameters.
            L = fix(length(x)/4.5);
            noverlap = fix(L*50/100);
            win = hamming(L);

            % Compute the power spectrum.
            f = linspace(0,175,1000);
            f = f*funitconv('Hz','cycles/TimeUnit','seconds');
            [ps,f] = pwelch(x,win,noverlap,f(:),Fs);
            ps = 2*ps;
            w = 2*pi*f;

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            acc_y_ps = ps;
        catch
            acc_y_ps = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({acc_y_ps},'VariableNames',{'acc_y_ps'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";

            % Compute effective sampling rate.
            tNumeric = time2num(acc_z.Time,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = acc_z.acc_z;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Set Welch spectrum parameters.
            L = fix(length(x)/4.5);
            noverlap = fix(L*50/100);
            win = hamming(L);

            % Compute the power spectrum.
            f = linspace(0,175,1000);
            f = f*funitconv('Hz','cycles/TimeUnit','seconds');
            [ps,f] = pwelch(x,win,noverlap,f(:),Fs);
            ps = 2*ps;
            w = 2*pi*f;

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            acc_z_ps = ps;
        catch
            acc_z_ps = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({acc_z_ps},'VariableNames',{'acc_z_ps'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";

            % Compute effective sampling rate.
            tNumeric = time2num(gyr_x.Time,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = gyr_x.gyr_x;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Set Welch spectrum parameters.
            L = fix(length(x)/4.5);
            noverlap = fix(L*50/100);
            win = hamming(L);

            % Compute the power spectrum.
            f = linspace(0,175,1000);
            f = f*funitconv('Hz','cycles/TimeUnit','seconds');
            [ps,f] = pwelch(x,win,noverlap,f(:),Fs);
            ps = 2*ps;
            w = 2*pi*f;

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            gyr_x_ps = ps;
        catch
            gyr_x_ps = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({gyr_x_ps},'VariableNames',{'gyr_x_ps'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";

            % Compute effective sampling rate.
            tNumeric = time2num(gyr_y.Time,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = gyr_y.gyr_y;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Set Welch spectrum parameters.
            L = fix(length(x)/4.5);
            noverlap = fix(L*50/100);
            win = hamming(L);

            % Compute the power spectrum.
            f = linspace(0,175,1000);
            f = f*funitconv('Hz','cycles/TimeUnit','seconds');
            [ps,f] = pwelch(x,win,noverlap,f(:),Fs);
            ps = 2*ps;
            w = 2*pi*f;

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            gyr_y_ps = ps;
        catch
            gyr_y_ps = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({gyr_y_ps},'VariableNames',{'gyr_y_ps'})];

        %% PowerSpectrum
        try
            % Get units to use in computed spectrum.
            tuReal = "seconds";

            % Compute effective sampling rate.
            tNumeric = time2num(gyr_z.Time,tuReal);
            [Fs,irregular] = effectivefs(tNumeric);
            Ts = 1/Fs;

            % Resample non-uniform signals.
            x_raw = gyr_z.gyr_z;
            if irregular
                x = resample(x_raw,tNumeric,Fs,'linear');
            else
                x = x_raw;
            end

            % Set Welch spectrum parameters.
            L = fix(length(x)/4.5);
            noverlap = fix(L*50/100);
            win = hamming(L);

            % Compute the power spectrum.
            f = linspace(0,175,1000);
            f = f*funitconv('Hz','cycles/TimeUnit','seconds');
            [ps,f] = pwelch(x,win,noverlap,f(:),Fs);
            ps = 2*ps;
            w = 2*pi*f;

            % Convert frequency unit.
            factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
            w = factor*w;
            Fs = 2*pi*factor*Fs;

            % Remove frequencies above Nyquist frequency.
            I = w<=(Fs/2+1e4*eps);
            w = w(I);
            ps = ps(I);

            % Configure the computed spectrum.
            ps = table(w, ps, 'VariableNames', {'Frequency', 'SpectrumData'});
            ps.Properties.VariableUnits = {'Hz', ''};
            ps = addprop(ps, {'SampleFrequency'}, {'table'});
            ps.Properties.CustomProperties.SampleFrequency = Fs;
            gyr_z_ps = ps;
        catch
            gyr_z_ps = table(NaN, NaN, 'VariableNames', {'Frequency', 'SpectrumData'});
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({gyr_z_ps},'VariableNames',{'gyr_z_ps'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = acc_x_ps.SpectrumData;
            w = acc_x_ps.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*0.175175175175175) & (w<=factor*175);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',1);
            peakAmp = [peakAmp(:); NaN(1-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(1-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakFreq1 = peakFreq(1);
            BandPower = trapz(w/factor,ps);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakFreq1,BandPower];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            acc_x_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            acc_x_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({acc_x_ps_spec},'VariableNames',{'acc_x_ps_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = acc_y_ps.SpectrumData;
            w = acc_y_ps.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*0.175175175175175) & (w<=factor*175);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',1);
            peakAmp = [peakAmp(:); NaN(1-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(1-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakFreq1 = peakFreq(1);
            BandPower = trapz(w/factor,ps);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakFreq1,BandPower];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            acc_y_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            acc_y_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({acc_y_ps_spec},'VariableNames',{'acc_y_ps_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = acc_z_ps.SpectrumData;
            w = acc_z_ps.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*0.175175175175175) & (w<=factor*175);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',1);
            peakAmp = [peakAmp(:); NaN(1-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(1-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakFreq1 = peakFreq(1);
            BandPower = trapz(w/factor,ps);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakFreq1,BandPower];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            acc_z_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            acc_z_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({acc_z_ps_spec},'VariableNames',{'acc_z_ps_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = gyr_x_ps.SpectrumData;
            w = gyr_x_ps.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*0.175175175175175) & (w<=factor*175);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',1);
            peakAmp = [peakAmp(:); NaN(1-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(1-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakFreq1 = peakFreq(1);
            BandPower = trapz(w/factor,ps);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakFreq1,BandPower];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            gyr_x_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            gyr_x_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({gyr_x_ps_spec},'VariableNames',{'gyr_x_ps_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = gyr_y_ps.SpectrumData;
            w = gyr_y_ps.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*0.175175175175175) & (w<=factor*175);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',1);
            peakAmp = [peakAmp(:); NaN(1-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(1-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakFreq1 = peakFreq(1);
            BandPower = trapz(w/factor,ps);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakFreq1,BandPower];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            gyr_y_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            gyr_y_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({gyr_y_ps_spec},'VariableNames',{'gyr_y_ps_spec'})];

        %% SpectrumFeatures
        try
            % Compute spectral features.
            % Get frequency unit conversion factor.
            factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
            ps = gyr_z_ps.SpectrumData;
            w = gyr_z_ps.Frequency;
            w = factor*w;
            mask_1 = (w>=factor*0.175175175175175) & (w<=factor*175);
            ps = ps(mask_1);
            w = w(mask_1);

            % Compute spectral peaks.
            [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
                'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',1);
            peakAmp = [peakAmp(:); NaN(1-numel(peakAmp),1)];
            peakFreq = [peakFreq(:); NaN(1-numel(peakFreq),1)];

            % Extract individual feature values.
            PeakAmp1 = peakAmp(1);
            PeakFreq1 = peakFreq(1);
            BandPower = trapz(w/factor,ps);

            % Concatenate signal features.
            featureValues = [PeakAmp1,PeakFreq1,BandPower];

            % Store computed features in a table.
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            gyr_z_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        catch
            % Store computed features in a table.
            featureValues = NaN(1,3);
            featureNames = {'PeakAmp1','PeakFreq1','BandPower'};
            gyr_z_ps_spec = array2table(featureValues,'VariableNames',featureNames);
        end

        % Append computed results to the frame table.
        frame = [frame, ...
            table({gyr_z_ps_spec},'VariableNames',{'gyr_z_ps_spec'})];

        %% Concatenate frames.
        frames = [frames;frame]; %#ok<*AGROW>
    end
    % Append all member results to the cell array.
    memberResult = table({frames},'VariableNames',"FRM_1");
    allMembersResult = [allMembersResult; {memberResult}]; %#ok<AGROW>
end

% Write the results for all members to the ensemble.
writeToMembers(outputEnsemble,allMembersResult)

% Gather all features into a table.
selectedFeatureNames = ["FRM_1/acc_x_sigstats/ClearanceFactor","FRM_1/acc_x_sigstats/CrestFactor","FRM_1/acc_x_sigstats/ImpulseFactor","FRM_1/acc_x_sigstats/Kurtosis","FRM_1/acc_x_sigstats/Mean","FRM_1/acc_x_sigstats/PeakValue","FRM_1/acc_x_sigstats/RMS","FRM_1/acc_x_sigstats/SINAD","FRM_1/acc_x_sigstats/SNR","FRM_1/acc_x_sigstats/ShapeFactor","FRM_1/acc_x_sigstats/Skewness","FRM_1/acc_x_sigstats/Std","FRM_1/acc_x_sigstats/THD","FRM_1/acc_y_sigstats/ClearanceFactor","FRM_1/acc_y_sigstats/CrestFactor","FRM_1/acc_y_sigstats/ImpulseFactor","FRM_1/acc_y_sigstats/Kurtosis","FRM_1/acc_y_sigstats/Mean","FRM_1/acc_y_sigstats/PeakValue","FRM_1/acc_y_sigstats/RMS","FRM_1/acc_y_sigstats/SINAD","FRM_1/acc_y_sigstats/SNR","FRM_1/acc_y_sigstats/ShapeFactor","FRM_1/acc_y_sigstats/Skewness","FRM_1/acc_y_sigstats/Std","FRM_1/acc_y_sigstats/THD","FRM_1/acc_z_sigstats/ClearanceFactor","FRM_1/acc_z_sigstats/CrestFactor","FRM_1/acc_z_sigstats/ImpulseFactor","FRM_1/acc_z_sigstats/Kurtosis","FRM_1/acc_z_sigstats/Mean","FRM_1/acc_z_sigstats/PeakValue","FRM_1/acc_z_sigstats/RMS","FRM_1/acc_z_sigstats/SINAD","FRM_1/acc_z_sigstats/SNR","FRM_1/acc_z_sigstats/ShapeFactor","FRM_1/acc_z_sigstats/Skewness","FRM_1/acc_z_sigstats/Std","FRM_1/acc_z_sigstats/THD","FRM_1/gyr_x_sigstats/ClearanceFactor","FRM_1/gyr_x_sigstats/CrestFactor","FRM_1/gyr_x_sigstats/ImpulseFactor","FRM_1/gyr_x_sigstats/Kurtosis","FRM_1/gyr_x_sigstats/Mean","FRM_1/gyr_x_sigstats/PeakValue","FRM_1/gyr_x_sigstats/RMS","FRM_1/gyr_x_sigstats/SINAD","FRM_1/gyr_x_sigstats/SNR","FRM_1/gyr_x_sigstats/ShapeFactor","FRM_1/gyr_x_sigstats/Skewness","FRM_1/gyr_x_sigstats/Std","FRM_1/gyr_x_sigstats/THD","FRM_1/gyr_y_sigstats/ClearanceFactor","FRM_1/gyr_y_sigstats/CrestFactor","FRM_1/gyr_y_sigstats/ImpulseFactor","FRM_1/gyr_y_sigstats/Kurtosis","FRM_1/gyr_y_sigstats/Mean","FRM_1/gyr_y_sigstats/PeakValue","FRM_1/gyr_y_sigstats/RMS","FRM_1/gyr_y_sigstats/SINAD","FRM_1/gyr_y_sigstats/SNR","FRM_1/gyr_y_sigstats/ShapeFactor","FRM_1/gyr_y_sigstats/Skewness","FRM_1/gyr_y_sigstats/Std","FRM_1/gyr_y_sigstats/THD","FRM_1/gyr_z_sigstats/ClearanceFactor","FRM_1/gyr_z_sigstats/CrestFactor","FRM_1/gyr_z_sigstats/ImpulseFactor","FRM_1/gyr_z_sigstats/Kurtosis","FRM_1/gyr_z_sigstats/Mean","FRM_1/gyr_z_sigstats/PeakValue","FRM_1/gyr_z_sigstats/RMS","FRM_1/gyr_z_sigstats/SINAD","FRM_1/gyr_z_sigstats/SNR","FRM_1/gyr_z_sigstats/ShapeFactor","FRM_1/gyr_z_sigstats/Skewness","FRM_1/gyr_z_sigstats/Std","FRM_1/gyr_z_sigstats/THD","FRM_1/pwm_1_sigstats/ClearanceFactor","FRM_1/pwm_1_sigstats/CrestFactor","FRM_1/pwm_1_sigstats/ImpulseFactor","FRM_1/pwm_1_sigstats/Kurtosis","FRM_1/pwm_1_sigstats/Mean","FRM_1/pwm_1_sigstats/PeakValue","FRM_1/pwm_1_sigstats/RMS","FRM_1/pwm_1_sigstats/SINAD","FRM_1/pwm_1_sigstats/SNR","FRM_1/pwm_1_sigstats/ShapeFactor","FRM_1/pwm_1_sigstats/Skewness","FRM_1/pwm_1_sigstats/Std","FRM_1/pwm_1_sigstats/THD","FRM_1/pwm_2_sigstats/ClearanceFactor","FRM_1/pwm_2_sigstats/CrestFactor","FRM_1/pwm_2_sigstats/ImpulseFactor","FRM_1/pwm_2_sigstats/Kurtosis","FRM_1/pwm_2_sigstats/Mean","FRM_1/pwm_2_sigstats/PeakValue","FRM_1/pwm_2_sigstats/RMS","FRM_1/pwm_2_sigstats/SINAD","FRM_1/pwm_2_sigstats/SNR","FRM_1/pwm_2_sigstats/ShapeFactor","FRM_1/pwm_2_sigstats/Skewness","FRM_1/pwm_2_sigstats/Std","FRM_1/pwm_2_sigstats/THD","FRM_1/pwm_3_sigstats/ClearanceFactor","FRM_1/pwm_3_sigstats/CrestFactor","FRM_1/pwm_3_sigstats/ImpulseFactor","FRM_1/pwm_3_sigstats/Kurtosis","FRM_1/pwm_3_sigstats/Mean","FRM_1/pwm_3_sigstats/PeakValue","FRM_1/pwm_3_sigstats/RMS","FRM_1/pwm_3_sigstats/SINAD","FRM_1/pwm_3_sigstats/SNR","FRM_1/pwm_3_sigstats/ShapeFactor","FRM_1/pwm_3_sigstats/Skewness","FRM_1/pwm_3_sigstats/Std","FRM_1/pwm_3_sigstats/THD","FRM_1/pwm_4_sigstats/ClearanceFactor","FRM_1/pwm_4_sigstats/CrestFactor","FRM_1/pwm_4_sigstats/ImpulseFactor","FRM_1/pwm_4_sigstats/Kurtosis","FRM_1/pwm_4_sigstats/Mean","FRM_1/pwm_4_sigstats/PeakValue","FRM_1/pwm_4_sigstats/RMS","FRM_1/pwm_4_sigstats/SINAD","FRM_1/pwm_4_sigstats/SNR","FRM_1/pwm_4_sigstats/ShapeFactor","FRM_1/pwm_4_sigstats/Skewness","FRM_1/pwm_4_sigstats/Std","FRM_1/pwm_4_sigstats/THD","FRM_1/pwm_5_sigstats/ClearanceFactor","FRM_1/pwm_5_sigstats/CrestFactor","FRM_1/pwm_5_sigstats/ImpulseFactor","FRM_1/pwm_5_sigstats/Kurtosis","FRM_1/pwm_5_sigstats/Mean","FRM_1/pwm_5_sigstats/PeakValue","FRM_1/pwm_5_sigstats/RMS","FRM_1/pwm_5_sigstats/SINAD","FRM_1/pwm_5_sigstats/SNR","FRM_1/pwm_5_sigstats/ShapeFactor","FRM_1/pwm_5_sigstats/Skewness","FRM_1/pwm_5_sigstats/Std","FRM_1/pwm_5_sigstats/THD","FRM_1/pwm_6_sigstats/ClearanceFactor","FRM_1/pwm_6_sigstats/CrestFactor","FRM_1/pwm_6_sigstats/ImpulseFactor","FRM_1/pwm_6_sigstats/Kurtosis","FRM_1/pwm_6_sigstats/Mean","FRM_1/pwm_6_sigstats/PeakValue","FRM_1/pwm_6_sigstats/RMS","FRM_1/pwm_6_sigstats/SINAD","FRM_1/pwm_6_sigstats/SNR","FRM_1/pwm_6_sigstats/ShapeFactor","FRM_1/pwm_6_sigstats/Skewness","FRM_1/pwm_6_sigstats/Std","FRM_1/pwm_6_sigstats/THD","FRM_1/esc_1_sigstats/ClearanceFactor","FRM_1/esc_1_sigstats/CrestFactor","FRM_1/esc_1_sigstats/ImpulseFactor","FRM_1/esc_1_sigstats/Kurtosis","FRM_1/esc_1_sigstats/Mean","FRM_1/esc_1_sigstats/PeakValue","FRM_1/esc_1_sigstats/RMS","FRM_1/esc_1_sigstats/SINAD","FRM_1/esc_1_sigstats/SNR","FRM_1/esc_1_sigstats/ShapeFactor","FRM_1/esc_1_sigstats/Skewness","FRM_1/esc_1_sigstats/Std","FRM_1/esc_1_sigstats/THD","FRM_1/esc_2_sigstats/ClearanceFactor","FRM_1/esc_2_sigstats/CrestFactor","FRM_1/esc_2_sigstats/ImpulseFactor","FRM_1/esc_2_sigstats/Kurtosis","FRM_1/esc_2_sigstats/Mean","FRM_1/esc_2_sigstats/PeakValue","FRM_1/esc_2_sigstats/RMS","FRM_1/esc_2_sigstats/SINAD","FRM_1/esc_2_sigstats/SNR","FRM_1/esc_2_sigstats/ShapeFactor","FRM_1/esc_2_sigstats/Skewness","FRM_1/esc_2_sigstats/Std","FRM_1/esc_2_sigstats/THD","FRM_1/esc_3_sigstats/ClearanceFactor","FRM_1/esc_3_sigstats/CrestFactor","FRM_1/esc_3_sigstats/ImpulseFactor","FRM_1/esc_3_sigstats/Kurtosis","FRM_1/esc_3_sigstats/Mean","FRM_1/esc_3_sigstats/PeakValue","FRM_1/esc_3_sigstats/RMS","FRM_1/esc_3_sigstats/SINAD","FRM_1/esc_3_sigstats/SNR","FRM_1/esc_3_sigstats/ShapeFactor","FRM_1/esc_3_sigstats/Skewness","FRM_1/esc_3_sigstats/Std","FRM_1/esc_3_sigstats/THD","FRM_1/esc_4_sigstats/ClearanceFactor","FRM_1/esc_4_sigstats/CrestFactor","FRM_1/esc_4_sigstats/ImpulseFactor","FRM_1/esc_4_sigstats/Kurtosis","FRM_1/esc_4_sigstats/Mean","FRM_1/esc_4_sigstats/PeakValue","FRM_1/esc_4_sigstats/RMS","FRM_1/esc_4_sigstats/SINAD","FRM_1/esc_4_sigstats/SNR","FRM_1/esc_4_sigstats/ShapeFactor","FRM_1/esc_4_sigstats/Skewness","FRM_1/esc_4_sigstats/Std","FRM_1/esc_4_sigstats/THD","FRM_1/esc_5_sigstats/ClearanceFactor","FRM_1/esc_5_sigstats/CrestFactor","FRM_1/esc_5_sigstats/ImpulseFactor","FRM_1/esc_5_sigstats/Kurtosis","FRM_1/esc_5_sigstats/Mean","FRM_1/esc_5_sigstats/PeakValue","FRM_1/esc_5_sigstats/RMS","FRM_1/esc_5_sigstats/SINAD","FRM_1/esc_5_sigstats/SNR","FRM_1/esc_5_sigstats/ShapeFactor","FRM_1/esc_5_sigstats/Skewness","FRM_1/esc_5_sigstats/Std","FRM_1/esc_5_sigstats/THD","FRM_1/esc_6_sigstats/ClearanceFactor","FRM_1/esc_6_sigstats/CrestFactor","FRM_1/esc_6_sigstats/ImpulseFactor","FRM_1/esc_6_sigstats/Kurtosis","FRM_1/esc_6_sigstats/Mean","FRM_1/esc_6_sigstats/PeakValue","FRM_1/esc_6_sigstats/RMS","FRM_1/esc_6_sigstats/SINAD","FRM_1/esc_6_sigstats/SNR","FRM_1/esc_6_sigstats/ShapeFactor","FRM_1/esc_6_sigstats/Skewness","FRM_1/esc_6_sigstats/Std","FRM_1/esc_6_sigstats/THD","FRM_1/cur_1_sigstats/ClearanceFactor","FRM_1/cur_1_sigstats/CrestFactor","FRM_1/cur_1_sigstats/ImpulseFactor","FRM_1/cur_1_sigstats/Kurtosis","FRM_1/cur_1_sigstats/Mean","FRM_1/cur_1_sigstats/PeakValue","FRM_1/cur_1_sigstats/RMS","FRM_1/cur_1_sigstats/SINAD","FRM_1/cur_1_sigstats/SNR","FRM_1/cur_1_sigstats/ShapeFactor","FRM_1/cur_1_sigstats/Skewness","FRM_1/cur_1_sigstats/Std","FRM_1/cur_1_sigstats/THD","FRM_1/cur_2_sigstats/ClearanceFactor","FRM_1/cur_2_sigstats/CrestFactor","FRM_1/cur_2_sigstats/ImpulseFactor","FRM_1/cur_2_sigstats/Kurtosis","FRM_1/cur_2_sigstats/Mean","FRM_1/cur_2_sigstats/PeakValue","FRM_1/cur_2_sigstats/RMS","FRM_1/cur_2_sigstats/SINAD","FRM_1/cur_2_sigstats/SNR","FRM_1/cur_2_sigstats/ShapeFactor","FRM_1/cur_2_sigstats/Skewness","FRM_1/cur_2_sigstats/Std","FRM_1/cur_2_sigstats/THD","FRM_1/cur_3_sigstats/ClearanceFactor","FRM_1/cur_3_sigstats/CrestFactor","FRM_1/cur_3_sigstats/ImpulseFactor","FRM_1/cur_3_sigstats/Kurtosis","FRM_1/cur_3_sigstats/Mean","FRM_1/cur_3_sigstats/PeakValue","FRM_1/cur_3_sigstats/RMS","FRM_1/cur_3_sigstats/SINAD","FRM_1/cur_3_sigstats/SNR","FRM_1/cur_3_sigstats/ShapeFactor","FRM_1/cur_3_sigstats/Skewness","FRM_1/cur_3_sigstats/Std","FRM_1/cur_3_sigstats/THD","FRM_1/cur_4_sigstats/ClearanceFactor","FRM_1/cur_4_sigstats/CrestFactor","FRM_1/cur_4_sigstats/ImpulseFactor","FRM_1/cur_4_sigstats/Kurtosis","FRM_1/cur_4_sigstats/Mean","FRM_1/cur_4_sigstats/PeakValue","FRM_1/cur_4_sigstats/RMS","FRM_1/cur_4_sigstats/SINAD","FRM_1/cur_4_sigstats/SNR","FRM_1/cur_4_sigstats/ShapeFactor","FRM_1/cur_4_sigstats/Skewness","FRM_1/cur_4_sigstats/Std","FRM_1/cur_4_sigstats/THD","FRM_1/cur_5_sigstats/ClearanceFactor","FRM_1/cur_5_sigstats/CrestFactor","FRM_1/cur_5_sigstats/ImpulseFactor","FRM_1/cur_5_sigstats/Kurtosis","FRM_1/cur_5_sigstats/Mean","FRM_1/cur_5_sigstats/PeakValue","FRM_1/cur_5_sigstats/RMS","FRM_1/cur_5_sigstats/SINAD","FRM_1/cur_5_sigstats/SNR","FRM_1/cur_5_sigstats/ShapeFactor","FRM_1/cur_5_sigstats/Skewness","FRM_1/cur_5_sigstats/Std","FRM_1/cur_5_sigstats/THD","FRM_1/cur_6_sigstats/ClearanceFactor","FRM_1/cur_6_sigstats/CrestFactor","FRM_1/cur_6_sigstats/ImpulseFactor","FRM_1/cur_6_sigstats/Kurtosis","FRM_1/cur_6_sigstats/Mean","FRM_1/cur_6_sigstats/PeakValue","FRM_1/cur_6_sigstats/RMS","FRM_1/cur_6_sigstats/SINAD","FRM_1/cur_6_sigstats/SNR","FRM_1/cur_6_sigstats/ShapeFactor","FRM_1/cur_6_sigstats/Skewness","FRM_1/cur_6_sigstats/Std","FRM_1/cur_6_sigstats/THD","FRM_1/roll_sigstats/ClearanceFactor","FRM_1/roll_sigstats/CrestFactor","FRM_1/roll_sigstats/ImpulseFactor","FRM_1/roll_sigstats/Kurtosis","FRM_1/roll_sigstats/Mean","FRM_1/roll_sigstats/PeakValue","FRM_1/roll_sigstats/RMS","FRM_1/roll_sigstats/SINAD","FRM_1/roll_sigstats/SNR","FRM_1/roll_sigstats/ShapeFactor","FRM_1/roll_sigstats/Skewness","FRM_1/roll_sigstats/Std","FRM_1/roll_sigstats/THD","FRM_1/pitch_sigstats/ClearanceFactor","FRM_1/pitch_sigstats/CrestFactor","FRM_1/pitch_sigstats/ImpulseFactor","FRM_1/pitch_sigstats/Kurtosis","FRM_1/pitch_sigstats/Mean","FRM_1/pitch_sigstats/PeakValue","FRM_1/pitch_sigstats/RMS","FRM_1/pitch_sigstats/SINAD","FRM_1/pitch_sigstats/SNR","FRM_1/pitch_sigstats/ShapeFactor","FRM_1/pitch_sigstats/Skewness","FRM_1/pitch_sigstats/Std","FRM_1/pitch_sigstats/THD","FRM_1/yaw_sigstats/ClearanceFactor","FRM_1/yaw_sigstats/CrestFactor","FRM_1/yaw_sigstats/ImpulseFactor","FRM_1/yaw_sigstats/Kurtosis","FRM_1/yaw_sigstats/Mean","FRM_1/yaw_sigstats/PeakValue","FRM_1/yaw_sigstats/RMS","FRM_1/yaw_sigstats/SINAD","FRM_1/yaw_sigstats/SNR","FRM_1/yaw_sigstats/ShapeFactor","FRM_1/yaw_sigstats/Skewness","FRM_1/yaw_sigstats/Std","FRM_1/yaw_sigstats/THD","FRM_1/roll_des_sigstats/ClearanceFactor","FRM_1/roll_des_sigstats/CrestFactor","FRM_1/roll_des_sigstats/ImpulseFactor","FRM_1/roll_des_sigstats/Kurtosis","FRM_1/roll_des_sigstats/Mean","FRM_1/roll_des_sigstats/PeakValue","FRM_1/roll_des_sigstats/RMS","FRM_1/roll_des_sigstats/SINAD","FRM_1/roll_des_sigstats/SNR","FRM_1/roll_des_sigstats/ShapeFactor","FRM_1/roll_des_sigstats/Skewness","FRM_1/roll_des_sigstats/Std","FRM_1/roll_des_sigstats/THD","FRM_1/pitch_des_sigstats/ClearanceFactor","FRM_1/pitch_des_sigstats/CrestFactor","FRM_1/pitch_des_sigstats/ImpulseFactor","FRM_1/pitch_des_sigstats/Kurtosis","FRM_1/pitch_des_sigstats/Mean","FRM_1/pitch_des_sigstats/PeakValue","FRM_1/pitch_des_sigstats/RMS","FRM_1/pitch_des_sigstats/SINAD","FRM_1/pitch_des_sigstats/SNR","FRM_1/pitch_des_sigstats/ShapeFactor","FRM_1/pitch_des_sigstats/Skewness","FRM_1/pitch_des_sigstats/Std","FRM_1/pitch_des_sigstats/THD","FRM_1/yaw_des_sigstats/ClearanceFactor","FRM_1/yaw_des_sigstats/CrestFactor","FRM_1/yaw_des_sigstats/ImpulseFactor","FRM_1/yaw_des_sigstats/Kurtosis","FRM_1/yaw_des_sigstats/Mean","FRM_1/yaw_des_sigstats/PeakValue","FRM_1/yaw_des_sigstats/RMS","FRM_1/yaw_des_sigstats/SINAD","FRM_1/yaw_des_sigstats/SNR","FRM_1/yaw_des_sigstats/ShapeFactor","FRM_1/yaw_des_sigstats/Skewness","FRM_1/yaw_des_sigstats/Std","FRM_1/yaw_des_sigstats/THD","FRM_1/vn_sigstats/ClearanceFactor","FRM_1/vn_sigstats/CrestFactor","FRM_1/vn_sigstats/ImpulseFactor","FRM_1/vn_sigstats/Kurtosis","FRM_1/vn_sigstats/Mean","FRM_1/vn_sigstats/PeakValue","FRM_1/vn_sigstats/RMS","FRM_1/vn_sigstats/SINAD","FRM_1/vn_sigstats/SNR","FRM_1/vn_sigstats/ShapeFactor","FRM_1/vn_sigstats/Skewness","FRM_1/vn_sigstats/Std","FRM_1/vn_sigstats/THD","FRM_1/ve_sigstats/ClearanceFactor","FRM_1/ve_sigstats/CrestFactor","FRM_1/ve_sigstats/ImpulseFactor","FRM_1/ve_sigstats/Kurtosis","FRM_1/ve_sigstats/Mean","FRM_1/ve_sigstats/PeakValue","FRM_1/ve_sigstats/RMS","FRM_1/ve_sigstats/SINAD","FRM_1/ve_sigstats/SNR","FRM_1/ve_sigstats/ShapeFactor","FRM_1/ve_sigstats/Skewness","FRM_1/ve_sigstats/Std","FRM_1/ve_sigstats/THD","FRM_1/vd_sigstats/ClearanceFactor","FRM_1/vd_sigstats/CrestFactor","FRM_1/vd_sigstats/ImpulseFactor","FRM_1/vd_sigstats/Kurtosis","FRM_1/vd_sigstats/Mean","FRM_1/vd_sigstats/PeakValue","FRM_1/vd_sigstats/RMS","FRM_1/vd_sigstats/SINAD","FRM_1/vd_sigstats/SNR","FRM_1/vd_sigstats/ShapeFactor","FRM_1/vd_sigstats/Skewness","FRM_1/vd_sigstats/Std","FRM_1/vd_sigstats/THD","FRM_1/vibe_x_sigstats/ClearanceFactor","FRM_1/vibe_x_sigstats/CrestFactor","FRM_1/vibe_x_sigstats/ImpulseFactor","FRM_1/vibe_x_sigstats/Kurtosis","FRM_1/vibe_x_sigstats/Mean","FRM_1/vibe_x_sigstats/PeakValue","FRM_1/vibe_x_sigstats/RMS","FRM_1/vibe_x_sigstats/SINAD","FRM_1/vibe_x_sigstats/SNR","FRM_1/vibe_x_sigstats/ShapeFactor","FRM_1/vibe_x_sigstats/Skewness","FRM_1/vibe_x_sigstats/Std","FRM_1/vibe_x_sigstats/THD","FRM_1/vibe_y_sigstats/ClearanceFactor","FRM_1/vibe_y_sigstats/CrestFactor","FRM_1/vibe_y_sigstats/ImpulseFactor","FRM_1/vibe_y_sigstats/Kurtosis","FRM_1/vibe_y_sigstats/Mean","FRM_1/vibe_y_sigstats/PeakValue","FRM_1/vibe_y_sigstats/RMS","FRM_1/vibe_y_sigstats/SINAD","FRM_1/vibe_y_sigstats/SNR","FRM_1/vibe_y_sigstats/ShapeFactor","FRM_1/vibe_y_sigstats/Skewness","FRM_1/vibe_y_sigstats/Std","FRM_1/vibe_y_sigstats/THD","FRM_1/vibe_z_sigstats/ClearanceFactor","FRM_1/vibe_z_sigstats/CrestFactor","FRM_1/vibe_z_sigstats/ImpulseFactor","FRM_1/vibe_z_sigstats/Kurtosis","FRM_1/vibe_z_sigstats/Mean","FRM_1/vibe_z_sigstats/PeakValue","FRM_1/vibe_z_sigstats/RMS","FRM_1/vibe_z_sigstats/SINAD","FRM_1/vibe_z_sigstats/SNR","FRM_1/vibe_z_sigstats/ShapeFactor","FRM_1/vibe_z_sigstats/Skewness","FRM_1/vibe_z_sigstats/Std","FRM_1/vibe_z_sigstats/THD","FRM_1/acc_x_ps_spec/PeakAmp1","FRM_1/acc_x_ps_spec/PeakFreq1","FRM_1/acc_x_ps_spec/BandPower","FRM_1/acc_y_ps_spec/PeakAmp1","FRM_1/acc_y_ps_spec/PeakFreq1","FRM_1/acc_y_ps_spec/BandPower","FRM_1/acc_z_ps_spec/PeakAmp1","FRM_1/acc_z_ps_spec/PeakFreq1","FRM_1/acc_z_ps_spec/BandPower","FRM_1/gyr_x_ps_spec/PeakAmp1","FRM_1/gyr_x_ps_spec/PeakFreq1","FRM_1/gyr_x_ps_spec/BandPower","FRM_1/gyr_y_ps_spec/PeakAmp1","FRM_1/gyr_y_ps_spec/PeakFreq1","FRM_1/gyr_y_ps_spec/BandPower","FRM_1/gyr_z_ps_spec/PeakAmp1","FRM_1/gyr_z_ps_spec/PeakFreq1","FRM_1/gyr_z_ps_spec/BandPower"];
featureTable = readFeatureTable(outputEnsemble,"FRM_1",'Features',selectedFeatureNames,'ConditionVariables',outputEnsemble.ConditionVariables,'IncludeMemberID',true);

% Set SelectedVariables to select variables to read from the ensemble.
outputEnsemble.SelectedVariables = unique([outputEnsemble.DataVariables;outputEnsemble.ConditionVariables;outputEnsemble.IndependentVariables],'stable');

% Gather results into a table.
if nargout > 1
    outputTable = readall(outputEnsemble);
end
end
