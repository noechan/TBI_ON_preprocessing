function SPM4_Segment(subjects,outdir,varargin)
%SPM4_SEGMENT

%--------------------------------------------------------------------------
% Initialise inputs and pathnames
p = inputParser;
p.addRequired('subjects', @isstruct)
p.addRequired('outdir', @ischar)

p.addParameter('ses','ses-1', @ischar)
p.addParameter('derdir', 'derivatives', @ischar)
p.addParameter('prepdir', 'SPM_prepro', @ischar)
p.addParameter('anatdir', 'anat', @ischar)
p.addParameter('segdir', 'old_seg', @ischar)

p.parse(subjects, outdir,varargin{:});
Arg = p.Results;

for sbj = 1:size(subjects, 1)
    disp(subjects(sbj).name)
    sub_path= fullfile(outdir, subjects(sbj).name, Arg.ses, Arg.derdir, Arg.prepdir);
    
    %% copy reoriented and coregistered T1
    sub_path_anat_src= fullfile(outdir, subjects(sbj).name, Arg.ses,Arg.derdir, Arg.prepdir, Arg.anatdir);
    sub_path_anat_dest= fullfile(outdir, subjects(sbj).name, Arg.ses,Arg.derdir, Arg.prepdir, Arg.anatdir, Arg.segdir);
    srcfile_anat_crT1= dir(fullfile(sub_path_anat_src, '*roT1w.nii'));
    
    % Copy T1 scans
    if ~isfolder(sub_path_anat_dest)
        mkdir(sub_path_anat_dest)
    end
    for sf = 1:length(srcfile_anat_crT1)
        if ~exist(fullfile(sub_path_anat_dest, srcfile_anat_crT1(sf).name), 'file')
            copyfile(fullfile(srcfile_anat_crT1(sf).folder, srcfile_anat_crT1(sf).name), sub_path_anat_dest)
        end
    end
    [srcfile_anat_crT1.folder] = deal(sub_path_anat_dest);
    subjects(sbj).sourcesanat = srcfile_anat_crT1;
    
    clear matlabbatch
    
    cr_T1= dir (fullfile(sub_path,Arg.anatdir,'*ro*.nii'));
    clear matlabbatch
    matlabbatch{1}.spm.tools.oldseg.data = cellstr([fullfile(sub_path,Arg.anatdir,Arg.segdir,cr_T1.name) ',1']); % if run on Windows/Linux Platform change to cr_T1.name
    matlabbatch{1}.spm.tools.oldseg.output.GM = [0 0 1]; %native space
    matlabbatch{1}.spm.tools.oldseg.output.WM = [0 0 1]; %native space
    matlabbatch{1}.spm.tools.oldseg.output.CSF = [0 0 1];%native space, to calculate TIV
    matlabbatch{1}.spm.tools.oldseg.output.biascor = 1;
    matlabbatch{1}.spm.tools.oldseg.output.cleanup = 1; %light cleanup
    matlabbatch{1}.spm.tools.oldseg.opts.tpm = {
        '/Users/noeliamartinezmolina/spm12/tpm/TPM_00001.nii' %Grey TPM from SPM12 based on the IXI 555 MNI152 extracted with spm_file_split
        '/Users/noeliamartinezmolina/spm12/tpm/TPM_00002.nii' %White TPM from SPM12 based on the IXI 555 MNI152 extracted with spm_file_split
        '/Users/noeliamartinezmolina/spm12/tpm/TPM_00003.nii' %CSF TPM from SPM12 based on the IXI 555 MNI152 extracted with spm_file_split
        };
    matlabbatch{1}.spm.tools.oldseg.opts.ngaus = [2
        2
        2
        4];
    matlabbatch{1}.spm.tools.oldseg.opts.regtype = 'mni';
    matlabbatch{1}.spm.tools.oldseg.opts.warpreg = 1;
    matlabbatch{1}.spm.tools.oldseg.opts.warpco = 25;
    matlabbatch{1}.spm.tools.oldseg.opts.biasreg = 0.01;%medium regularisation
    matlabbatch{1}.spm.tools.oldseg.opts.biasfwhm = 60;
    matlabbatch{1}.spm.tools.oldseg.opts.samp = 3;
    matlabbatch{1}.spm.tools.oldseg.opts.msk = {''};
    spm_jobman('run',matlabbatch)
end

%% Loop to remove raw_data from new per-subject folder
for sbj = 1:size(subjects, 1)
    for rawi = 1:length(subjects(sbj).sourcesanat)
        rwdt = fullfile(subjects(sbj).sourcesanat(rawi).folder...
            , subjects(sbj).sourcesanat(rawi).name);
        if exist(rwdt, 'file'), delete(rwdt); end
    end
end

end
