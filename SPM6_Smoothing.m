function SPM6_Smoothing(subjects, outdir,varargin)
%SPM6_SMOOTHING

%--------------------------------------------------------------------------
% Initialise inputs and pathnames
p = inputParser;
p.addRequired('subjects', @isstruct)
p.addRequired('outdir', @ischar)

p.addParameter('ses','ses-1', @ischar)
p.addParameter('derdir', 'derivatives', @ischar)
p.addParameter('prepdir', 'SPM_prepro', @ischar)
p.addParameter('funcdir', 'func', @ischar)
p.addParameter('anatdir', 'anat', @ischar)
p.addParameter('normdir', 'old_norm', @ischar)
p.addParameter('smodir', 'smoothing_8', @ischar)

p.parse(subjects,outdir,varargin{:});
Arg = p.Results;

%% Loop for subjects
for sbj = 1:size(subjects, 1)
    disp(subjects(sbj).name)
    
    %% copy normalised EPIs
    sub_path_func_src= fullfile(outdir, subjects(sbj).name, Arg.ses,Arg.derdir, Arg.prepdir, Arg.funcdir, Arg.normdir);
    sub_path_func_dest= fullfile(outdir, subjects(sbj).name, Arg.ses,Arg.derdir, Arg.prepdir, Arg.funcdir, Arg.smodir);
    srcfile_func= dir(fullfile(sub_path_func_src, 'wrrosub*.nii'));
    
    if ~isfolder(sub_path_func_dest)
        mkdir(sub_path_func_dest)
    end
    for sf = 1:length(srcfile_func)
        if ~exist(fullfile(sub_path_func_dest, srcfile_func(sf).name), 'file')
            copyfile(fullfile(srcfile_func(sf).folder, srcfile_func(sf).name), sub_path_func_dest)
        end
    end
    [srcfile_func.folder] = deal(sub_path_func_dest);
    subjects(sbj).sourcesfunc = srcfile_func;
    
    %% Specify inputs
    wroEPI_rest = dir (fullfile(sub_path_func_dest,'wrrosub*.nii'));
    wroEPI_rest_name= extractfield(wroEPI_rest,'name')';
end

clear matlabbatch
for n = 1:numel(wroEPI_rest_name)
    matlabbatch{1}.spm.spatial.smooth.data{n,1}=(fullfile(sub_path_func_dest,wroEPI_rest(n).name));
end
matlabbatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

spm_jobman ('run', matlabbatch)

%% Loop to remove raw_data from new per-subject folder
for rawi = 1:length(subjects(sbj).sourcesfunc)
    rwdt = fullfile(subjects(sbj).sourcesfunc(rawi).folder...
        , subjects(sbj).sourcesfunc(rawi).name);
    if exist(rwdt, 'file'), delete(rwdt); end
end
end



