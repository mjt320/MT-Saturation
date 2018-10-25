function MTSat_create_R2s_map(opts)

load([opts.outputDir '/acqPars']);

mkdir(opts.outputDir); delete([opts.outputDir '/*R2s*.*']);

if ~isfield(opts,'R2s_fit'); opts.R2s_fit=ones(1,acqPars.NEchoes); end %if opts.fit not specified, fit all data
if ~isfield(opts,'R2s_fittingMode'); options.R2s_fittingMode='nonlinear'; end

%% load 4D magnitude data
[magnitudePD,xyz]=spm_read_vols(spm_vol([opts.outputDir '/PD_allEchoes.nii']));

%% initialise output arrays
volTemplate=spm_vol([opts.outputDir '/PD.nii']); %use this header as template for 3D output files
R2s=nan(volTemplate.dim); S0=nan(volTemplate.dim); T2s=nan(volTemplate.dim); RSq=nan(volTemplate.dim); model=nan([volTemplate.dim sum(opts.R2s_fit,2)]);

%% do the fitting
for i3=1:size(magnitudePD,3); for i1=1:size(magnitudePD,1); for i2=30%1:size(magnitudePD,2) %loop through voxels
            
            [S0(i1,i2,i3),R2s(i1,i2,i3),T2s(i1,i2,i3),RSq(i1,i2,i3),model(i1,i2,i3,:)] = ...
                fit_R2s(acqPars.TE_PD_s.',magnitudePD(i1,i2,i3,:),opts.R2s_fit,opts.R2s_threshold1,opts.R2s_threshold2,struct('mode',opts.R2s_fittingMode));
            
        end;
    end;
    disp([num2str(i3) '/' num2str(size(magnitudePD,3))]);
end;

%% write output images
SPMWrite4D(volTemplate,model,opts.outputDir,'model',16);
SPMWrite4D(volTemplate,magnitudePD(:,:,:,opts.R2s_fit==1),opts.outputDir,'signal',16);

paramNames={'S0_R2s' 'R2s' 'T2s' 'RSq_R2s'};
outputs={S0 R2s T2s RSq};

for iOutput=1:size(outputs,2)
    SPMWrite4D(volTemplate,outputs{iOutput},opts.outputDir,paramNames{iOutput},16);
end

end