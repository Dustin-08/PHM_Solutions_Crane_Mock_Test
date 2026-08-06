function folder_tree=makefoldertree(src_filepath, dst_filepath,savefunc, ext)
folder_tree.path=dst_filepath;
mkdir(dst_filepath);

folderList=get_folder_list(src_filepath);
folderList(strcmp(folderList(:),'.') | strcmp(folderList(:),'..'))=[];
if ~isempty(folderList)
    under_folder_tree=cell(length(folderList),1);
    for i=1:length(folderList)
        under_folder_tree{i}=makefoldertree([src_filepath  '\'  folderList{i}], [dst_filepath  '\'  folderList{i}], savefunc, ext);
        folder_tree.u_tree=under_folder_tree{i};
        mkdir(under_folder_tree{i}.path);
    end
end

fileList=get_file_list(src_filepath, ext);
folder_tree.list=fileList;
if ~isempty(fileList)
    callfunc=[savefunc '(src_filepath, dst_filepath, fileList)'];
    eval(callfunc);
end


