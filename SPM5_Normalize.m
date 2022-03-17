function SPM5_Normalize(subjects,outdir,varargin)
%SPM5_NORMALIZE

%--------------------------------------------------------------------------
% Initialise inputs and pathnames
p = inputParser;
p.addRequired('subjects', @isstruct)
p.addRequired('outdir', @ischar)

p.addParameter('ses','ses-1', @ischar)
p.addParameter('derdir', 'derivatives', @ischar)
p.addParameter('prepdir', 'SPM_prepro', @ischar)
p.addParameter('funcdir', 'func', @ischar)
p.addParameter('rdir', 'realign', @ischar)
p.addParameter('anatdir', 'anat', @ischar)
p.addParameter('segdir', 'old_seg', @ischar)
p.addParameter('normdir', 'old_norm', @ischar)

p.parse(subjects, outdir,varargin{:});
Arg = p.Results;

%% Loop for subjects
for sbj =1:size(subjects, 1)
    disp(subjects(sbj).name)
    sub_path= fullfile(outdir, subjects(sbj).name, Arg.ses, Arg.derdir, Arg.prepdir);
    %% copy reoriented EPIs
    sub_path_func_src= fullfile(outdir, subjects(sbj).name, Arg.ses,Arg.derdir, Arg.prepdir, Arg.funcdir, Arg.rdir);
    sub_path_func_dest= fullfile(outdir, subjects(sbj).name, Arg.ses,Arg.derdir, Arg.prepdir, Arg.funcdir, Arg.normdir);
    srcfile_func= dir(fullfile(sub_path_func_src, 'rrosub*.nii'));
    
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
    roEPI_rest = dir (fullfile(sub_path_func_dest,'rrosub*.nii'));
    roEPI_rest_name= extractfield(roEPI_rest,'name')';
    matrix = spm_select('FPList', fullfile(sub_path, Arg.anatdir, Arg.segdir), 'seg_sn.*\.mat$');
    
    
    %% Run Old normalise
    clear matlabbatch
    matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {matrix};
    for n = 1:numel(roEPI_rest_name)
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample{n,1} =(fullfile(sub_path_func_dest,roEPI_rest(n).name));
    end
    matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0;
    matlabbatch{1}.spm.spatial.normalise.write.roptions.bb =[-78 -112 -65
        78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
    matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
    
    spm_jobman('run', matlabbatch)
    %% Loop to remove raw_data from new per-subject folder
    for rawi = 1:length(subjects(sbj).sourcesfunc)
        rwdt = fullfile(subjects(sbj).sourcesfunc(rawi).folder...
            , subjects(sbj).sourcesfunc(rawi).name);
        if exist(rwdt, 'file'), delete(rwdt); end
    end
end
end


