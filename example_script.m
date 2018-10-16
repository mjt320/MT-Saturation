clear; close all;

%% set up paths
procRoot='/ISIS/proc5/mthripp1';
addpath('/usr/local/spm/spm12');
addpath([procRoot '/software/GitHub/utilities']);
addpath([procRoot '/software/GitHub/MT-Saturation']);

%% set parameters
opts.seriesMT=7; %series numbers (series dicom directory should simply be either e.g. 23 or 23_MTImage)
opts.seriesT1=9;
opts.seriesPD=8;
opts.thresholdPD=300; %if PD intensity (sum over echoes) is less than this then output will be NaN for all parameter maps
opts.dicomExamDir=['./dicom']; %exam dicom directory
opts.outputDir='./results'; %output directory for parameter maps

%% run pipeline steps
MTSat_convert_reg(opts); %convert from dicom to nii, sum signal over echoes, co-register to PD image
MTSat_create_maps(opts); %calculate MTSat and other parameter maps

%% save settings
save('./options','opts'); 
