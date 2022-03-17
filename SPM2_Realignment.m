function SPM1_Realignment(subjects,outdir,varargin)
%SPM1_REALIGNMENT

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
p.addParameter('rdir', 'realign', @ischar)

p.parse(subjects,outdir,varargin{:});
Arg = p.Results;


%% Loop for subjects
for sbj = 1:size(subjects, 1)
    disp(subjects(sbj).name)
    sub_path = fullfile(outdir, subjects(sbj).name, Arg.ses, Arg.derdir, Arg.prepdir, Arg.funcdir);
    
    srcfile_func= dir(fullfile(sub_path,Arg.rodir,'rosub*.nii'));
    
    if ~isfolder(fullfile(sub_path, Arg.rdir))
        mkdir(fullfile(sub_path, Arg.rdir))
    end
    
    for sf=1:numel(srcfile_func)
        if ~exist(fullfile(sub_path,Arg.rdir, srcfile_func(sf).name), 'file')
            copyfile(fullfile(sub_path, Arg.rodir, srcfile_func(sf).name), fullfile(sub_path, Arg.rdir))
        end
    end
    
    %Prepare inputs
    rEPI_rest = dir (fullfile(sub_path,Arg.rdir,'rosub*.nii'));
    rEPI_rest_name= extractfield(rEPI_rest,'name')';
        
        % Spatial realignment
        for n = 1:numel(rEPI_rest_name)
            matlabbatch{1}.spm.spatial.realign.estwrite.data{1,1}{n,1} = (fullfile(sub_path,Arg.rdir,rEPI_rest(n).name));
        end
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
        
        spm_jobman('run', matlabbatch);
        clear matlabbatch
        ps_file=['spm_',datestr(now, 'yyyymmmdd'),'.ps'];
        if ~exist(fullfile(sub_path,Arg.rdir,ps_file),'file')
            movefile(fullfile(pwd,ps_file),fullfile(sub_path,Arg.rdir,ps_file))
        end
        
        % Loop to remove input data
    for in = 1:numel(rEPI_rest_name)
        indt =fullfile(sub_path,Arg.rdir,rEPI_rest(in).name);
        if exist(indt, 'file'), delete(indt); end
    end
end


