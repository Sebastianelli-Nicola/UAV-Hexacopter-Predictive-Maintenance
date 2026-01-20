%% Initialization
clear all
clc

%% Dataset extraction

% List of data files
filelist=["NO_FAULT1.mat","NO_FAULT2.mat","NO_FAULT3.mat","NO_FAULT4.mat","NO_FAULT5.mat","NO_FAULT6.mat",...
    "FAULT_M1_5.mat","FAULT_M2_5.mat","FAULT_M3_5.mat","FAULT_M4_5.mat","FAULT_M5_5.mat","FAULT_M6_5.mat",...
    "FAULT_M1_10.mat","FAULT_M2_10.mat","FAULT_M3_10.mat","FAULT_M4_10.mat","FAULT_M5_10.mat","FAULT_M6_10.mat"];
nFiles=length(filelist);

% Synchronization method
% syncmethod="resampling";
syncmethod="zero_order_hold";

% Desired sync rate
Fs = 350; 
datalist=cell(1,nFiles);
for i = 1:nFiles
    datalist{i} = synchronize(filelist(i),syncmethod,Fs);
end

%% Creation of a single timetable "dataTable"
dataTable = table('Size', [nFiles 0]);

for i = 1:nFiles
    % Extraction
    data = datalist{i};
    acc_x = data.IMU.ACC_sync(:,1);
    acc_y = data.IMU.ACC_sync(:,2);
    acc_z = data.IMU.ACC_sync(:,3);
    gyr_x = data.IMU.GYR_sync(:,1);
    gyr_y = data.IMU.GYR_sync(:,2);
    gyr_z = data.IMU.GYR_sync(:,3);
    pwm_1 = data.PWM_sync(:,1);
    pwm_2 = data.PWM_sync(:,2);
    pwm_3 = data.PWM_sync(:,3);
    pwm_4 = data.PWM_sync(:,4);
    pwm_5 = data.PWM_sync(:,5);
    pwm_6 = data.PWM_sync(:,6);
    esc_1 = data.ESC.RPM0_sync(:);
    esc_2 = data.ESC.RPM1_sync(:);
    esc_3 = data.ESC.RPM2_sync(:);
    esc_4 = data.ESC.RPM3_sync(:);
    esc_5 = data.ESC.RPM4_sync(:);
    esc_6 = data.ESC.RPM5_sync(:);
    cur_1 = data.ESC.CURR0_sync(:);
    cur_2 = data.ESC.CURR1_sync(:);
    cur_3 = data.ESC.CURR2_sync(:);
    cur_4 = data.ESC.CURR3_sync(:);
    cur_5 = data.ESC.CURR4_sync(:);
    cur_6 = data.ESC.CURR5_sync(:);
    roll = data.ATTITUDE.ROLL_sync(:);
    pitch = data.ATTITUDE.PITCH_sync(:);
    yaw = data.ATTITUDE.YAW_sync(:);
    roll_des = data.ATTITUDE.DesROLL_sync(:);
    pitch_des = data.ATTITUDE.DesPITCH_sync(:);
    yaw_des = data.ATTITUDE.DesYAW_sync(:);
    vn = data.XKF1.VN_sync(:);
    ve = data.XKF1.VE_sync(:);
    vd = data.XKF1.VD_sync(:);
    vibe_x = data.VIBE.ACC_sync(:,1);
    vibe_y = data.VIBE.ACC_sync(:,2);
    vibe_z = data.VIBE.ACC_sync(:,3);
    
    % Conversion to timetable
    acc_x = array2timetable(acc_x,'SampleRate',Fs);
    acc_y = array2timetable(acc_y,'SampleRate',Fs);
    acc_z = array2timetable(acc_z,'SampleRate',Fs);
    gyr_x = array2timetable(gyr_x,'SampleRate',Fs);
    gyr_y = array2timetable(gyr_y,'SampleRate',Fs);
    gyr_z = array2timetable(gyr_z,'SampleRate',Fs);
    pwm_1 = array2timetable(pwm_1,'SampleRate',Fs);
    pwm_2 = array2timetable(pwm_2,'SampleRate',Fs);
    pwm_3 = array2timetable(pwm_3,'SampleRate',Fs);
    pwm_4 = array2timetable(pwm_4,'SampleRate',Fs);
    pwm_5 = array2timetable(pwm_5,'SampleRate',Fs);
    pwm_6 = array2timetable(pwm_6,'SampleRate',Fs);
    esc_1 = array2timetable(esc_1,'SampleRate',Fs);
    esc_2 = array2timetable(esc_2,'SampleRate',Fs);
    esc_3 = array2timetable(esc_3,'SampleRate',Fs);
    esc_4 = array2timetable(esc_4,'SampleRate',Fs);
    esc_5 = array2timetable(esc_5,'SampleRate',Fs);
    esc_6 = array2timetable(esc_6,'SampleRate',Fs);
    cur_1 = array2timetable(cur_1,'SampleRate',Fs);
    cur_2 = array2timetable(cur_2,'SampleRate',Fs);
    cur_3 = array2timetable(cur_3,'SampleRate',Fs);
    cur_4 = array2timetable(cur_4,'SampleRate',Fs);
    cur_5 = array2timetable(cur_5,'SampleRate',Fs);
    cur_6 = array2timetable(cur_6,'SampleRate',Fs);
    roll = array2timetable(roll,'SampleRate',Fs);
    pitch = array2timetable(pitch,'SampleRate',Fs);
    yaw = array2timetable(yaw,'SampleRate',Fs);
    roll_des = array2timetable(roll_des,'SampleRate',Fs);
    pitch_des = array2timetable(pitch_des,'SampleRate',Fs);
    yaw_des = array2timetable(yaw_des,'SampleRate',Fs);
    vn = array2timetable(vn,'SampleRate',Fs);
    ve = array2timetable(ve,'SampleRate',Fs);
    vd = array2timetable(vd,'SampleRate',Fs);
    vibe_x = array2timetable(vibe_x,'SampleRate',Fs);
    vibe_y = array2timetable(vibe_y,'SampleRate',Fs);
    vibe_z = array2timetable(vibe_z,'SampleRate',Fs);
    
    % Ensemble
    dataTable.acc_x(i) = {acc_x};
    dataTable.acc_y(i) = {acc_y};
    dataTable.acc_z(i) = {acc_z};
    dataTable.gyr_x(i) = {gyr_x};
    dataTable.gyr_y(i) = {gyr_y};
    dataTable.gyr_z(i) = {gyr_z};
    dataTable.pwm_1(i) = {pwm_1};
    dataTable.pwm_2(i) = {pwm_2};
    dataTable.pwm_3(i) = {pwm_3};
    dataTable.pwm_4(i) = {pwm_4};
    dataTable.pwm_5(i) = {pwm_5};
    dataTable.pwm_6(i) = {pwm_6};
    dataTable.esc_1(i) = {esc_1};
    dataTable.esc_2(i) = {esc_2};
    dataTable.esc_3(i) = {esc_3};
    dataTable.esc_4(i) = {esc_4};
    dataTable.esc_5(i) = {esc_5};
    dataTable.esc_6(i) = {esc_6};
    dataTable.cur_1(i) = {cur_1};
    dataTable.cur_2(i) = {cur_2};
    dataTable.cur_3(i) = {cur_3};
    dataTable.cur_4(i) = {cur_4};
    dataTable.cur_5(i) = {cur_5};
    dataTable.cur_6(i) = {cur_6};
    dataTable.roll(i) = {roll};
    dataTable.pitch(i) = {pitch};
    dataTable.yaw(i) = {yaw};
    dataTable.roll_des(i) = {roll_des};
    dataTable.pitch_des(i) = {pitch_des};
    dataTable.yaw_des(i) = {yaw_des};
    dataTable.vn(i) = {vn};
    dataTable.ve(i) = {ve};
    dataTable.vd(i) = {vd};
    dataTable.vibe_x(i) = {vibe_x};
    dataTable.vibe_y(i) = {vibe_y};
    dataTable.vibe_z(i) = {vibe_z};
