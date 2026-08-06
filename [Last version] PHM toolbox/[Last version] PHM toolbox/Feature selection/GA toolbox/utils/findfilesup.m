% Find Files upwards the directory structure regarding a search mask 
%
% This function searches for files in the current directory and depending
% on the given SearchLevel upwards through directories.
% The search file mask can conatin * for searching with wildcards.
% The search path mask can also contain * as wildcard. Please
% keep in mind, that the search path upwards has only one directory 
% at each level.
% The utility function findfiles is used for the actual search process.
% Currently always the full path is returned (absolute path).
%
% Syntax:  [PathFileList, FileList, PathList] = findfilesup(SearchFileMask, SearchPathMask, SearchLevel)
%
% Input parameter:
%   SearchFileMask - String or cell array of strings containing the file mask
%                       to search for {'*.m'; 'ma*'; '*am.mat'}
%                       if omitted or empty '*' is used
%                       if NaN (not a string): search for all directories
%   SearchPathMask - String containing the path to search on
%                       The path may contain as many masks (*) as necessary
%                       and also on lower levels {'v:\ge*\pl*\fritz'}, the extension 
%                       of the * is handled by the function
%                       special strings: '' or '.': current directory
%                       if omitted or empty '.' (current directory) is used
%   SearchLevel    - Scalar indicating how much levels of directorys (beginning with the SearchPath)
%                       should be searched
%                       1: only SearchPath
%                       n: SearchPath + (n-1) levels upwards
%                       if omitted or empty 1 is used
%
% Output parameter:
%   PathFileList- Cell array of string(s) containing the path and name of the found files
%   FileList    - Cell array of string(s) containing the name of the found files
%   PathList    - Cell array of string(s) containing the path of the found files
%
% Example:
%   % Search in directory TSeq001 and 3 levels up for files with mask *SystemOption.m
%   % not recursively
%   >> [pfl, fl, pl] = findfiles('*SystemOptions.m', 'TSeq001', 4);
%      pfl = 
%          'c:\projekte\mtest\models\test\st_regler\regelkreis\test001\tseq001\MTest_SystemOptions.m'
%          'c:\projekte\mtest\models\test\st_regler\regelkreis\MTest_SystemOptions.m'
%          'c:\projekte\mtest\models\test\st_regler\MTest_SystemOptions.m'
%      fl = 
%          'MTest_SystemOptions.m'
%          'MTest_SystemOptions.m'
%          'MTest_SystemOptions.m'
%      pl = 
%          'c:\projekte\mtest\models\test\st_regler\regelkreis\test001\tseq001\'
%          'c:\projekte\mtest\models\test\st_regler\regelkreis\'
%          'c:\projekte\mtest\models\test\st_regler\'   
%
%   % Search in directories gea*\gr* and in geaobj for files with mask *an*.m and *objfun1*.mat
%   % not recursively
%   >> [pfl, fl, pl] = findfiles({'*am*.m'; '*objfun1*.mat'}, {'gea*\p*', 'geaobj\gr*'});
%      pfl = 
%          'geatbx\plotext\samdata.m'
%          'geatbx\plotext\sammon.m'
%          'geaobj\grafics\res_beasv_objfun1_var_2_01.mat'
%          'geaobj\grafics\res_beasv_objfun1c_var_2_01.mat'
%      fl = 
%          'samdata.m'
%          'sammon.m'
%          'res_beasv_objfun1_var_2_01.mat'
%          'res_beasv_objfun1c_var_2_01.mat'
%      pl = 
%          'geatbx\plotext\'
%          'geatbx\plotext\'
%          'geaobj\grafics\'
%          'geaobj\grafics\'
%
% See also: findfiles, dir

% Author:   Tobias Bochtler
% History:  25.09.2003  file created



