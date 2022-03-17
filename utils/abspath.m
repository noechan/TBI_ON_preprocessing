function abspath = abspath(relpath)
% Turns a partial/relative path into an absolute path
% NOTE: THIS WILL CREATE THE PATH GIVEN, MAKE SURE IT'S THE RIGHT ONE!
    tmp = pwd;
    if ~isfolder(relpath), mkdir(relpath); end
    cd(relpath)
    abspath = pwd;
    cd(tmp)
end