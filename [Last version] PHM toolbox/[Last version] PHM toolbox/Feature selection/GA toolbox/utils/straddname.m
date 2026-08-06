% Add a special name to a string/file name
%
% This function extends a given string with another string.
% The main use is in the generation of an extended filename for data 
% files based on a common string and extended by changing contents.
% The given file name base can be used for specifying the main topic
% of the data and the extension reflects the current run or similar.
%
% The extension is only done, when the filename ends in an underscore.
% The handling of a path and file extension is done inside the function.
% See the examples below.
%
% Syntax:  FileNameExtended = straddname(FileNameBase, StrExtension)
%
% Input parameter:
%    FileNameBase- String containing the base of the new filename
%                  can include path and extension
%    StrExtension- String containing the extension
%
% Output parameter:
%    FileNameExtended - extended string
%
% Examples:
%
%  % Extend the string/filename FN='OptResult_' with another string
%  % ExtStr, when FN is empty, just use the default in DefStr
%  % the extension is only done, when FN ends in '_'
%  >> FN = 'OptResult_'; ExtStr = 'special_name'; DefStr = 'DataFile_';
%  >> NewName = straddname(FN, ExtStr, DefStr);
%     NewName = 'OptResult_special_name'
%
%  >> FN = 'dir1\data2\Result_.txt'; ExtStr = 'run4'; DefStr = 'DataFile_';
%  >> NewName = straddname(FN, ExtStr, DefStr);
%     NewName = 'dir1\data2\Result_run4.txt'
%
%  % Here the default string in DefStr is used (FN is empty)
%  >> FN = ''; ExtStr = 'run4'; DefStr = 'DataFile_';
%  >> NewName = straddname(FN, ExtStr, DefStr);
%     NewName = 'DataFile_run4'
%
% See also: straddtime

% Author:   Hartmut Pohlheim
% History:  06.04.2000  file created


function FileNameExtended = straddname(FileNameBase, StrExtension, DefaultFileName)

   % Check input parameter
   if nargin < 1, FileNameBase = []; end
   if isnan(FileNameBase), FileNameBase = []; end
   
   if nargin < 2, StrExtension = []; end
   if isnan(StrExtension), StrExtension = []; end
   if isempty(StrExtension), StrExtension = ''; end

   if nargin < 3, DefaultFileName = []; end
   if isnan(DefaultFileName), DefaultFileName = []; end

   % When FileNameBase is empty, set to given default filename
   if isempty(FileNameBase), FileNameBase = DefaultFileName; end
   
   % If FileName is still empty, return just with StrExtension
   if isempty(FileNameBase), FileNameExtended = StrExtension;
   else
      % Look for path and extension inside FileNameBase
      [FBPath, FBName, FBExt] = fileparts(FileNameBase);
   
      % Check for _ (underscore) at end of filename
      % when '_' is there, extend the filename
      if strcmp(FBName(end), '_'),
         % Add the FileNameBase
         FBName = sprintf('%s%s', FBName, StrExtension);
      end
      % Construct full file name again
      FileNameExtended = fullfile(FBPath, [FBName FBExt]);
   end


% End of function