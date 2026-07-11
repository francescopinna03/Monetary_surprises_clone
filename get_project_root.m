function projectRoot = get_project_root()
% GET_PROJECT_ROOT Resolve the root folder of the data package.
%
% The data package is the unzipped Econometrics_data folder, containing
% the Raw/ and Output/ subfolders described in the README.
%
% Resolution order:
%   1. The environment variable ECONOMETRICS_DATA_ROOT, if set.
%   2. A folder named 'Econometrics_data' next to the MATLAB scripts.
%   3. A folder named 'Econometrics_data' in the current working directory.
%
% The resolved folder must contain the Raw/ subfolder, otherwise an error
% is raised so that a misconfigured path fails early and explicitly.

projectRoot = getenv('ECONOMETRICS_DATA_ROOT');

if isempty(projectRoot)
    candidates = { ...
        fullfile(fileparts(mfilename('fullpath')), 'Econometrics_data'), ...
        fullfile(pwd, 'Econometrics_data')};
    for k = 1:numel(candidates)
        if exist(candidates{k}, 'dir')
            projectRoot = candidates{k};
            break
        end
    end
end

if isempty(projectRoot) || ~exist(fullfile(projectRoot, 'Raw'), 'dir')
    error(['get_project_root:notFound. Could not locate the data package. ' ...
        'Set the environment variable ECONOMETRICS_DATA_ROOT to the path of ' ...
        'the unzipped Econometrics_data folder (the one containing Raw/ and ' ...
        'Output/), or place the Econometrics_data folder next to the MATLAB ' ...
        'scripts or in the current working directory.']);
end
end
