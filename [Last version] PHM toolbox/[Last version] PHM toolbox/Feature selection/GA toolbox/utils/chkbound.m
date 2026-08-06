% CHecK the boundaries of variables and set to boundaries when outside
%
% This function takes the variables of individuals and checks, if  
% the variables are inside the defined boundaries. If not, the
% variables outside the boundaries are set to values inside 
% the boundaries.
% An additional input parameter may define special variables, which 
% could extend ouside the defined boundaries.
%
% Syntax:  NewChrom = chkbound(Chrom, ChkOpt, VLUB, BoundOut)
%
% Input parameters:
%    Chrom     - A matrix containing the chromosomes of the
%                current population. Each row corresponds to
%                an individuals string representation.
%    ChkOpt    - (optional) Vector containing check bound options
%                ChkOpt(1): ChkReset - number containing the reset
%                           method for variables outsider boundaries
%                           0: reset variables to boundaries
%                           1: reset variables uniform into 10%-area
%                              from violated boundary (not implemented)
%                           if omitted or NaN, ChkReset = 0 is assumed
%    VLUB      - Matrix containing the boundaries of each variable.
%    BoundOut  - (optional) matrix of same size as VLUB, every value 
%                   defines, if the respective variable may "violate"
%                   the defined boundaries
%                 0: no vioaltion of boundaries possible (variable
%                       values outside the boundaries will be reset)
%                 1: variable values outside boundaries allowed
%
% Output parameter:
%    NewChrom  - Matrix containing the new individuals.
%
% See also: geamain2

% Author:   Hartmut Pohlheim
% History:  02.03.1998  file created
%           23.03.1998  first option added (reset outside variable values
%                          to boundaries
%           27.09.1999  new input parameter BoundOut, used for soft boundaries
%           05.10.2002  all error messages replaced by warnings


function NewChrom = chkbound(Chrom, ChkOpt, VLUB, BoundOut)

% Identify the population size (Nind) and the number of variables (Nvar)
   [Nind, Nvar] = size(Chrom);

% Set standard checkbound parameter
   ChkOptStandard = [0];      % ChkReset = 0
   
% Preset return variable
   NewChrom = Chrom; 

% Check parameter consistency
   if nargin < 3,  warning('Not enough input parameter. No boundary check performed.'); return; end
   
   [NrowsVLUB, NvarVLUB] = size(VLUB);
   if NrowsVLUB < 2, warning('VLUB must be a matrix with at least 2 rows. No boundary check performed.'); return; end
   if Nvar ~= NvarVLUB, % for instance, when using as functions
      NvarCh = NvarVLUB;
   else NvarCh = Nvar; end

   % If BoundOut is not given, set it to all zeros (enforce all boundaries)
   if nargin < 4,  BoundOut = []; end
   if isnan(BoundOut), BoundOut = []; end
   if isempty(BoundOut), BoundOut = zeros(2, NvarCh); end

   if isnan(ChkOpt), ChkOpt = []; end
   if length(ChkOpt) > length(ChkOptStandard), 
      warning('Too many parameters in ChkOpt. Reset to max number.'); ChkOpt = ChkOpt(1:length(ChkOptStandard));
   end

   ChkOptIntern = ChkOptStandard; ChkOptIntern(1:length(ChkOpt)) = ChkOpt;
   ChkReset = ChkOptIntern(1);

   if isnan(ChkReset), ChkReset = ChkOptStandard(1);
   elseif ~any(ChkReset == [0, 1]), 
      warning('Parameter for check bound reset must be one of [0, 1]! Reset to standard value.');
      ChkReset = ChkOptStandard(1);
   end


% Get the indices of variables, which may be outside the boundaries
   BoundOutIxMin = find(BoundOut(1,:) == 0);
   BoundOutIxMax = find(BoundOut(2,:) == 0);

% Ensure variables boundaries, compare with lower and upper boundaries
   % Set outside variables to boundaries
   if ChkReset == 0,  % 1:NvarCh
      NewChrom = Chrom;
      if ~(isempty(BoundOutIxMin)),
         NewChrom(:, BoundOutIxMin) = max(repmat(VLUB(1,BoundOutIxMin),[Nind 1]), NewChrom(:, BoundOutIxMin));
      end
      if ~(isempty(BoundOutIxMax)),
         NewChrom(:, BoundOutIxMax) = min(repmat(VLUB(2,BoundOutIxMax),[Nind 1]), NewChrom(:, BoundOutIxMax));
      end
   elseif ChkReset == 1,
   
   end
   


% End of function
