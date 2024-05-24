clear all
%% Initialise inputs, pathnames 
indir = '/Volumes/LASA/TBI_OpenNeuro/TBI_openneuro/data/';
outdir = '/Volumes/LASA/TBI_OpenNeuro/TBI_openneuro/data/derivatives/data/';
code_path='/Volumes/LASA/TBI_project/Shared_code/TBI_preprocessing_openneuro/';
addpath(code_path)
addpath(fullfile(code_path,'utils'))
cd(indir)
hc_subjects=dir('sub-control*');

%% Build datasets for multiple sessions
s1=1;s2=1;s3=1;
for sbji =1:size(hc_subjects, 1)
    sub_path=fullfile(hc_subjects(sbji).folder, hc_subjects(sbji).name);
    ses=dirflt(sub_path);
    ses=ses(3:4);% just for MAC!!
    if numel(ses)==2
        if ismember({ses(1).name}, {'ses-1'})
            Idx_s1(s1,1)=sbji;
            s1=s1+1;
        end
        if ismember({ses(2).name}, {'ses-2'})
            Idx_s2(s2,1)=sbji; 
            s2=s2+1;
        end
    end
end
   
subjects_s1=hc_subjects(Idx_s1); subjects_s2=hc_subjects(Idx_s2); 

% Do preprocess
% SPM0_Initialise(indir, outdir, subjects_s2(1:end))
SPM_prepro_wrapper(subjects_s1(4:end),outdir)
