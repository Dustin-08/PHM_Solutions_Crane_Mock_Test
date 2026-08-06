% LOAD OPTions from a text file
%
% This function loads OPTIONS from a text file. 
% However, the function may be used for reading everything else as well.
%
% This function is used for:
%  - loading parameters defined by the user for the GEA Toolbox 
%    (especially for the compiled version of the GEATbx)
%
% Syntax:  Options = geaoptload(FileName, FilePath)
%
% Input parameter:
%    FileName  - String containing name of file to load from
%    FilePath  - (optional) String containing path to file
%
% Output parameter:
%    Options   - Structure containing options from file
%                if an error occured, Options will be empty
%                   (Options = []).
%
% See also: geamain2, geaoptsave, geaoptset, geaoptprint

% Author:   Hartmut Pohlheim
% History:  14.06.1999  file created
%           02.09.2001  Check of first letter of option name added
%                          (must be a letter)
%           03.06.2002  warnings during compile removed


function Options = geaoptload(FileName, FilePath)

   % Save nargin and nargout
   NAIN = nargin; NAOUT = nargout;

   % Check input parameter
   if NAIN < 2, FilePath = ''; end
   
   % Reset variables
   Options = [];

   % Produce a correct filename
   % [FileNameOhne, Rest] = strtok(FileName, '.');
   % if isempty(Rest), if FileType == 'm', FileName = [FileName, '.m']; else FileName = [FileName, '.geapara']; end, end

   % Open the file for reading and check for errors
   FileNameFull = fullfile(FilePath, FileName);
   [fidload, error_message] = fopen(FileNameFull, 'rt');
   if fidload == -1, warning(sprintf('error during fopen of file (%s): %s', FileNameFull, error_message)); return; end
   
   % Read stuff from file and process, line after line
   while 1
      % Reset some variables
      OptName = ''; ParaValue = [];

      CurLine = fgetl(fidload);
      if ~ischar(CurLine), break, end

      % remove leading and trailing blanks
      CurLine = deblankall(CurLine);

      % Look for comment lines and continue
      if isempty(CurLine),
         % Empty line found, ignore
         
      % Look for comment lines and continue
      elseif any([CurLine(1) == ['%' '#' '/']]),
         % Comment line found, ignore contents
      
      % Line with contents found   
      else
         % Get the string with the option name description
         [OptName, CurLineRest] = strtok(CurLine, ':');
         
         % Check the option name for validity (must consist of letters, numbers and '.')
         % here only the first letter is tested for isletter
         if ~(isletter(OptName(1))),
            warning(sprintf('An option in the parameter file  %s  is not correct (first char not a letter): %s', FileNameFull, OptName));
         else
            
            % Check for length of option values and set CurLine appropriate
            if length(CurLineRest) >= 2,
               CurLine = deblankall(CurLineRest(2:end));
            else CurLine = ''; end
            
            if isempty(CurLine), ParaValue = []; 
            else
               % Check for strings
               if CurLine(1) == '''',
                  CurLineRest = CurLine; ParaValue = {}; ipara = 1;
                  while 1,
                     [CurPara, CurLineRest] = strtok(CurLineRest, '''');
                     if ipara == 1, ParaValue = CurPara; else ParaValue{ipara} = CurPara; end
                     if length(CurLineRest) > 1, CurLineRest = CurLineRest(2:end); end
                     if length(CurLineRest) == 1, if CurLineRest(1) == '''', CurLineRest = ''; end, end
                     CurLineRest = deblankall(CurLineRest);
                     if isempty(CurLineRest), break; end
                     if ipara == 1, ParaValue = {ParaValue}; end
                     ipara = ipara +1;
                  end
               % otherwise numbers are included
               else
                  ParaValue = sscanf(CurLine, '%g');
                  ParaValue = ParaValue';
               end
            end
   
            % Put the option into the options structure
            % Decompose long fieldnames into their parts
            OptNameAll = fieldnames_parts(OptName);
            % Get fieldnames of all previous options
            if isempty(Options), AllOptFieldNames = '';
            else AllOptFieldNames = fieldnames_full(Options); end
            % Check, if the current options was red before
            IxCmp = strcmp(AllOptFieldNames, OptName);
            % If this option was read before
            if any(IxCmp),
               % add current options value to this parameter
               PrevParaValue = getfield(Options, OptNameAll{:});
               ParaValue = [PrevParaValue; ParaValue];
               % or extend size of structure element
               
            end
            % Set option in option structure         
            Options = setfield(Options, OptNameAll{:}, ParaValue);
            
            % disp(sprintf('%s|', CurLine));
         end
      end
      
   end
   
   % Close file
   fclose(fidload);


% End of function