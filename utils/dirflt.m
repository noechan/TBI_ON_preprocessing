function contents = dirflt(indir, varargin)
%DIRFLT - return contents of a directory with some filtering options

%% Initialise inputs
p = inputParser;
p.KeepUnmatched = true;

p.addRequired('indir', @isstr);

p.addParameter('getdir', true, @(x) islogical(x) || ismember(x,[0 1]));
p.addParameter('getfile', true, @(x) islogical(x) || ismember(x,[0 1]));

p.parse(indir, varargin{:});
Arg = p.Results;


%% Get and parse contents
contents = dir(indir);

contents(ismember({contents.name}, {'.', '..'})) = [];

idxD = [contents.isdir] & Arg.getdir;
idxF = ~[contents.isdir] & Arg.getfile;

contents = contents(idxD | idxF);