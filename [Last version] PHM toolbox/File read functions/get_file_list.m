function file_list = get_file_list(path, ext, filter)
if nargin<2
    dirData = dir([path '\*']);      %# Get the data for the current directory
elseif nargin<3
    dirData = dir([path '\*.' ext]);      %# Get the data for the current directory
else
    dirData = dir([path '\' filter '.' ext]);      %# Get the data for the current directory
end
    dirIndex = [dirData.isdir];  %# Find the index for directories
    file_list = {dirData(~dirIndex).name}';  %'# Get a list of the files
    file_list=sort_nat(file_list);