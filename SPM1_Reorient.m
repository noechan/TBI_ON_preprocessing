function SPM2_Reorient(subjects,outdir,varargin)
%SPM2_REORIENT

%--------------------------------------------------------------------------
% Initialise inputs and pathnames
p = inputParser;
p.addRequired('subjects', @isstruct)
p.addRequired('outdir', @ischar)

p.addParameter('ses','ses-1', @ischar)
p.addParameter('derdir', 'derivatives', @ischar)
p.addParameter('prepdir', 'SPM_prepro', @ischar)
p.addParameter('funcdir', 'func', @ischar)
p.addParameter('rodir', 'reorient', @ischar)

p.parse(subjects,outdir,varargin{:});
Arg = p.Results;


%% Loop for subjects
for sbj = 1:size(subjects, 1)
    disp(subjects(sbj).name)
    sub_path = fullfile(outdir, subjects(sbj).name, Arg.ses, Arg.derdir, Arg.prepdir, Arg.funcdir);
    
    srcfile_func= dir(fullfile(sub_path,'*rest*.nii'));
    
    if ~isfolder(fullfile(sub_path, Arg.rodir))
        mkdir(fullfile(sub_path, Arg.rodir))
    end
    
    if ~exist(fullfile(sub_path,Arg.rodir, srcfile_func.name), 'file')
        copyfile(fullfile(srcfile_func.folder, srcfile_func.name), fullfile(sub_path, Arg.rodir))
    end
    
% Split func scans to reorient folder and remove raw data from this folder
spm_file_split(fullfile(sub_path, Arg.rodir,srcfile_func.name), fullfile(sub_path, Arg.rodir));
rwdt = fullfile(sub_path, Arg.rodir,srcfile_func.name);
if exist(rwdt, 'file'), delete(rwdt); end

    %Prepare inputs
    EPI_rest = dir (fullfile(sub_path,Arg.rodir,'sub*.nii'));
    EPI_rest_name= extractfield(EPI_rest,'name')';
    matrix = load(fullfile(sub_path,'reorient.mat'));
    
    clear matlabbatch
    % Reorient images to AC
    for n = 1:numel(EPI_rest_name)
        matlabbatch{n}.spm.util.reorient.srcfiles = {fullfile(sub_path,Arg.rodir,EPI_rest(n).name)};
        matlabbatch{n}.spm.util.reorient.transform.transM = matrix.M;
        matlabbatch{n}.spm.util.reorient.prefix = 'ro';
    end
    spm_jobman('run', matlabbatch)
    
    % Loop to remove input data
    for in = 1:numel(EPI_rest_name)
        indt =fullfile(sub_path,Arg.rodir,EPI_rest(in).name);
        if exist(indt, 'file'), delete(indt); end
    end
end
end

