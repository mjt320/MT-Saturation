clear; close all;

%% set up paths
procRoot='/ISIS/proc5';
addpath('/usr/local/spm/spm12'); %path to SPM
addpath([procRoot '/software/GitHub/utilities']); %path to utility functions
addpath([procRoot '/software/GitHub/MT-Saturation']); %path to MTSat functions
addpath([procRoot '/software/GitHub/T2Star']); %path to T2Star fitting functions

%% set parameters
opts.seriesMT=7; %series numbers (series dicom directory should simply be either e.g. 23 or 23_MTImage)
opts.seriesT1=9;
opts.seriesPD=8;
opts.thresholdPD=300; %if PD intensity (sum over echoes) is less than this then output will be NaN for all MT parameter maps
opts.dicomExamDir='./dicom'; %exam dicom directory
opts.outputDir='./results_R2s_linear'; %output directory for parameter maps

opts.R2s_fit=[1 1 1]; % (for R2* mapping) which echoes to fit (optional argument)
opts.R2s_threshold1=40; % (for R2* mapping) exclude voxels where first echo is less intense than this (avoid fitting voxels in air)
opts.R2s_threshold2=40; % (for R2* mapping) exclude echoes from fitting if less intense than this (avoid fitting noisy data points)
opts.R2s_fittingMode='nonlinear'; % optional argument to specify linear versus non-linear fitting

%% run pipeline steps
MTSat_convert_reg(opts); %convert from dicom to nii, sum signal over echoes, co-register to PD image
MTSat_create_maps(opts); %calculate MTSat and other parameter maps
MTSat_create_R2s_map(opts); %use multi-echo PD acquisition to estimate R2* maps

%% save settings
save('./options','opts'); 
