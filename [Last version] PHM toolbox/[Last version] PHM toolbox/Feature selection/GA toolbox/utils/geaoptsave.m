% SAVE a GEAOPTions structure to a matlab file
%
% This function saves a GEAOPTIONS structure to an matlab m-file. 
% A fully functional matlab m-file is created and the correct syntax
% calls to geaoptset are included for recreating the given options.
%
% This function is used for:
%  - saving parameters defined by the GEA Toolbox GUI to a readable and 
%    editable format
%
% Syntax:  Result = geaoptsave(GeaOpt, FileName, FilePath)
%
% Input parameter:
%    GeaOpt    - Structure with geaoptions
%    FileName  - (optional) String containing name of file to save to
%    FilePath  - (optional) String containing path to file
%
% Output parameter:
%    Result    - indicates the result of the operation
%
% See also: geamain2, geagui, geaoptset, geaoptprint, geaoptload

% Author:   Hartmut Pohlheim
% History:  17.12.98    file created
%                       basic functionality included
%           28.01.99    review of function, some polishing
%                       include date and time of parameter file 
%                          creation into file
%           31.03.99    special handling for matrix output
%                          uses prprintf with ';' between rows
%           21.06.99    special handling for matrix output 
%                          (multiple lines in text mode)


function Result = geaoptsave(GeaOpt, FileName, FilePath, FileType)

   % Save nargin and nargout
   NAIN = nargin; NAOUT = nargout;

   % Check input parameter
   if NAIN < 3, FilePath = ''; end
   if NAIN < 4, FileType = ''; end
   if isempty(FileType), FileType = 'm'; end
   if FileType(1) ~= 'm', FileType = 't'; end

   % Produce a correct filename
   [PartPath, PartName, PartExt] = fileparts(FileName);
   if isempty(PartPath), PartPath = FilePath; end
   if isempty(PartExt), if FileType == 'm', PartExt = '.m'; else PartExt = '.geapara'; end, end

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
      HeaderofFile2 = sprintf(['function GeaOpt = %s\n\n', ...
                               '%% Call the geaoptset function\n', ...
                               '   GeaOpt = geaoptset(', ...
                             ], PartName);
   else HeaderofFile2 = ''; end
   
   HeaderofFile = [HeaderofFile1, HeaderofFile2];

   % Get the full fieldnames for all properties in GeaOpt
   FieldnamesFull = fieldnames_full(GeaOpt);

   % Run through all fieldnames and output the stuff into an string
   BodyofFile = '';
   for ifield = 1:length(FieldnamesFull),
      FieldNamesCurrent = fieldnames_parts(FieldnamesFull{ifield});
      Values = getfield(GeaOpt, FieldNamesCurrent{:});

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
         % if field is char and no cell, convert to cell for common starting point
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
            % case 'System.ObjFunVarBounds', ValString = [prprintf('%g', ', ', Values(1,:)), '; ', prprintf('%g', ', ', Values(2,:))];
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

   % disp([HeaderofFile, BodyofFile, FooterofFile]);

   % Save text to the defined file
   FileNameFull = fullfile(PartPath, [PartName, PartExt]);
   [fidgen, error_message] = fopen(FileNameFull, 'wt');
   if fidgen == -1, disp(sprintf('error during fopen of file (%s): %s', ...
                                 FileNameFull, error_message));
      Result = 0;
   else
      fprintf(fidgen, '%s%s%s', HeaderofFile, BodyofFile, FooterofFile);
      fclose(fidgen);
      Result = 1;
   end


% End of function