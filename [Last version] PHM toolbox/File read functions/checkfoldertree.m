function checkfoldertree(src_path, dst_path)
dirData_src = dir(src_path);      %# Get the data for the current directory
dirIndex_src = [dirData_src.isdir];  %# Find the index for directories
folderList = {dirData_src(dirIndex_src).name}';  %'# Get a list of the files
folderList(strcmp(folderList(:),'.') | strcmp(folderList(:),'..'))=[];
folderList_src=folderList;

dirData_dst = dir(dst_path);      %# Get the data for the current directory
dirIndex_dst = [dirData_dst.isdir];  %# Find the index for directories
folderList = {dirData_dst(dirIndex_dst).name}';  %'# Get a list of the files
folderList(strcmp(folderList(:),'.') | strcmp(folderList(:),'..'))=[];
folderList_dst=folderList;


for i=1:length(folderList_src)
    idx=strcmp(folderList_dst(:), folderList_src{i});
    if sum(idx)==0
        fp=fopen('diff_file.txt' ,'a');
        fprintf(fp, '%s\n',[src_path '\' folderList_src{i}]);
        fclose(fp);
    end
end


if ~isempty(folderList_src)
    for i=1:length(folderList_src)
        checkfoldertree([src_path  '\'  folderList_src{i}], [dst_path  '\'  folderList_src{i}]);
    end
end

fileList = {dirData_src(~dirIndex_src).name}';  %'# Get a list of the files
fileList_src=sort_nat(fileList);
fileList = {dirData_dst(~dirIndex_dst).name}';  %'# Get a list of the files
fileList_dst=sort_nat(fileList);
% folder_tree.list=fileList;
if ~isempty(fileList_src)

    for i=1:length(fileList_src)
        idx=strcmp(fileList_dst(:), fileList_src{i});
        if sum(idx)==0
            fp=fopen('diff_file.txt', 'a');
            fprintf(fp, '%s\n', [src_path '\' fileList_src{i}]);
            fclose(fp);
        end
    end

end




