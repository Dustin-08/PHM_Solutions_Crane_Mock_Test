% perform goal preference calculation between multiple objective values
%
% This function performs goal preference ranking between individuals.
% This is used during the calculation of fitness values in 
% the ranking of multiple objective values.
%
% Syntax:  FitnVShare = rankgoal(ObjV1, ObjV2, Goals)
%
% Input parameters:
%    ObjV1/2   - Row vectors containing the objective values of 
%                   one individual each
%    Goals     - Row vector containing goals for all objective values
%
% Output parameters:
%    Prefer    - Scalar indicating preference of ObjV1 over ObjV2
%
% See also: ranking, rankshare

% Author:   Hartmut Pohlheim
% History:  28.04.99    file created


function Prefer = rankgoal(ObjV1, ObjV2, Goals)

   % Error checkingexcluded for speed
   % Check input parameters
   % if(size(ObjV1) ~= size(ObjV2)), error('Objective values must have the same size!'), end

   if nargin < 3, Goals = []; end

   if isempty(Goals),
      i_sat = [];
      i_not = 1:length(ObjV1);
   else
      % Find satisfying and not-satisfying goals for ObjV1
      i_sat = find(ObjV1 <= Goals);
      i_not = find(ObjV1 >  Goals);
   end

   % 
   if length(i_not) == 0,        % all goals satiesfied
      Prefer = any([rankplt(ObjV1, ObjV2), any(ObjV2 > Goals)]);

   elseif length(i_sat) == 0,    % no goal satiesfied
      Prefer = rankplt(ObjV1, ObjV2);

   else                          % case mixed
      Prefer = any([rankplt(ObjV1(i_not),ObjV2(i_not)), ...
                    all([all(ObjV1(i_not) == ObjV2(i_not)), ...
                         any([rankplt(ObjV1(i_sat),ObjV2(i_sat)), any(ObjV2(i_sat) > Goals(i_sat))]) ...
                        ]) ...
                   ]);
   end


% End of function
