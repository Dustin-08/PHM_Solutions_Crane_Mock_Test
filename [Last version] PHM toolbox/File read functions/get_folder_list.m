function folder_list = get_folder_list(path)
    dirData = dir(path);      %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    folder_list = {dirData(dirIndex).name}';  %'# Get a list of the files
    folder_list(strcmp(folder_list(:),'.') | strcmp(folder_list(:),'..'))=[];