function SPM3_Coregistration(subjects,outdir,varargin)
%SPM3_COREGISTRATION

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
p.addParameter('rdir', 'realign', @ischar)

p.parse(subjects,outdir,varargin{:});
Arg = p.Results;

for sbj = 1:size(subjects, 1)
    disp(subjects(sbj).name)
    sub_path= fullfile(outdir, subjects(sbj).name, Arg.ses, Arg.derdir, Arg.prepdir);
    
    romeanEPI = spm_select('FPList', fullfile(sub_path, Arg.funcdir, Arg.rdir), '^meanro.*\.nii$');
    roT1 = spm_select('FPList', fullfile(sub_path, Arg.anatdir), '^*roT1w.*\.nii$');
    
        clear matlabbatch
        %% Coregistration
        matlabbatch{1}.spm.spatial.coreg.estimate.ref = {romeanEPI};
        matlabbatch{1}.spm.spatial.coreg.estimate.source ={roT1};% {deblank(roT1(2,:))}; % if run on Windows/Linux Platform change to  {roT1};
        matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    
    spm_jobman('run',matlabbatch)
    
    ps_file=['spm_',datestr(now, 'yyyymmmdd'),'.ps'];
    if ~exist(fullfile(sub_path, Arg.anatdir,ps_file),'file')
        movefile(fullfile(pwd,ps_file),fullfile(sub_path, Arg.anatdir,['coreg' ps_file]))
    end
    
end
