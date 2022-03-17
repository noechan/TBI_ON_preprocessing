function SPM_prepro_wrapper(subjects, outdir, varargin)
%SPM_PREPRO_WRAPPER
%
% INPUT
%   subjects
%   outdir
% VARARGIN
%   'prep_steps'     numeric, numbers of the preprocessing steps to call,
%                    default = [1 4 6 7]
%
% CALLS SPM1_Realignment(), SPM2_Reorient(), SPM3_Coregistration(), SPM4_Segment(), SPM5_Normalize(), SPM6_Smoothing()
%------------------------------------------------------------------------


%% Initialise inputs
pp = [6];
p = inputParser;
p.addRequired('subjects', @isstruct)
p.addRequired('outdir', @ischar)


p.addParameter('funcdir', 'func', @ischar)
p.addParameter('anatdir', 'anat', @ischar)
p.addParameter('ses','ses-1', @ischar)
p.addParameter('derdir', 'derivatives', @ischar)
p.addParameter('prepdir', 'SPM_prepro', @ischar)
p.addParameter('prep_steps', pp, @(x) isnumeric(x) || iscellstr(x))

p.parse(subjects, outdir, varargin{:})
Arg = p.Results;

%----------------------------------------------------
% Initialise SPM
spm('Defaults', 'fMRI')
spm_jobman('initcfg')


%% Perform requested preprocessing steps
if iscellstr(Arg.prep_steps)
    preps = {'reorient' 'realignment' 'coregistration' 'segment' 'normalize' 'smooth'};
    idx = startsWith(preps, Arg.prep_steps, 'IgnoreCase', true);
    Arg.prep_steps = pp(idx);
end
Arg.prep_steps = sort(Arg.prep_steps);
for i = 1:length(Arg.prep_steps)
    switch Arg.prep_steps(i)
        case 1
            SPM1_Reorient(subjects,outdir)
        case 2
            SPM2_Realignment(subjects,outdir)
        case 3
            SPM3_Coregistration(subjects,outdir)
        case 4
            SPM4_Segment(subjects,outdir)
        case 5
            SPM5_Normalize(subjects,outdir)
        case 6
            SPM6_Smoothing(subjects,outdir)
    end
end




