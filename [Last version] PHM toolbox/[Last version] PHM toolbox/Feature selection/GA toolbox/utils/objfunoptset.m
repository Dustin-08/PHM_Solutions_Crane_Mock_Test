% Create/alter OPTions structure for parameter SETtings of OBJective FUNctions
% 
% FunctionName : Name or Description of function
% VarBoundMin  : Lower  boundary or boundaries for VLUB
% VarBoundMax  : Higher boundary or boundaries for VLUB
% NumVarDefault: Default amount of variables used in objective function
% NumVarMin    : Minimal amount of variables
% NumVarMax    : Maximal amount of variables
% NumObjDefault: Default number of objectives created by function
% NumObjMin    : Minimum number of objectives the function can create
% NumObjMax    : Maximum number of objectives the function can create
% GlobalMinVar : Variables of the global minimum (only valid for single-criteria function)
% GlobalMinObj : Global minimum of a single criteria function (if known)
% MObjGoals    : Goals for (multiple) objectives
%
% See also: paraoptset for a full description

% Author:   Hartmut Pohlheim
% History:  04.09.2001  file created
%           29.01.2006  added 'MObjGoals' for definition of goals in objective function


function objfunopt = objfunoptset(varargin)

   % Define possible properties, their default types, values and the ranges or possible values
   % Get cell array with properties (name, type range, default value) from private function
   [PARAProp, PropAssign] = objfunoptpropdef;

   % Call the utility function for all the data handling
   if all([nargout == 0, nargin == 0]), paraoptset({PARAProp, PropAssign});
   else objfunopt = paraoptset({PARAProp, PropAssign}, varargin{:}); end
   

% End of function



% Private function
%
% This private function creates and returnes a default OBJFUNOPTions cell array.
%
% Syntax:  [ObjFunProp, PropAssign] = objfunoptpropdef
%
% See also: paraoptset

% Author:   Hartmut Pohlheim
% History:  28.05.2001  file created


function [ObjFunProp, PropAssign] = objfunoptpropdef,

   % Define assignment of row to value in property cell array
   PropName = 1; PropType = 2; PropDefval = 3; PropRange = 4; PropMulti = 5;
   PropAssign = [PropName, PropType, PropDefval, PropRange, PropMulti];
   
   % See paraoptset for a full description
   % AbrPropType = strvcat('positive integer', 'positive scalar', 'string', 'scalar', 'all');
   % AbrPropMulti = strvcat('just one', 'num. subpop', 'multi');
   % PropHeading = ['   Property Name        Type       Default value   min.  Range   max.    Number of para.   '];

   ObjFunProp = [ ...
       {'FunctionName'},           {3},     { '' },           {[ NaN  NaN]}, {0}; ...
       {'VarBoundMin'},            {4},     {-Inf},           {[-Inf  Inf]}, {2}; ...
       {'VarBoundMax'},            {4},     { Inf},           {[-Inf  Inf]}, {2}; ...

       {'NumVarDefault'},          {1},     {   2},           {[   1  Inf]}, {0}; ...
       {'NumVarMin'},              {1},     {   1},           {[   1  Inf]}, {0}; ...
       {'NumVarMax'},              {1},     { Inf},           {[   1  Inf]}, {0}; ...
       
       {'NumObjDefault'},          {1},     {   1},           {[   1  Inf]}, {0}; ...
       {'NumObjMin'},              {1},     {   1},           {[   1  Inf]}, {0}; ...
       {'NumObjMax'},              {1},     { Inf},           {[   1  Inf]}, {0}; ...

       {'GlobalMinVar'},           {4},     {-Inf},           {[-Inf  Inf]}, {2}; ...
       {'GlobalMinObjV'},          {4},     {-Inf},           {[-Inf  Inf]}, {2}; ...

       {'MObjGoals'},              {4},     {-Inf},           {[-Inf  Inf]}, {2}; ...

      ];


% End of private function

