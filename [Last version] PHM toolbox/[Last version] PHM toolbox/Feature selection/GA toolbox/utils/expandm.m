% EXPAND a Matrix, utility function
%
% This function expands a matrix MatIn in both dimensions.
% In the output matrix MatOut each element of MatIn is
% repeated as often as defined in EXPN. The size of MatOut is
% [EXPN(1)*size(MatIn,1), EXPN(2)*size(MatIn,2)].
% This function is used in the GEA Toolbox.
%
% Input parameters:
%    MatIn     - Input Matrix (before expanding)
%    EXPN      - Vector of 2 numbers, how often expand in each
%                   dimensiom
%                EXPN(1): replicate vertically
%                EXPN(2): replicate horizontally
%
% Output parameter:
%    MatOut    - Output Matrix (after expanding)
%
% Example:
%    MatIn = [1 2 3
%             4 5 6]
%
%    EXPN = [1 2] => MatOut = [1 1 2 2 3 3;
%                              4 4 5 5 6 6]
%
%    EXPN = [2 1] => MatOut = [1 2 3;
%                              1 2 3;
%                              4 5 6;
%                              4 5 6]
%
%    EXPN = [3 2] => MatOut = [1 1 2 2 3 3;
%                              1 1 2 2 3 3;
%                              1 1 2 2 3 3;
%                              4 4 5 5 6 6;
%                              4 4 5 5 6 6;
%                              4 4 5 5 6 6]
%
% See also: repmat

% Author:   Hartmut Pohlheim
% History:  13.02.97    file created

function MatOut = expandm(MatIn, EXPN)

% Check input parameters
   if nargin < 2, error('Not enough input parameters!'); end
   if isempty(EXPN), MatOut = MatIn; return; end
   if any(EXPN < 0), error('Expand dimension EXPN must be 1 or 2 numbers > 0!'); end

% If only one number is given, expansion in both dimensions is equal
   if length(EXPN) < 2, EXPN = [EXPN(1), EXPN(1)]; end

% Get size of input matrix
   [MatRows, MatCols] = size(MatIn);

% Calculate expand index
   RowsIx = (1:MatRows);
   ColsIx = (1:MatCols);
   RowsIx = RowsIx(ones(EXPN(1), 1), :);
   ColsIx = ColsIx(ones(EXPN(2), 1), :);

% Create output matrix
   MatOut = MatIn(RowsIx(:), ColsIx(:));


% End of function