% ToolBoX function to define parameters for multi-objective optimization 1
%
% This function defines parameters for a multi-objective optimization.
%
% First of all the multi-objective ranking is switched on. At the same time 
% the multi-objective visualization is switched on (every 10 generations).
% Additionally, the useful standard visualization methods for multi-objective
% optimization are selected (variables of all individuals and order of 
% subpopulations).
%
% Syntax:  GEAOPT = tbx3moo1
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: demomop, democantilever, tbx3real, geamain2, geaoptset

% Author:   Hartmut Pohlheim
% History:  05.11.2006  file created


function GEAOPT = tbx3moo1


% Set function specific parameters
   GEAOPT = geaoptset( 'Selection.RankingMultiobj', 20      ...   % Switch on multi-objective ranking and MO visualization every 10 generations
                     , 'Output.GrafikInterval',     10     ...    % How often to visualize state and course of optimization
                     , 'Output.GrafikMethod',       200101 ...    % Which standard grahics to viusalize, only these 2 are useful currently
                     , 'Output.GrafikStyle',        614144 ...    % Which method to use for standard graphics
                     , 'Output.TextExcludeSub',      1 ...        % Exclude info on subpopulations
                     );


% End of function

