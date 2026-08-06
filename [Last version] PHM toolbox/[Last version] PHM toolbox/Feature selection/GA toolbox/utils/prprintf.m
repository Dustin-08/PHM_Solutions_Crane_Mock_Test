% Pretty Print formated of variable
%
% This function takes the given variable and produces a string
% containing the contents of the variable in a pretty printed
% format.
% The function checks the variable, if it contains characters.
% When characters are in the variable/matrix, each row is printed
% as one string without looking at 'Format'. 'Between' is used as
% divider.
% Otherwise (VarData contains only numbers), each element is printed
% using 'Format'. 'Between' is used to divide the elements of one
% row. Between rows a number of spaces is included to visually
% divide the rows.
% If the variable contains structures or cell arrays, this function 
% is called recursively for every element, even structure arrays.
% An internal function prstruct handles the special case of structures
% appropriately. The field names are printed as well, every element on
% a single line.
% All this produces a good looking string of the elements in 'VarData'
% without worrying to much about the format of the elements.
%
% Syntax:  [PrString, ErrMsg] = prprintf(Format, Between, VarData)
%
% Input parameter:
%    Format    - (optional) String containing formatstring, uses same 
%                syntax as sprintf
%                   if omitted, '%g' is used
%    Between   - (optional) String containing characters to put
%                between elements in VarData 
%                   if omitted, '   ' is used
%    VarData   - Variable(s) to pretty print, may be a scalar,
%                a character, a string, a matrix, a cell array or 
%                a structure with all of this, even mixed up
%
%    If only 2 input parameters are provided, the first input is
%    Format and the second input VarData, Between is set to an empty
%    string.
%
%    If only 1 input parameters is provided, the first input is
%    VarData, Format and  Between are set to default values.
% 
% Output parameter:
%    PrString  - String containing the elements in VarData pretty
%                printed
%    ErrMsg    - String containing possible error message, then PrString
%                is an empty string
%                ErrMsg is an empty matrix, when no error occured
%
% Examples:
% >>prprintf('%g', '/', [1.02 4.07 3.0532])
%     1.02/4.07/3.0532
%
% >>prprintf('%.3g ', [1.02 4.07; 3.0532 5.875; 3.324 4.123])
%     1.02 4.07   3.05 5.88   3.32 4.12
%
% >>prprintf('%s', ' ', ['eins';'zwei';'drei';'vier'])
%     eins zwei drei vier
%
% Try prprintf with cell arrays and structures as well!
%
% See also: sprintf

% Author:   Hartmut Pohlheim
% History:  12.08.97    file created
%                       file commented
%           01.09.98    support for non-numeric and non-char data added
%                          (no longer an error is issued)
%           19.11.98    output of structure data added, a separate internal
%                          function prstruct handles this data type
%           24.11.98    handling of empty elements added, produced some 
%                          problems when used in structures
%           02.12.98    now just one parameter works as well, using 
%                          defaults for Format and Between
%           18.02.99    handling of structure arrays added 
%                          (s(1).a, s(2).a and so on)


function [PrString, ErrMsg] = prprintf(Format, Between, VarData)
 
% Set output variables to default values
   PrString = '';
   ErrMsg = [];
   
% Check input parameters
   if nargin < 1, ErrMsg = 'Nothing to pretty print!'; return;
   elseif nargin < 2, VarData = Format; Format = '%g'; Between = '   ';
   elseif nargin < 3, VarData = Between; Between = '   '; end
   
   [NRow NCol] = size(VarData);

   MatlabVersion = version;
   
   % Check for characters in VarData, and a check for Between as cell array (only >Matlab5)
   Between2 = '  ';
   if MatlabVersion(1) <= '4', 
      VarIsNumorStr = 1;   % in Matlab 4 only numeric data and strings existed
   else
      VarIsNumorStr = any([isnumeric(VarData), ischar(VarData)]);
      if iscell(Between),
         if length(Between) == 1, Between = Between{1};
         else Between2 = Between{2}; Between = Between{1}; end
      end
   end

   % Do pretty printing for numeric or string data
   if isempty(VarData),
      PrString = ' -empty- ';
   elseif VarIsNumorStr == 1,
      % Check for characters in VarData
      if MatlabVersion(1) <= '4', VarIsChar = isstr(VarData);
      else                        VarIsChar = ischar(VarData); end
      
      % When characters/strings in VarData
      if VarIsChar,
         % If Format contains a string formatter, use this Format, else standard %s
         if ~(isempty(findstr(Format, 's'))), StrFormat = Format; else StrFormat = '%s'; end 
         % Print the strings variables into the pretty string
         PrString = [PrString sprintf(StrFormat, VarData(1, :))];
         for irow = 2:NRow,
            PrString = [PrString sprintf([Between StrFormat], VarData(irow, :))];
         end
      % When numbers in VarData
      else
         for irow = 1:NRow,
            if irow > 1, PrString = [PrString Between2]; end
            PrString = [PrString sprintf(Format, VarData(irow, 1))];
            if NCol > 1,
               PrString = [PrString sprintf([Between Format], VarData(irow, 2:NCol))];
            end
         end
      end
   % when VarData is a cell array, struct or something else, do some appropriate things
   else
      if iscell(VarData),
         VarLength = prod(size(VarData));
         for icell = 1:VarLength,
            PrStringAdd = prprintf(Format, {Between, Between2}, VarData{icell});
            PreCell = ''; if isempty(Format), PreCell = sprintf('{%d}  ', icell); end
            PrString = [PrString sprintf('%s%s   ', PreCell, PrStringAdd)];
         end
      elseif isstruct(VarData),
         StructLevel = 1;
         [PrStringAdd, ErrMsg] = prstruct(StructLevel, Format, {Between, Between2}, VarData);
         PrString = [PrString '  ' PrStringAdd];
      else
         PrString = 'Non-numeric or non-char data, will be supported later !';
      end
   end


% internal function prstruct
%
% special handling for structures
%
function [PrString, ErrMsg] = prstruct(StructLevel, Format, Between, StructVar)

   PrString = '';
   SpaceLevel = '     ';
   
   % Get field names of given structure and create corresponding char array
   PrFieldNames = fieldnames(StructVar);
   PrFieldNamesJust = char(PrFieldNames);
   
   % Loop over all structure array elements
   StructLength = prod(size(StructVar));
   for istruct = 1:StructLength,
      StartSpace = repmat(SpaceLevel, [1, StructLevel]);
      % Output of array element number (separate line)
      if StructLength > 1,
         StructArrayNumber = sprintf('(%d)', istruct); 
         PrString = [PrString, sprintf('\n%s%s', StartSpace(1:end-3), StructArrayNumber)];
      end
      % Loop over all fields in structure
      for ifield = 1:length(PrFieldNames),
         FieldVar = getfield(StructVar(istruct), PrFieldNames{ifield});
         % Call function recursively, when structure in structure
         if isstruct(FieldVar),
            [PrStringAdd, ErrMsg] = prstruct(StructLevel+1, Format, Between, FieldVar);
            Extra = ' ';
         % call prprintf for the other data types
         else
            [PrStringAdd, ErrMsg] = prprintf(Format, Between, FieldVar);
            Extra = ' :';
         end
         PrString = sprintf('%s\n%s%s %s  %s', PrString, StartSpace, PrFieldNamesJust(ifield,:), Extra, PrStringAdd);
      end
   end


% End of function
