function SPM0_Initialise(indir, outdir, subjects, varargin)
%SPM0_INITIALISE

%--------------------------------------------------------------------------
% Initialise inputs
p = inputParser;
p.addRequired('indir', @ischar)
p.addRequired('outdir', @ischar)
p.addRequired('subjects', @isstruct)


p.addParameter('funcdir', 'func', @ischar)
p.addParameter('anatdir', 'anat', @ischar)
p.addParameter('ses','ses-1', @ischar)
p.addParameter('derdir', 'derivatives', @ischar)
p.addParameter('prepdir', 'SPM_prepro', @ischar)


p.parse(indir, outdir, subjects, varargin{:})
Arg = p.Results;

%% Loop to copy raw_data to derivatives folder per subject
for sbji = 1:size(subjects, 1)
    disp(subjects(sbji).name)
    sub_path_func_rw = fullfile(indir, subjects(sbji).name, Arg.ses,Arg.funcdir);
    sub_path_anat_rw = fullfile(indir, subjects(sbji).name, Arg.ses,Arg.anatdir);
    sub_path_func_der = fullfile(outdir, subjects(sbji).name,  Arg.ses, Arg.derdir, Arg.prepdir,Arg.funcdir);
    sub_path_anat_der = fullfile(outdir, subjects(sbji).name, Arg.ses,Arg.derdir, Arg.prepdir,Arg.anatdir);
    
    %Unzip func & anat scans
    gz_func=dir(fullfile(sub_path_func_rw,'sub*.nii.gz'));gunzip(fullfile(sub_path_func_rw,gz_func.name))
    gz_anat=dir(fullfile(sub_path_anat_rw,'sub*.nii.gz'));gunzip(fullfile(sub_path_anat_rw,gz_anat.name))
    
    
    % Copy func scans
    
    srcfile_func= dir(fullfile(sub_path_func_rw, '*rest*.nii'));
    
    if ~isfolder(sub_path_func_der)
        mkdir(sub_path_func_der)
    end
    if ~exist(fullfile(sub_path_func_der, srcfile_func.name), 'file')
        copyfile(fullfile(srcfile_func.folder, srcfile_func.name), sub_path_func_der)
    end
    


%Copy T1 scans

srcfile_anat_T1 = dir(fullfile(sub_path_anat_rw, '*roT1w*.nii'));

if ~isfolder(sub_path_anat_der)
    mkdir(sub_path_anat_der)
end

for sf = 1:length(srcfile_anat_T1)
    if ~exist(fullfile(sub_path_anat_der, srcfile_anat_T1(sf).name), 'file')
        copyfile(fullfile(srcfile_anat_T1(sf).folder, srcfile_anat_T1(sf).name), sub_path_anat_der)
    end
end

% Copy reorient file to func folder

srcfile_anat_reorient = dir(fullfile(sub_path_anat_rw, '*reorient*.mat'));
if ~exist(fullfile(sub_path_func_der, srcfile_anat_reorient.name), 'file')
    copyfile(fullfile(srcfile_anat_reorient.folder, srcfile_anat_reorient.name), sub_path_func_der)
end

% %Copy lesion scans
% if strcmp(Arg.ses,'ses-001')
%     if ~strcmp(subjects(sbji).name,'sub-24') && ~strcmp(subjects(sbji).name,'sub-31') && ~strcmp(subjects(sbji).name,'sub-32') && ~strcmp(subjects(sbji).name,'sub-33') && ~strcmp(subjects(sbji).name,'sub-35')
%         srcfile_anat_les = dir(fullfile(sub_path_anat_rw, '*roLESION.nii'));
%     end
% elseif strcmp(Arg.ses,'ses-002')
%     if ~strcmp(subjects(sbji).name,'sub-24') && ~strcmp(subjects(sbji).name,'sub-27') && ~strcmp(subjects(sbji).name,'sub-31') && ~strcmp(subjects(sbji).name,'sub-32') && ~strcmp(subjects(sbji).name,'sub-33') && ~strcmp(subjects(sbji).name,'sub-35')
%         srcfile_anat_les = dir(fullfile(sub_path_anat_rw, '*roLESION.nii'));
%     elseif  strcmp(Arg.ses,'ses-002') && strcmp(subjects(sbji).name,'sub-27')
%         srcfile_anat_les = dir(fullfile(sub_path_anat_rw, '*roLESION_v.nii'));
%     end
% elseif  strcmp(Arg.ses,'ses-003')
%     if ~strcmp(subjects(sbji).name,'sub-24') && ~strcmp(subjects(sbji).name,'sub-25') && ~strcmp(subjects(sbji).name,'sub-27') && ~strcmp(subjects(sbji).name,'sub-31') && ~strcmp(subjects(sbji).name,'sub-32') && ~strcmp(subjects(sbji).name,'sub-33') && ~strcmp(subjects(sbji).name,'sub-35')
%         srcfile_anat_les = dir(fullfile(sub_path_anat_rw, '*roLESION.nii'));
%     elseif strcmp(Arg.ses,'ses-003') && strcmp(subjects(sbji).name,'sub-25') || strcmp(subjects(sbji).name,'sub-27')
%         srcfile_anat_les = dir(fullfile(sub_path_anat_rw, '*roLESION_v.nii'));
%     end
% end
% 
% if exist('srcfile_anat_les','var')
%     for sf = 1:length(srcfile_anat_les)
%         if ~exist(fullfile(sub_path_anat_der, srcfile_anat_les(sf).name), 'file')
%             copyfile(fullfile(srcfile_anat_les(sf).folder, srcfile_anat_les(sf).name), sub_path_anat_der)
%         end
%     end
% end
% 
% clear srcfile_anat_les

end
%----------------------------------------------------
% Initialise SPM
spm('Defaults', 'fMRI')
spm_jobman('initcfg')
end
