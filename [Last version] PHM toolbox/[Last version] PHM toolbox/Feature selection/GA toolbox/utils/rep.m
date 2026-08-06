% REPlicate a matrix, utility function
%
% This function repeats a matrix MatIn in both dimensions.
% In the output matrix MatOut the input matrix MatIn is
% repeated as often as defined in REPN. The size of MatOut is
% [REPN(1)*size(MatIn,1), REPN(2)*size(MatIn,2)].
% This function is widely used in the GEA Toolbox.
%
% Syntax:  MatOut = rep(MatIn, REPN);
%
% Input parameters:
%    MatIn     - Input Matrix (befor replicating)
%    REPN      - Vector of 2 numbers, how often replicate in each
%                   dimensiom
%                REPN(1): replicate vertically
%                REPN(2): replicate horizontally
%
% Output parameter:
%    MatOut    - Output Matrix (after replicating)
%
% Example:
%    MatIn = [1 2 3;
%             4 5 6]
%    REPN = [1 2] => MatOut = [1 2 3 1 2 3;
%                              4 5 6 4 5 6]
%    REPN = [2 1] => MatOut = [1 2 3;
%                              4 5 6;
%                              1 2 3;
%                              4 5 6]
%    REPN = [3 2] => MatOut = [1 2 3 1 2 3;
%                              4 5 6 4 5 6;
%                              1 2 3 1 2 3;
%                              4 5 6 4 5 6;
%                              1 2 3 1 2 3;
%                              4 5 6 4 5 6]
%
% See also: expandm

% Author:   Hartmut Pohlheim
% History:  14.02.96    file created
%           09.08.96    coding changed, easier to understand now
%           13.02.97    update of comments


function MatOut = rep(MatIn, REPN)

% Check input parameters
   if nargin < 2, error('Not enough input parameters!'); end
   if isempty(REPN), MatOut = MatIn; return; end
   if any(REPN < 0), error('Repeat dimension REPN must be 1 or 2 numbers > 0!'); end

% If only one number is given, expansion in both dimensions is equal
   if length(REPN) < 2, REPN = [REPN(1), REPN(1)]; end

% Get size of input matrix
   [MatRows, MatCols] = size(MatIn);

% Calculate repeat index
   RowsIx = (1:MatRows)';
   ColsIx = (1:MatCols)';
   RowsIx = RowsIx(:, ones(1, REPN(1)));
   ColsIx = ColsIx(:, ones(1, REPN(2)));

% Create output matrix
   MatOut = MatIn(RowsIx, ColsIx);


% End of function
