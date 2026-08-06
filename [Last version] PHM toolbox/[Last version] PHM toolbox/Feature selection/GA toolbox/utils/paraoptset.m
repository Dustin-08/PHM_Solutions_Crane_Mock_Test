% Create/alter PARAOPTions structure
%
% This function creates or alters options structures.
% This function can be used for:
%  - creating a new complete options structure, all values set to defaults
%  - create a new partial options structure with given properties
%  - combine two or more options structures into one
%  - change given properties of a options structure 
% The Example section below provides examples for all these possibilities.
%
% Syntax:  paraopt = paraoptset(PARAOPTDEF, P1, P2, P3, P4, ...)
%
% Input parameter:
%    PARAOPTDEF - Cell array defining the nameof possible options, their type,
%                 default value and a possible dimensionality
%    P1 ...     - Parameters/options and their values in name/value pairs
%    See Examples below for description of possible inputs types and their 
%    corresponding functionality.
%
% Output parameter:
%    PARAOPT    - Structure with newly defined options
%
% See also: paraoptload, paraoptsave, paraoptpropprint (private), fieldnames_parts, fieldnames_full
%
% Examples:
% 
%  paraoptset 
%     Called with no input and output arguments displays all property names and
%     their possible values, including the default value. paraoptset property
%     defaults for any unspecified property are taken from the values specified
%     inside this function.
%
%  paraopt_full = paraoptset 
%     Called with no input arguments returns a paraoptions structure with all 
%     possible property names and set to their default value.
%
%  paraopt_part = paraoptset('name', value1, 'name2', value2, ...) 
%     Creates a partial paraoptions structure in which the given 
%     properties have the specified values.  It is sufficient to 
%     type only the leading characters that uniquely identify the property.
%     Case is ignored for the property names.
%     paraopt_part = paraoptset('Mutation.Name', 'mutint', 'Mutation.Range', 0.1)
%        The structure paraopt_part contains just the fields 'Mutation.Name'
%        and 'Mutation.Range' set to the specified values.
%
%  paraopt = paraoptset(paraopt_part, 'name1', value1, ...) 
%     Alters an existing paraoptions structure paraopt_part using the given
%     properties.
%     paraopt_new = paraoptset(paraopt_part, 'Recombination.Name', 'recdis', Mutation.Name', 'mutreal')
%        The structure paraopt_part defined in the previous example is extended 
%        with the property 'Recombination.Name'. The property 'Mutation.Name' 
%        is set to a new value.
%
%  paraopt = paraoptset(paraoptold, paraoptnew) 
%     Combines an existing paraoptions structure paraoptold with a new 
%     paraoptions structure paraoptnew. Any new properties overwrite 
%     corresponding old properties.
%
%  paraopt_all = paraoptset(paraoptset, paraopt_new)
%     The full and default structure returned by paraoptset (see second 
%     example above) is redefined with the properties from paraopt_new, 
%     which was preset in the examples above.
%
%  paraopt = paraoptset(paraoptcheck)
%     When called with just one paraoptions structure as input parameter, the values 
%     of these properties are checked (violation of boundaries, when multi strategy - then
%     the number of values is set to the number of subpopulations and so on).


% Author:   Hartmut Pohlheim
% History:  20.10.1998  file created
%           21.10.1998  interface defined
%                       property names of structure defined
%           28.10.1998  finished definition, setting and combination of 
%                          paraoptions structure
%           29.10.1998  replaced fprintf by sprintf and disp in output of 
%                          default values (paraoptpropprint), much quicker now
%           05.11.1998  number of parameters for every property is checked 
%                          against defined possibilities in PropMulti
%           25.05.1999  check of parameter boundaries added, values are reset 
%                          to boundaries, when outside
%                       when parameter integer, then round of parameter
%           02.06.1999  reworked all getfield/setfield to muli sub index working
%           14.03.2000  moved large data property cell array in private 
%                          subfunction (needed for C++-compilation)
%           14.09.2000  moved printing of default cell array to subfunction
%           28.05.2001  adapted for general use
%           17.02.2002  subfunctions reworked, more comments
%           04.10.2002  handling of multi element parameters added (one parameter
%                          defines the exact number of parameter values, see
%                          'NumberMulti')
%           23.04.2006  replaced all error calls with warning calls


function paraopt = paraoptset(PARAOPTDEF, varargin)

% Save nargin and nargout
   NAIN = nargin; NAOUT = nargout;

% Define application specific properties, their default types, values and the ranges or possible values
   % Get cell array with properties (name, type range, default value)
   PARAProp = PARAOPTDEF{1};
   % PropAssign = PARAOPTDEF{2};
   NAIN = NAIN - 1;

   % Get assignment of row to value in property cell array
   % PropName = PropAssign(1); PropType = PropAssign(2); PropDefval = PropAssign(3); PropRange = PropAssign(4); PropMulti = PropAssign(5);
   PropName = 1; PropType = 2; PropDefval = 3; PropRange = 4; PropMulti = 5;
    
   % Create char array from property names
   PARAPropNames = char(PARAProp{:, PropName});
   
   % Get number of possible properties
   [NProp, NDummy] = size(PARAProp);

   % Print out possible/default values of paraopt.
   if all([NAIN == 0, NAOUT == 0]),
      paraoptpropprint(PARAProp);
      return;
   end
   
   % Create a default paraoptions structure
   paraopt = [];
   if all([NAIN == 0, NAOUT > 0]),
      for jprop = 1:NProp,
         % Set field value to empty field
         % paraopt = setfield(paraopt, PARAProp{j, PropName}, []);

         % Set field value to default value
         PARAPropNameFields = fieldnames_parts(PARAProp{jprop, PropName});
         paraopt = setfield(paraopt, PARAPropNameFields{:}, PARAProp{jprop, PropDefval});
      end
   end

   % Run through all leading paraoptions structures and combine them
   inain = 1;
   while inain <= NAIN,
      arg = varargin{inain};
      if isstr(arg), break; end          % arg is an option name
      if ~isempty(arg)                   % [] is a valid paraopt argument
         % Check for a struct argument, when not - warning and ignore
         if ~isa(arg, 'struct')
            warning(sprintf(['Expected argument %d to be a string property name ' ...
                             'or an PARAOPTIONS structure.'], inain));
         % Process found struct argument
         else
            % Create cell array with all full fieldnames of current paraoptions structure
            FieldNamesFull = fieldnames_full(arg);

            % Run through all properties and set them to new value when defined 
            % in current paraoptions structure
            for j = 1:NProp,
               % Get the parts of the option name
               PARAPropNameFields = fieldnames_parts(PARAProp{j, PropName});

               % Compare name of current option to all provided
               IxCmp = strcmp(FieldNamesFull, deblank(PARAProp{j, PropName}));

               if any(IxCmp),
                  NewValue = getfield(arg, PARAPropNameFields{:});
                  paraopt = setfield(paraopt, PARAPropNameFields{:}, NewValue);
               elseif NAIN == 1,
                  % Set field value to default value
                  paraopt = setfield(paraopt, PARAPropNameFields{:}, PARAProp{j, PropDefval});
               end

               % Do the following only, when just one input argument defined 
               % (special case for checking validity of parameters)
               if NAIN == 1,
                  % Check and reset values of options
                  if any(PARAProp{j, PropType} == [1 2 4]),
                     MinMaxVal = PARAProp{j, PropRange};
                     % Do only check, when Range not NaN
                     if ~(isnan(MinMaxVal(1))),
                        FieldValue = getfield(paraopt, PARAPropNameFields{:});
                        % Set all values larger than the max value to the max value
                        FieldValue = max(repmat(MinMaxVal(1), size(FieldValue)), FieldValue);
                        % Set all values samller than the min value to the min value
                        FieldValue = min(repmat(MinMaxVal(2), size(FieldValue)), FieldValue);
                        % When value should be an integer (Type == 1), then round the value
                        if PARAProp{j, PropType} == 1, FieldValue = round(FieldValue); end
                        % Put the checked value back into the paraoptions structure
                        paraopt = setfield(paraopt, PARAPropNameFields{:}, FieldValue);
                     end
                  end

                  % Check and set number of option values for this parameter depending on number in multi parameter
                  % vectors and matrices can be extended (along the second dimension)
                  if PARAProp{j, PropMulti} == 1,
                     % Check, if PARAOPTIONS option 'NumberMulti' does exist
                     if isfield(paraopt, 'NumberMulti'),
                        if isfield(paraopt, paraopt.NumberMulti),
                           % Get the number from 'NumberMulti' for the number of multiple options
                           NumMulti_1 = getfield(paraopt, paraopt.NumberMulti);
                           FieldValue = getfield(paraopt, PARAPropNameFields{:});
                           if all([PARAProp{j, PropType} == 3, ~(iscell(FieldValue))]), FieldValue = {FieldValue}; end
                           % When the number of options in the property and 'NumberMulti' not identical
                           if size(FieldValue,2) ~= NumMulti_1,
                              % Replicate the available options as much as necessary (could be more than needed)
                              NewValue = repmat(FieldValue, [1, ceil(NumMulti_1/size(FieldValue,2))]);
                              % Take exact 'NumberMulti' options from the replicated options
                              NewValue = NewValue(:, 1:NumMulti_1);
                              % Put the now correct number of options back into PARAOPTIONS structure
                              paraopt = setfield(paraopt, PARAPropNameFields{:}, NewValue);
                           end
                        end
                     end

                  % Ensure, that option contains only one value (PropMulti == 0)
                  elseif all([PARAProp{j, PropMulti} == 0, any(PARAProp{j, PropType} == [1, 2])]),
                     FieldValue = getfield(paraopt, PARAPropNameFields{:});
                     paraopt = setfield(paraopt, PARAPropNameFields{:}, FieldValue(1));

                  % Do not do something, number of values was not bounded (PropMulti == 2)
                  elseif PARAProp{j, PropMulti} == 2,
                     % do nothing, may be one or more values
                  end
               end
            end
         end
         
      end
      inain = inain + 1;
   end


   % Check the number of remaining options/arguments, should be a multiple of 2 (name-value pairs)
   % Issue just a warning, missing arguments will be addressed later in detail
   if rem(NAIN-inain+1,2) ~= 0, warning('Properties should occur in pairs: property name / value.'); end

   % Start expecting a property name, not a value and a correct string value
   ExpectValue = 0; StringValueWrong = 0; 
   while inain <= NAIN
      % Get the next argument from input parameters
      arg = varargin{inain};
      % Expect a correct property or value
      StringValueWrong = 0;

      % Look for a property name (not a value)
      if ~ExpectValue
         % Check, if the property is a string, warning, when not
         if ~isstr(arg), 
            warning(sprintf('Argument  %d  must be a string property name.', inain));
            StringValueWrong = 1;
         end

         % When we found a string
         if StringValueWrong == 0,
            % Make the strings low case for later comparison
            lowArg = lower(arg); lowPARAPropNames = lower(PARAPropNames);
            % Compare property string with possible properties
            j = strmatch(lowArg, lowPARAPropNames);
            % No matches found
            if isempty(j),
               warning(sprintf('Unrecognized property name ''%s''.', arg));
               StringValueWrong = 1;
            % More than one match found
            elseif length(j) > 1,
               % Check for any exact matches (in case any names are subsets of others)
               k = strmatch(lowArg, lowPARAPropNames, 'exact');
               % One exact match found
               if length(k) == 1,
                  j = k;
               % Multiple exact matches found, user must define the property names more exact
               else
                  warning(sprintf('The given property name ''%s'' is not unique enough! Possible matches:  %s .', ...
                                  arg, prprintf('%s', ', ', char(PARAProp{j, PropName}))));
                  StringValueWrong = 1;
               end
            end
         end
         % Only when the property name was correct, we expect a property value next
         if StringValueWrong == 0,
            ExpectValue = 1;
         end

      else
         % Get the parts of the option name
         PARAPropNameFields = fieldnames_parts(PARAProp{j, PropName});
         paraopt = setfield(paraopt, PARAPropNameFields{:} , arg);
         ExpectValue = 0;
      end
       
      inain = inain + 1;
   end

   % Issue a warning, when no value was found after a property name
   if all([ExpectValue == 1, StringValueWrong == 0]), 
      warning(sprintf('An value was expected for property ''%s''.', arg));
   end


% End of function



% Private function
%
% This private function prints a default PARAOPTions cell array on screen.
%
% Syntax:  PARAProp = paraoptpropprint
%
% See also: paraoptset

% Author:   Hartmut Pohlheim
% History:  14.09.2000  file created
%           28.05.2001  adapted for general use


function paraoptpropprint(PARAProp),


   % Get assignment of row to value in property cell array
   PropName = 1; PropType = 2; PropDefval = 3; PropRange = 4; PropMulti = 5;

   % Create char array from property names
   PARAPropNames = char(PARAProp{:, PropName});
   PARAPropNamesRight = strjust(PARAPropNames, 'left');
   
   % Get number of possible properties
   [NProp, NDummy] = size(PARAProp);
   
   % Define descriptive strings for number options
   AbrPARAPropType = strvcat('positive integer', 'positive scalar', 'string', 'scalar', 'all');
   AbrPARAPropMulti = strvcat('just one', 'NumberMulti', 'multi');
   LZ10 = '          ';
   
   % Get the length of the longest parameter name and add 3 spaces
   PARAPropHeadLength = size(PARAPropNamesRight, 2) + 3;
   % Define heading for parameter options
   PARAPropHeading = '   Property Name   ';
   % If the length of the parameter name is longer than the heading, add extra spaces to heading
   if PARAPropHeadLength > length(PARAPropHeading),
      PARAPropNameExtra = '';
      PARAPropHeading = sprintf('%s%s', PARAPropHeading, repmat(' ', [1, PARAPropHeadLength-length(PARAPropHeading)]));
   % If parameter names are shorter, create string with necessary extra spaces
   else PARAPropNameExtra = repmat(' ', [1, max(1, length(PARAPropHeading)-PARAPropHeadLength)]); end

   % Define the remaining headers (non-changing length)
   PARAPropHeading = sprintf('%s   Type     %s    min.   Range    max.        Number of para.      Default value   ', PARAPropHeading, LZ10);

   % Define main heading and start printing into string
   OutStr = sprintf('\nProperties of PARAOPT and their possible and default settings:\n\n');
   OutStr = [OutStr, sprintf('%s\n', PARAPropHeading), sprintf('%s\n', repmat('-', [1, length(PARAPropHeading)]))];

   % Print the options nicely into a string
   for ip = 1:NProp,
      OutStr = [OutStr, sprintf('   %s   %s',   PARAPropNamesRight(ip, :), PARAPropNameExtra)];
      OutStr = [OutStr, sprintf('%s',          AbrPARAPropType(PARAProp{ip,PropType}, :))];
      OutStr = [OutStr, sprintf('%28s',        prprintf('%10.3g   ', PARAProp{ip,PropRange}))];
      OutStr = [OutStr, sprintf('      %s    ', AbrPARAPropMulti(PARAProp{ip,PropMulti}+1, :))];
      OutStr = [OutStr, sprintf('      %s',    prprintf('%g', '  ', PARAProp{ip,PropDefval}))];
      OutStr = [OutStr, '\n'];
   end
   
   % Print the string on screen
   fprintf(OutStr);


% End of private function


% Private function
%
% Create cell array with all full fieldnames of given structure
%
% This function collects the complete/full fieldnames of a given 
% structure up to arbitrary levels and returnes them in a cell array.
% This function calls itself recursively to get the fieldnames of 
% the lower levels.
%
% Syntax:  [FieldNamesFull] = fieldnames_full(StructFull)
%
% Input parameters:
%    StructFull - Structure of any form
%
% Output parameter:
%    FieldNamesFull - cell array of strings containing the complete 
%                     fieldnames of the input structure
%
% Example:
% % Get the complete/full fieldnames of the structure
% >> ExplStruct.First = 24;
% >> ExplStruct.SecondField.Higher = 'no';
% >> ExplStruct.SecondField.Deeper.Really = 38;
% >> FullFieldNames = fieldnames_full(ExplStruct)
%    FullFieldNames = 
%      { 'First'
%        'SecondField.Higher'
%        'SecondField.Deeper.Really'
%      }
%
% See also: paraoptset, paraoptsave, paraoptload, fieldnames_parts
     
% Author:   Hartmut Pohlheim
% History:  17.02.2002  file created (taken from compdiv)


function [FieldNamesFull] = fieldnames_full(StructFull)

   % Check for empty input or no-structure input, return with empty cell array
   if any([isempty(StructFull), ~(isstruct(StructFull))]), return; end

   % Preset output parameter
   FieldNamesFull = {};
   
   % Get fieldnames of first level in structure
   FieldNamesCurrent = fieldnames(StructFull);
   FieldNamesFull = {};

   for ifull = 1:size(FieldNamesCurrent, 1),
      StructLevel2 = getfield(StructFull, FieldNamesCurrent{ifull});
      if isstruct(StructLevel2),
         FieldNamesInt = fieldnames_full(StructLevel2);
         FieldNamesNew = strcat(FieldNamesCurrent{ifull}, '.', FieldNamesInt);
      else FieldNamesNew = FieldNamesCurrent(ifull); end
      FieldNamesFull = [FieldNamesFull; FieldNamesNew];
   end


% End of private function



% Private function
%
% Decompose long/full fieldnames into their parts
%
% This function decomposes the full structure fieldname into its parts.
% The partial strings are returned in a cell array.
%
% Syntax:  [FieldNameParts] = fieldnames_parts(FieldNameFull)
%
% Input parameters:
%    FieldNameFull - String containing one full structure fieldname
%                    (mostly created by fieldnames_full)
%
% Output parameter:
%    FieldNameParts - cell array of strings containing the parts of the full 
%                     structure fieldnames
%
% Example:
% % Get the partial field names from the full fieldname
% >> FieldNameParts = fieldnames_parts('SecondField.Deeper.Really')
% >> FieldNameParts = 
%     'SecondField'    'Deeper'    'Really'
%
% See also: paraoptset, paraoptsave, paraoptload, fieldnames_full
     
% Author:   Hartmut Pohlheim
% History:  17.02.2002  file created (taken from compdiv)


function [FieldNameParts] = fieldnames_parts(FieldNameFull)

   % Preset output parameter
   FieldNameParts = {};
   
   NameRest = FieldNameFull;
   % Take all parts before '.', one after the other
   while ~(isempty(NameRest)),
      [Part, NameRest] = strtok(NameRest, '.');
      FieldNameParts = {FieldNameParts{:}, Part};
   end


% End of private function