end

%% Definition of the fault codes
fault = [0 0 0 0 0 0 5 5 5 5 5 5 10 10 10 10 10 10];
fault_cat = categorical(fault');
dataTable.faultCode(:) = fault_cat;

%% Computation of Diagnostic Feature Designer features
[feature_Table,data_feature_Table] = diagnosticFeaturesfull(dataTable);

%% Clean features by removing NaNs from features
feature_Table=standardizeMissing(feature_Table,{-Inf,Inf});
countcolumnNaNs=[zeros(1,4),sum(isnan(table2array(feature_Table(:,5:end))))];
% Remove features with more than 25% of NaNs
feature_Table(:,find(countcolumnNaNs>size(feature_Table,1)/4))=[];
% First sample: if a feature sample is NaN, replace with 0
initial=find(feature_Table.('FRM_1/TimeStart')==0);
feature_Table_tmp1 = fillmissing(feature_Table(initial,:),'constant',0,'DataVariables',@isnumeric);
feature_Table(initial,:) = feature_Table_tmp1;
% Second to last sample: if a feature sample is NaN, replace with previous value
feature_Table = fillmissing(feature_Table,'previous');

%% Split into training and testing data
rng(0)
partition=cvpartition(feature_Table.EnsembleID_,'Holdout',0.3,'Stratify',true);
idx_train = training(partition);
idx_test = test(partition);

feature_Table_Train=feature_Table(idx_train,:);
feature_Table_Test=feature_Table(idx_test,:);

%% Save data and try to reload the feature table
save data_feature_Table_zoh.mat dataTable data_feature_Table feature_Table feature_Table_Train feature_Table_Test
clear all
load data_feature_Table_zoh.mat

%%
classificationLearner(feature_Table_Train,'faultCode');
