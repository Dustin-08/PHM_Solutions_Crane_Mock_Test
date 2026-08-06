% Create/alter PARAOPTions structure
%
% This function creates or alters options structures.
% This function can be used for:
%  - creating a new complete options structure, all values set to defaults
%  - create a new partial options structure with given properties
%  - combine two or more predefined options structures into one
%  - change given properties of a options structure 
% The Example section below provides examples for all these possibilities.
%
% Syntax:  paraopt = paraoptset(P1, P2, P3, P4, ...)
%
% Input parameter:
%    See Examples below for description of possible inputs types and their 
%    corresponding functionality.
%
% Output parameter:
%    PARAOPT    - Structure with newly defined options
%
% See also: paraoptset, paraoptload, paraoptsave
%


function geaopt = paraoptexample(varargin)


   % Define possible properties, their default types, values and the ranges or possible values
   % Get cell array with properties from private function
   PARAProp = paraoptpropintern;

   % Call the utility function for all the data handling
   if all([nargout == 0, nargin == 0]), paraoptset({PARAProp});
   else geaopt = paraoptset({PARAProp}, varargin{:}); end


% End of function



% Private function
%
%
% Create a default PARAOPTions cell array containing the definition of possible options
%
% Syntax:  [PARAPropDef, PARAPropAssign] = paraoptpropexample
%
% See also: paraoptset, paraoptload, paraoptload

% Author:   Hartmut Pohlheim
% History:  23.04.2006  file created


function PARAPropDef = paraoptpropintern

   % See paraoptset for a full description
   % Type:   1: integer, 2: scalar, 3: string, 4: scalar, 5: all
   % Multi:  0: just one, 1: number multi, 2: multiple/any number

   %     Property Name       Type     Default value     min Range max  Number of parameter
   PARAPropDef = [ ...
       {'NumberMulti'},      {3},     {'NumPara'},       {[NaN NaN]},  {0}; ...
       {'NumPara'},          {1},     {4},               {[1 Inf]},    {0}; ...
       {'MainNumber'},       {1},     {[25,20,15,30]},   {[1 Inf]},    {1}; ...
       {'ParaMain.Name'},    {3},     {{'selsus'}},      {[NaN NaN]},  {1}; ...
       {'ParaMain.Option1'}, {2},     {[1.7]},           {[0 Inf]},    {1}; ...
       {'ParaExtra.Name'},   {3},     {{'mutreal'}},     {[NaN NaN]},  {1}; ...
       {'ParaExtra.Rate'},   {2},     {[1]},             {[0 Inf]},    {1}; ...
       {'Method3.Para1'},    {2},     {1e-4},            {[0 Inf]},    {0}; ...
       {'Method3.Para2'},    {4},     {[]},              {[NaN NaN]},  {2}; ...
       {'Method3.Para3'},    {4},     {[]},              {[NaN NaN]},  {2}; ...
       {'Method4.Para'},     {1},     {0},               {[0 21]},     {0}; ...
       {'Method4.Name'},     {3},     {' '},             {[NaN NaN]},  {0}; ...
       {'Method4.Option'},   {4},     {[]},              {[NaN NaN]},  {2}; ...
      ];             


% End of function