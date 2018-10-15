clear; close all;

%% set up paths
rawDataRoot='/ISIS/procB/BRIC2_dicom/MR';
procRoot='/ISIS/proc5/mthripp1';
addpath('/usr/local/spm/spm12');
addpath([procRoot '/software/GitHub/utilities']);
addpath([procRoot '/software/GitHub/MT-Saturation']);

%% set parameters
opts.seriesMT=2; %series numbers (series dicom directory should simply be either e.g. 23 or 23_MTImage)
opts.seriesT1=4;
opts.seriesPD=3;
opts.thresholdPD=50; %if PD intensity (sum over echoes) is less than this then output will be NaN for all parameter maps
opts.dicomExamDir=[rawDataRoot '/MSDev/MT_phantom_20170214_145924.839000']; %exam dicom directory
opts.outputDir='./results'; %output directory for parameter maps

%% run pipeline steps
MTSat_convert_reg(opts); %convert from dicom to nii, sum signal over echoes, co-register to PD image
MTSat_create_maps(opts); %calculate MTSat and other parameter maps

%% save settings
save('./options','opts'); 