function [PathFileList, FileList, PathList] = findfilesup(SearchFileMask, SearchPathMask, SearchLevels, SearchMode)

   if nargin < 1, SearchFileMask = ''; end;
   if nargin < 2, SearchPathMask = ''; end;

   if nargin < 3, SearchLevels   = 1; end;
   if isempty(SearchLevels), SearchLevels = 1; end
   if SearchLevels < 1; SearchLevels = 1; end

   % 'all': return all found files; 'first': only first found in directory; 
   % 'one': return only one file, ever first found
   SearchModeStd = {'all', 'first', 'one'};
   if nargin < 4, SearchMode   = ''; end;
   if isempty(SearchMode), SearchMode = SearchModeStd{1}; end;
   SearchModeNum = find(strcmp(SearchMode, SearchModeStd));
   if isempty(SearchModeNum), SearchModeNum = 1; end;
   
   aktdir = pwd;
   
   PathFileList = [];
   FileList     = [];
   PathList     = [];
   FullPath     = 0;

   if all([isempty(strfind(SearchPathMask, ':')) == 0, isempty(strfind(SearchPathMask, '*'))])
      cd(SearchPathMask);
      FullPath = 1;
   end
   
   % Search from the actual directory or given full path (without '*') upwards
   if any([isempty(SearchPathMask), FullPath == 1])
      for SLevel = 1:SearchLevels
         aktpath  = pwd;
         if aktpath(end) ~= filesep, aktpath  = [aktpath, filesep]; end;
         
         aktPList = {};
         
         %find files in present directory
         [PFList, FList, PList] = findfiles(SearchFileMask);
         
         if ~(isempty(FList)),
            if any(SearchModeNum == [2, 3]),
               PFList = PFList(1); FList = FList(1); PList = PList(1);
            end
            % add files and paths to list
            PathFileList = [PathFileList; strcat(aktpath, PFList)];
            FileList     = [FileList; FList];
            
            [aktPList{1:length(FList)}] = deal(aktpath);
            aktPList = aktPList';
            PathList = [PathList; aktPList];

            % When one file found, go out of loop
            if any(SearchModeNum == [3]), break; end
         end
         
         %one step up
         oldpath = pwd;
         cd ..;
         
         if strcmp(pwd, oldpath), break; end; % reached root
      end
   end
   
   % full path with '*'
   if all([isempty(strfind(SearchPathMask, ':')) == 0, isempty(strfind(SearchPathMask, '*')) == 0])
      cd(getstartpath(SearchPathMask));
      
      for SLevel = 1:SearchLevels
         % find files
         [PFList, FList, PList] = findfiles(SearchFileMask, SearchPathMask);
         
         if ~(isempty(FList)),
            if any(SearchModeNum == [2, 3]),
               PFList = PFList(1); FList = FList(1); PList = PList(1);
            end
            
            % add files and paths to list
            PathFileList = [PathFileList; PFList];
            FileList     = [FileList; FList];
            PathList     = [PathList; PList];
         end

         % When one file found, go out of loop
         if any(SearchModeNum == [3]), break; end
         
         % one step up
         if SLevel > 1, % level 2 is the starting path of the directory mask
            oldpath = pwd;
            cd ..; 
            if strcmp(pwd, oldpath), break; end; % reached root
         end; 
         
         SearchPathMask = pwd;
      end
   end
   
   % relativ path
   if all([isempty(SearchPathMask) == 0, isempty(strfind(SearchPathMask, ':')) == 1])
      
      for SLevel = 1:SearchLevels,
         aktpath  = pwd;
         if aktpath(end) ~= filesep, aktpath  = [aktpath, filesep]; end;

         % find files
         [PFList, FList, PList] = findfiles(SearchFileMask, SearchPathMask);
         
         if ~(isempty(FList)),
            if any(SearchModeNum == [2, 3]),
               PFList = PFList(1); FList = FList(1); PList = PList(1);
            end
         
            % add files and paths to list
            PathFileList = [PathFileList; strcat(aktpath, PFList)];
            FileList     = [FileList; FList];
            PathList     = [PathList; strcat(aktpath, PList)];
         end

         % When one file found, go out of loop
         if any(SearchModeNum == [3]), break; end
         
         % one step up
         if SLevel > 1, %level 2 is the starting path of the directory mask
            oldpath = pwd;
            cd ..; 
            if strcmp(pwd, oldpath), break; end; % reached root
         end; 
         
         SearchPathMask = '';
      end
   end
   
   cd(aktdir);



function path = getstartpath(pathmask)
   path = [];
   [tpath, rest] = strtok(pathmask, filesep);
   
   while ~(isempty(strfind(rest, '*'))),
      if ~(isempty(path)),
         path = [path filesep tpath];
      else path = tpath; end;
      [tpath, rest] = strtok(rest, filesep);
   end


% End of function