function MTSat_create_maps(opts)
%% generate MTSat (and other parameter) images from coregistered nii files

%% load acquisition parameters, delete existing parameter maps
load([opts.outputDir '/acqPars'],'acqPars');
delete([opts.outputDir '/delta_app.*']); delete([opts.outputDir '/A_app.*']); delete([opts.outputDir '/MTR.*']); delete([opts.outputDir '/T1_app.*']); delete([opts.outputDir '/R1_app.*']);

%% load 4D magnitude data
[S_PD,xyz]=spm_read_vols(spm_vol([opts.outputDir '/PD.nii']));
[S_MT,xyz]=spm_read_vols(spm_vol([opts.outputDir '/reg_MT.nii']));
[S_T1,xyz]=spm_read_vols(spm_vol([opts.outputDir '/reg_T1.nii']));

%% initialise output arrays
volTemplate=spm_vol([opts.outputDir '/PD.nii']); %use this header as template for 3D output files
R1_app=nan(volTemplate.dim); A_app=nan(volTemplate.dim); MTR=nan(volTemplate.dim); delta_app=nan(volTemplate.dim);
T1_app=nan(volTemplate.dim);

%% Calculate output parameters
a_PD=acqPars.a_PD; a_T1=acqPars.a_T1; a_MT=acqPars.a_MT;
TR_PD=acqPars.TR_PD; TR_T1=acqPars.TR_T1;

A_app =...
    ( S_T1 .* (S_PD*TR_T1*a_PD^2 - S_PD.*TR_PD*a_T1^2) ) ./ ...
    ( a_PD*a_T1 * (S_PD*TR_T1*a_PD - S_T1*TR_PD*a_T1) );

R1_app =...
    -( a_PD*a_T1 * (S_PD*TR_T1*a_PD - S_T1*TR_PD*a_T1) ) ./ ...
    ( 2*TR_T1*TR_PD * (S_PD*a_T1 - S_T1*a_PD) );

delta_app = - (a_PD^2)/2 + (A_app.*R1_app*TR_PD*a_PD)./S_MT - R1_app*TR_PD;

MTR = 100 * ((S_PD - S_MT) ./ S_PD);

T1_app = 1./R1_app;

%% apply threshold, write output images
paramNames={'A_app' 'R1_app' 'delta_app' 'MTR' 'T1_app'};
outputs={A_app R1_app delta_app MTR T1_app};
for iOutput=1:size(outputs,2)
    outputs{iOutput}(S_PD<opts.thresholdPD)=nan;
    SPMWrite4D(volTemplate,outputs{iOutput},opts.outputDir,paramNames{iOutput},16);
end

%% delete superfluous images
delete([opts.outputDir '/MT_echo*.*']);
delete([opts.outputDir '/T1_echo*.*']);
delete([opts.outputDir '/PD_echo*.*']);

end
