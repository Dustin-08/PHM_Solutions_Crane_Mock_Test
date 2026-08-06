% SAVE a PARAOPTions structure to a text or matlab file
%
% This function saves a PARAOPTIONS structure to a readable and 
% editable format:  text format file or matlab m-file function.
%
% If creating a m-file:
% A fully functional matlab m-file is created and the correct syntax
% calls to paraoptset are included for recreating the given options.
% 
% If creating a text file:
% A text parameter file is created using the following syntax.
% - tbd. 
%
% The main use for the text parameter file is in compiled programs,
% where the interpretation of m-parameter-files is not possible (the
% parameter file can not be included at compile time, it will/must be 
% changed before/during/after run time).
%
% This function is used for:
%  - saving parameters defined by paraoptset to 
%
% Syntax:  Result = paraoptsave(ParaOpt, FileName, FilePath)
%
% Input parameter:
%    ParaOpt   - Structure with ParaOptions
%    FileName  - String containing name of file to save to
%    FilePath  - (optional) String containing path to file
%    FileType  - (optional) String defining the type of parameter file
%                             only the first letter is checked
%                             'm': m-file
%                             't': txt-file
%
% Output parameter:
%    Result    - indicates the result of the operation
%
% Examples:
%
%
%
%
% See also: paraoptset, paraoptload, prprintf

% Author:   Hartmut Pohlheim
% History:  17.12.1998  file created
%                       basic functionality included
%           28.01.1999  review of function, some polishing
%                       include date and time of parameter file 
%                          creation into file
%           31.03.1999  special handling for matrix output
%                          uses prprintf with ';' between rows
%           21.06.1999  special handling for matrix output 
%                          (multiple lines in text mode)
%           23.04.2006  added many comments, reworked help text


function Result = paraoptsave(ParaOpt, FileName, FilePath, FileType)

   % Save nargin and nargout
   NAIN = nargin; NAOUT = nargout;

   % Preset the return parameter
   SaveResult = 0;

   % Check input parameter
   if NAIN < 2, FileName = ''; end
   if ~(isstr(FileName)), FileName = ''; end
   if isempty(FileName), warning('The FileName must be defined (as string).'); return; end
   
   if NAIN < 3, FilePath = ''; end
   if NAIN < 4, FileType = ''; end
   if isempty(FileType), FileType = 'm'; end
   if FileType(1) ~= 'm', FileType = 't'; end

   % Produce a correct filename
   [PartPath, PartName, PartExt] = fileparts(FileName);
   if isempty(PartPath), PartPath = FilePath; end
   if isempty(PartExt), if FileType == 'm', PartExt = '.m'; else PartExt = '.paraopt'; end, end

   % define the text header and footer of the file to create
   HeaderofFile1 = sprintf(['%% %s: parameter file (created automatically)\n%%\n', ...
                            '%% This parameter file was written by a matlab function!\n', ...
                            '%% However, the contents of the file may be changed by hand to reflect\n', ...
                            '%% the needs of the user!\n%%\n', ...
                            '%% Just exclude the lines with parameters you want not be set/defined by \n', ...
                            '%% this script and/or change the parameter values directly.\n', ...
                            '%% \n', ...
                            '%% This file was created at   date: %s     time: %s \n', ...
                            '%% \n\n', ...
                           ], upper(PartName), datestr(now, 1), datestr(now, 13));
                           
   if FileType == 'm', 
      HeaderofFile2 = sprintf(['function ParaOpt = %s\n\n', ...
                               '%% Call the paraoptset function\n', ...
                               '   ParaOpt = paraoptset(', ...
                             ], PartName);
   else HeaderofFile2 = ''; end
   
   HeaderofFile = [HeaderofFile1, HeaderofFile2];

   % Get the full fieldnames for all properties in ParaOpt
   FieldnamesFull = fieldnames_full(ParaOpt);

   % Run through all fieldnames and output the stuff into a string
   BodyofFile = '';
   for ifield = 1:length(FieldnamesFull),
      FieldNamesCurrent = fieldnames_parts(FieldnamesFull{ifield});
      Values = getfield(ParaOpt, FieldNamesCurrent{:});

      % Test type of Values
      if iscell(Values),
         ValueIsCell = 1; ParaOpen = '{'; ParaClose = '}';
         if isempty(Values), ValueIsChar = -1; elseif ischar(Values{1}), ValueIsChar = 1; else ValueIsChar = 0; end
      else
         ValueIsCell = 0; ParaOpen = '['; ParaClose = ']';
         if isempty(Values), ValueIsChar = -1; elseif ischar(Values(1)), ValueIsChar = 1; else ValueIsChar = 0; end
      end

      % Do the correct output creation depending on empty, string/char or numerical
      if ValueIsChar == -1,
         ValString = {' '};

      elseif ValueIsChar == 1,
         % If field is char and no cell, convert to cell for common starting point
         if ValueIsCell == 0, Values = cellstr(Values); end
         
         % Output the elements of the char cell array
         ValString = sprintf('''%s', Values{1});
         if length(Values) > 1,
            for ival = 2:length(Values),
               ValString = [ValString, sprintf('''  ''%s', Values{ival})];
            end
         end
         ValString = [ValString, ''''];
         ValString = {ValString};

      else
         % Create the output string for numerical data, quite easy with prprintf
         if FileType == 'm', 
            ValString = {prprintf('%g', {', ', '; '}, Values)};
         else  % text type file
            ValString = cell(size(Values, 1),1);
            for ival = 1:size(Values, 1),
               ValString{ival} = prprintf('%g', {'  ', '; '}, Values(ival,:));
            end
         end
      end
      
      % the first line of the parameter definition must be handled separately
      if ifield == 1, ParaKomma = ' '; else ParaKomma = '                      ,'; end
      % Put all the created data together into the correct function line
      if FileType == 'm', 
         BodyofFile = [BodyofFile, sprintf('%s ''%s'', %s%s%s ...\n', ...
                                   ParaKomma, FieldnamesFull{ifield}, ParaOpen, ValString{:}, ParaClose)];
      else     % text type file
         for ivalstr = 1:size(ValString,1),
            BodyofFile = [BodyofFile, sprintf('%s:   %s\n', ...
                                      FieldnamesFull{ifield}, ValString{ivalstr})];
         end
      end
   end

   % Define the footer of the file
   if FileType == 'm', 
      FooterofFile = sprintf(['                     );\n\n', ...
                              '%% End of function\n', ...
                             ]);
   else
      FooterofFile = sprintf('\n\n');
   end

   disp([HeaderofFile, BodyofFile, FooterofFile]);

   % Save text to the defined file
   FileNameFull = fullfile(PartPath, [PartName, PartExt]);
   [fidgen, FileOpenMessage] = fopen(FileNameFull, 'wt');
   if fidgen == -1, warning(sprintf('error during fopen of file (%s): %s', ...
                                    FileNameFull, FileOpenMessage));
      Result = 0;
   else
      fprintf(fidgen, '%s%s%s', HeaderofFile, BodyofFile, FooterofFile);
      fclose(fidgen);
      Result = 1;
   end


% End of function