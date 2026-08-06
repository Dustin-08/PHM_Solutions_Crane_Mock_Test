% RANK two multi objective values Partially Less Than
%
% This function compares two multi objective values 
% by partuially less than. If the first one is PLT, 
% Prefer is 1, else 0.
%
% This is used during the ranking of multi objective values.
%
% Input parameters:
%    ObjV1/2   - Row vectors containing the objective values of 
%                   one individual each
%
% Output parameters:
%    Prefer    - Scalar indicating parttially less than of ObjV1 
%                   compared to ObjV2

% Author:   Hartmut Pohlheim
% History:  28.04.99    file created


function Prefer = rankplt(ObjV1, ObjV2);

   % Error checking excluded for speed
   % if(size(ObjV1) ~= size(ObjV2)), error('Objective values must have the same size!'), end

   Prefer = all([ObjV1 <= ObjV2, any(ObjV1 < ObjV2)]);


% End of function
