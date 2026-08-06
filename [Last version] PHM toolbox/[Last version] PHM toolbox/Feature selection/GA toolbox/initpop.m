% INITialization of POPulation (including innoculation)
%
% This function initializes the population with individuals
% taken from the provided input matrix PopInit.
% This initialization function checks, if the number of
% varibales of the individuals from PopInit is identical
% to the number of variables defined in the boundaries
% array VLUB.
% Additionally, based on the provided individuals similar 
% individuals are produced and included into the 
% population Chrom. The level of randomization and the number
% of unchanged individuals in the population Chrom can be 
% controlled by the options in InitOpt.
% When PopInit is empty, standard random initialization of the
% individuals is done (depending on VariableFormat).
%
% Syntax:  [Chrom, VLUB] = initpop(PopInit, Nind, VLUB, InitOpt)
%
% Input parameters:
%    PopInit   - Vector or matrix containing the initial individuals
%                   may be any number of individuals
%                if PopInit is empty, a uniform at random initialization
%                   of individuals takes place
%    Nind      - Number of individuals to create at all
%    VLUB      - Matrix containing the boundaries of the variables
%    InitOpt   - parameter for initialization
%                InitOpt(1): InitVariableFormat
%                            format/representation of variables (real, integer, 
%                            binary), see options of GEATbx (VariableFormat)
%                            standard: 0 (real variable representation)
%                InitOpt(2): InitRand
%                            level of randomization of (innoculated) individuals
%                            0: no randomization, no similar individuals are produced
%                           >0: randomize individuals using the following equation
%                               (randn/4 * InitRand * domain of variable)
%                            standard: 0.25
%                InitOpt(3): InitNindKeep
%                            keep preinitialized individuals in population (unchanged)
%                            0: keep none of them
%                            > 0 (max 1): scalar (percentage of population size) how 
%                               many individuals from PopInit to copy to Chrom
%                            standard: 0.2 (keep not more than 20% of individuals
%                                      in final population)
%                InitOpt(4): InitNindUniform
%                            create some individuals uniform at random in defined 
%                            domain of variables (boundaries VLUB) - uses the 
%                            standard init functions initrp, initip, initbp and initpp
%                            0: create none
%                            > 0 (max 1): scalar (percentage of population size) how 
%                            standard: 0 (creatze no individuals uniform at random)
%                               many individuals to create uniform at random
%                   if InitNindKeep+InitNindUniform > 1: InitNindUniform is reduced
%                   if 1-InitNindKeep+InitNindUniform > 0: this defines the percentage
%                       of individuals (InitNindRand) to create by innoculation with 
%                       the provided individuals in PopInit und randomization 
%                       defined by InitRand
%
% Output parameters:
%    Chrom     - Matrix containing the individuals of the current
%                population. Each row corresponds to one individual's
%                representation.
%    VLUB      - (optional) Matrix containing the (new) boundaries of the 
%                variables (not changed here), same as input parameter
%
% Examples:
%
% % Preparation for all examples:
% %    create initial individuals and corresponding boundary matrix
% >> popinit = repmat([1;2;3;4], [1, 7]);
% >> vlub = repmat([0;10], [1, 7]);
%
% % Get a uniform at random initialized population with 25 real valued individuals
% >> newpop = initpop([], 25, vlub)
%
% % Get a uniform at random initialized population with 25 integer valued individuals
% >> newpop = initpop([], 25, vlub, 2)
%
% % Create a preinitialized population of 40 individuals with standard options
% >> newpop = initpop(popinit, 40, vlub);
% % Get an impression of the distribution of the individuals
% >> plot(newpop');
%
% % Create a preinitialized population of 60 real valued individuals,
% % keep all initial variables (InitOpt(3) == 1), create fully (uniform) random 
% % individuals (50% of population size = 30 ind.) and create also innoculated 
% % individuals (reminding individuals) in an area of 40% around the initial ind.
% >> newpop = initpop(popinit, 60, vlub, [0, 0.4, 1, 0.5]);
%
% % Create a preinitialized population of 50 real valued individuals,
% % keep no initial variables (InitOpt(3) == 0), create only innoculated 
% % individuals in an area of 20% around the initial individuals
% >> newpop = initpop(popinit, 50, vlub, [0, 0.2, 0, 0]);
%
% See also: initrp, initip, initbp, initpp, geamain2

% Author:   Hartmut Pohlheim
% History:  30.03.99    file created
%                       inclusion into GEATbx, may be used from outside as well
%           13.10.99    randomization around provided individuals added
%           14.10.99    comments and examples added


function [Chrom, VLUB] = initpop(PopInit, Nind, VLUB, InitOpt);

% Set standard initialization parameter
   InitOptStandard = [0, 0.2, 0.25, 0];
   % InitVariableFormat = 0 (real), 
   % InitRand = 0.3 (use normal random innoculation with 30% of domain of variables),
   % InitNindKeep = 0.2 (keep 20% maximal)
   % InitNindUniform = 0 (create no random individuals)

% Check parameter consistency
   if nargin < 2,  error('Not enough input parameter (at least 2 parameters - individuals and Nind)'); end
   if isnan(PopInit), PopInit = []; end
   if nargin < 3,  VLUB = []; end

   if nargin < 4, InitOpt = []; end
   if isnan(InitOpt), InitOpt = []; end
   if length(InitOpt) > length(InitOptStandard), error(' Too many parameter in InitOpt'); end

   InitOptIntern = InitOptStandard; InitOptIntern(1:length(InitOpt)) = InitOpt;
   InitVariableFormat = InitOptIntern(1); InitRand = InitOptIntern(2);
   InitNindKeep = InitOptIntern(3); InitNindUniform = InitOptIntern(4);

   if isnan(InitVariableFormat), InitVariableFormat = InitOptStandard(1); end

   if isnan(InitRand), InitRand = InitOptStandard(2);
   elseif any([InitRand < 0, InitRand > 1]), 
      warning('Parameter for randomization of preinitialization must be a scalar in [0, 1]');
   end
   InitRand = min([max([InitRand, 0]), 1]);

   if isnan(InitNindKeep), InitNindKeep = InitOptStandard(3);
   elseif any([InitNindKeep < 0, InitNindKeep > 1]), 
      warning('Parameter for keeping provided individuals must be a scalar in [0, 1]');
   end
   InitNindKeep = min([max([InitNindKeep, 0]), 1]);
   
   if isnan(InitNindUniform), InitNindUniform = InitOptStandard(4);
   elseif any([InitNindUniform < 0, InitNindUniform > 1]), 
      warning('Parameter for creation of random individuals must be a scalar in [0, 1]');
   end
   InitNindUniform = min([max([InitNindUniform, 0]), 1]);

   % Compute population parameters
   [NindInitPop, NvarInitPop] = size(PopInit); if isempty(PopInit), NvarInitPop = size(VLUB, 2); end
   NvarVLUB = size(VLUB, 2); if isempty(VLUB), NvarVLUB = NvarInitPop; end
   if NvarInitPop ~= NvarVLUB,
      error('Number of variables of individuals in preinitialized population (PopInit) disagree with number of defined boundaries (VLUB)!')
   end

   % The second parameter Nind may contain the number of (binary) variables to use as the second element
   if length(Nind) > 1, NVarBin = Nind(2); Nind = Nind(1); else NVarBin = 20*NvarInitPop; end

   % When preinitialized individuals should be kept (used) directly in population 
   ChromKeep = []; NindKeep = 0; 
   if all([InitNindKeep > 0, NindInitPop >= 1]),
      % How many individuals to keep
      % minimum from defined percentage and the provided individuals
      NindKeep = min([ceil(InitNindKeep * Nind), NindInitPop]);
      % Less or equal much individuals in preinitialized population than needed
      if NindInitPop == NindKeep,
         ChromKeep = PopInit;
      % more individuals in preinitialized population than needed
      else
         % linearly spaced
         SelIx = ceil(linspace(1, NindInitPop, NindKeep))';
         % uniform at random selection 
         % SelIx = ceil(NindInitPop * rand(NindKeep, 1));
         ChromKeep = PopInit(SelIx,:);
      end
   end

   % Number of individuals to be created uniform at random
   NindUniform = ceil(InitNindUniform * Nind);
   if NindKeep + NindUniform > Nind, NindUniform = Nind - NindKeep; end
   % Number of individuals to be created normalized at random with innoculation
   if all([InitRand > 0, NindInitPop >= 1]), NindRand = Nind - NindKeep - NindUniform;
   else NindRand = 0; end
   % Recalculate NindUniform depending on (probably) changed NindRand
   NindUniform = Nind - NindKeep - NindRand;

   % Do the randomization with innoculation
   ChromRand = [];
   if NindRand > 0,
      % Create vector with indices into init population and select
      % individuals uniform at random
      SelIx = rem([1:NindRand]-1, NindInitPop)+1;
      ChromRand = PopInit(SelIx,:);
      % Randomize the selected individuals 
      % (the last dividend (4) scales the range of random value to 1)
      MatRandn = InitRand * randn(NindRand, NvarVLUB) / 4;
      Range = repmat((VLUB(2,:) - VLUB(1,:)), [NindRand 1]);
      ChromRand = ChromRand + MatRandn .* Range;
      % Check for boundaries
      ChromRand = max(repmat(VLUB(1,:),[NindRand 1]), ChromRand);
      ChromRand = min(repmat(VLUB(2,:),[NindRand 1]), ChromRand);
      % Check for integer variables
      if any(InitVariableFormat == [1, 2, 3, 4]), ChromRand = round(ChromRand); end
   end


   % Do uniform at random initialization without innoculation for missing individuals
   ChromUniform = [];
   if NindUniform > 0,
      switch InitVariableFormat,
         % Real valued population
         case 0, ChromUniform = initrp(NindUniform, VLUB);
         % Integer valued population
         case 2, ChromUniform = initip(NindUniform, VLUB);
         % Permutation population
         case 5, ChromUniform = initpp(NindUniform, VLUB);
         % Decode variables into binary,  [1, 3 or 4]
         otherwise, ChromUniform = initbp(NindUniform, NVarBin);
      end
   end

   Chrom = [ChromKeep; ChromRand; ChromUniform];
   % ChromKeep, ChromRand, ChromUniform
   
      % Create vector with indices into population and select individuals uniform at random
      % SelIx = rem([1:Nind]-1, NindInitPop)+1;
      % Chrom = [Chrom; PopInit(SelIx,:)];

   % Mix individuals
   % MixIx = rem([1:Nind]-1, Nind)+1;
   [dummy, MixIx] = sort(rand(Nind, 1));
   Chrom = Chrom(MixIx,:);
   

% End of function
