function pipeline_MTSat_convert_reg(opts)
%convert data from dicom to nii
%then co-register images

%% create output directory or delete any existing contents
mkdir(opts.outputDir); delete([opts.outputDir '/*.*']);

%% initialise variables
acqPars.TR_PD=nan;
acqPars.TR_T1=nan;
acqPars.TR_MT=nan;
acqPars.a_PD=nan;
acqPars.a_T1=nan;
acqPars.a_MT=nan;
acqPars.aDeg_PD=nan;
acqPars.aDeg_T1=nan;
acqPars.aDeg_MT=nan;

seriesNos = [opts.seriesPD opts.seriesT1 opts.seriesMT];
seriesNames= {'PD' 'T1' 'MT'};
TR=nan(1,3);
aDeg=nan(1,3);

%% for each series convert dicoms and record acquisition parameters
for iSeries=1:3
    
    %% look for series directory in specified exam directory
    temp2=dir([opts.dicomExamDir '/']);
    temp3=~cellfun(@isempty,regexp({temp2.name},['^' num2str(seriesNos(iSeries)) '_'])) | strcmp({temp2.name},num2str(seriesNos(iSeries))); %look for directories names 'iSeries' or beginning with 'iSeries_'
    if sum(temp3)~=1; error('Cannot find single unique dicom directory for this series.'); end
    dicomDir=[opts.dicomExamDir '/' temp2(temp3).name];
    
    %% look for dicom files
    dicomPaths=getMultipleFilePaths([dicomDir '/*.dcm']);
    if isempty(dicomPaths); dicomPaths=getMultipleFilePaths([dicomDir '/*.IMA']); end;
    if isempty(dicomPaths); error(['No dicoms found in ' dicomDir]); end;
    
    %% get acquisition parameters from one of the dicom headers
    temp=dicominfo(dicomPaths{1});
    TR(iSeries)=0.001*temp.RepetitionTime;
    aDeg(iSeries)=temp.FlipAngle;
    
    %% convert dicoms to 3D niftis using dcm2niix
    system(['dcm2niix -f ' seriesNames{iSeries} '_echo%e -t n -v n -o ' opts.outputDir ' ' dicomDir]);
    
    %% sum signal over all echoes
    temp=dir([opts.outputDir '/' seriesNames{iSeries} '*.nii']); NEchoes=size(temp,1);
    str1=['fslmaths ' opts.outputDir '/' seriesNames{iSeries} '_echo1'];
    str2=['fslmerge -t ' opts.outputDir '/' seriesNames{iSeries} '_allEchoes ' opts.outputDir '/' seriesNames{iSeries} '_echo1'];
    for iEcho=2:NEchoes;
        str1=[str1 ' -add ' opts.outputDir '/' seriesNames{iSeries} '_echo' num2str(iEcho)];
        str2=[str2 ' ' opts.outputDir '/' seriesNames{iSeries} '_echo' num2str(iEcho)];
    end
    str1=[str1 ' ' opts.outputDir '/' seriesNames{iSeries}];
    system(str1); %sum echoes using fslmaths
    system(str2); %combine echoes into 4D nii using fslmerge
end

%% assign acquisition parametesr to acqPars struct
[acqPars.TR_PD,acqPars.TR_T1,acqPars.TR_MT]=deal(TR(1),TR(2),TR(3));
[acqPars.aDeg_PD,acqPars.aDeg_T1,acqPars.aDeg_MT]=deal(aDeg(1),aDeg(2),aDeg(3));
[acqPars.a_PD,acqPars.a_T1,acqPars.a_MT]=deal(aDeg(1)*((2*pi)/360),aDeg(2)*((2*pi)/360),aDeg(3)*((2*pi)/360));


%% display acquisition parameters
disp(['PD: TR=' num2str(acqPars.TR_PD) ' aDeg=' num2str(acqPars.aDeg_PD) ' a (rads)=' num2str(acqPars.a_PD) ]);
disp(['T1: TR=' num2str(acqPars.TR_T1) ' aDeg=' num2str(acqPars.aDeg_T1) ' a (rads)=' num2str(acqPars.a_T1) ]);
disp(['MT: TR=' num2str(acqPars.TR_MT) ' aDeg=' num2str(acqPars.aDeg_MT) ' a (rads)=' num2str(acqPars.a_MT) ]);

save([opts.outputDir '/acqPars'],'acqPars');

%% co-register images to PD scan using FLIRT, then merge all 3 images into 4D image
refFile=[opts.outputDir '/PD.nii'];
system([ 'flirt -in ' opts.outputDir '/T1.nii -ref ' refFile ' -out ' opts.outputDir '/reg_T1' ' -omat ' opts.outputDir '/T12PD.txt -dof 6 -cost normmi']); %FLIRT
system([ 'flirt -in ' opts.outputDir '/MT.nii -ref ' refFile ' -out ' opts.outputDir '/reg_MT' ' -omat ' opts.outputDir '/MT2PD.txt -dof 6 -cost normmi']); %FLIRT
system([ 'fslmerge -t ' opts.outputDir '/reg_4D ' opts.outputDir '/PD ' opts.outputDir '/reg_MT ' opts.outputDir '/reg_T1']);

%% change all files to NII type
fslchfiletype_all([opts.outputDir '/*.nii.gz'],'NIFTI'); %change file type to NII

end