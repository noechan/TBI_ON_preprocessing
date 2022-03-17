function names = build_dataset(indir, varargin)
% BUILD_DATASET
% 
%   names = build_dataset(indir, varargin)
% 
% INPUT
%   indir   string/cellstr, directory to search for data OR set of dirs
% 
% VARARGIN
%   subdir  string, some fixed directory to append to path
% 
% NOTE  This function calls dirflt: pass getfile=0 OR getdir=0 to prevent 
%       return of files or dirs (these are true by default)
%       This function can use any of name_filter()'s arguments to, e.g. 
%       filter subjects by name, number, or both
% 
% CALLS     name_filter(), abspath(), dirflt()
%--------------------------------------------------------------------------


%% Initialise inputs
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('indir', @(x) ischar(x) || iscellstr(x)) %#ok<*ISCLSTR>

p.addParameter('subdir', '', @ischar)

p.parse(indir, varargin{:})
Arg = p.Results;


%% Set up paths ------------------------------------
if iscellstr(indir)
    recus = indir(2:end);
    indir = indir{1};
else
    recus = {};
end
if ~isfolder(indir)
    error 'build_fileset: path to data does not exist!'
end

% call abspath because spm_select() can't handle tilde-prefixed paths
indir = abspath(indir);

% expecting a fixed directory structure for data and ROIs:
data_path = fullfile(indir, Arg.subdir);


%% Filter subjects ------------------------------------
names = dirflt(data_path, p.Unmatched);

% Filter by cell array of strings or vector of inds
if isfield(p.Unmatched, 'filt')
    filt = p.Unmatched.filt;
    names = name_filter(names, filt, rmfield(p.Unmatched, 'filt')); 
end


%% Recursion?
if ~isempty(recus)
    names = [names; build_dataset(recus, varargin{:})];
end
