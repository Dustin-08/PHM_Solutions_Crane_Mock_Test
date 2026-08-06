% Add a date and time string to a string base
%
% This function extends a given string with the current date and 
% time (24h). (format: yyyy-mmm-dd_hh-mm-ss)
% The main use is in the generation of a different filename for data 
% files each time the function is called (when the second changed).
% The given file name base can be used for specifying the topic of
% the data.
% The handling of a path and file extension is done inside the function.
%
% Syntax:  FileNamewithTime = straddtime(FileNameBase)
%
% Input parameter:
%    FileNameBase- String containing the base of the new filename
%
% Output parameter:
%    FileNamewithTime - extended string
%
% Examples:
%
%  % Extend the string/filename 'OptResult' with the current date and time
%  % the result means: created at 5th of May 2002, 22:12:39
%  >> NewName = straddtime('OptResult');
%     NewName = 'OptResult_2000-May-05_22-12-39'
%
% See also: straddname

% Author:   Hartmut Pohlheim
% History:  05.04.2000  file created
%           06.04.2000  added better file name handling (path and extension)
%           06.05.2002  changed the format of date and time (uses '-' in date)
%                       time contains seconds as well (needed for some very 
%                          quick automatic optimizations


function FileNamewithTime = straddtime(FileNameBase)

   % Check input parameter
   if nargin < 1, FileNameBase = []; end
   if isnan(FileNameBase), FileNameBase = []; end
   if isempty(FileNameBase), FileNameBase = 'DataFile'; end
   
   % Look for path and extension inside FileNameBase
   [FBPath, FBName, FBExt] = fileparts(FileNameBase);
   
   % Check for _ (underscore) at end of filename
   if strcmp(FBName(end), '_'), FBName = FBName(1:end-1); end
   
   % Get current time
   CurTime = now;
   % Produce string with date and time
   StrTime = sprintf('%s-%s-%s_%s', datestr(CurTime, 10), datestr(CurTime, 3), datestr(CurTime, 7), datestr(CurTime, 13) );
   % Replace : from time with underscore
   StrTime = strrep(StrTime, ':', '-');   % StrTime(end-2) = '_';
   % Add the FileNameBase
   FBNamewithTime = sprintf('%s_%s', FBName, StrTime);
   
   % Construct full file name again
   FileNamewithTime = fullfile(FBPath, [FBNamewithTime FBExt]);


% End of function