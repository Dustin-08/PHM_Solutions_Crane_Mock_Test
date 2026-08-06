% Collect best individuals during an optimization run
%
% This functions collects the best individuals during an optimiztaion run.
% The user defines, how many individuals (variable values and corresponding
% objective values - even multi-objective) are collected.
% The function takes care, that no individual is collected twice (comparison
% of variable values).
% It may be specified, that only one individual per objective value is 
% collected (then, the objective values are compared, and not the variable
% values).
%
% Syntax:  BestIndNew = colbestind(ColBestOpt, BestIndOld, Chrom, ObjV, RankCh)
%
% Input parameter:
%    ColBestOpt- (optional) Cell array containing parameters for collection
%                   of best individuals
%                ColBestOpt{1} = ColIndPartPop: (optional)
%                   scalar containing the number of individuals to collect
%                   (when smaller 1, the value specifies the number 
%                    as part of the population, otherwise floor(ColIndPartPop) 
%                    individuals are collected)
%                   example: 0.1 means, that 10% of the individuals of the 
%                            population are copied to BestIndNew, it is assured,
%                            that  these individuals are different from BestIndOld
%                            1 (or 1.001) means, that only 1 individual is collected
%                   the number of copied individuals is only smaller, when not 
%                      enough different individuals are found (different variable 
%                      values)
%                   if omitted or NaN, 0.1 is assumed
%                ColBestOpt{2} = ColIndCompWhat: (optional)
%                   scalar indicating, what should be compared (when checking
%                   for identical/not useful individuals)
%                   0: Check only for identical variable values
%                   1: Check for identical objective values and identical variable values
%                   2: Check only for identical objective values
%                  -1: No check for differences
%                   if omitted or NaN, ColIndCompWhat = 0 is assumed
%                ColBestOpt{3} = ColIndWriteFile: (optional)
%                   scalar indicating, if the good individuals should be written to
%                   file, the file name is given in ColIndFileName (ColBestOpt{3})
%                   0: do not write to file
%                   1: write good individuals to file
%                   if omitted or NaN, ColIndFileName = 0 is assumed
%                ColBestOpt{4} = ColIndFileName: (optional)
%                   string defining the file name for the collected good individuals
%                   if omitted or NaN, ColIndFileName = straddtime('BestIndCollected.txt')
%                   is assumed
%    BestIndOld- Cell array containing previous best individuals 
%                   {1} contains variables, {2} contains objective values
%    Chrom     - Matrix containing individuals of current generation
%    ObjV      - Vector/Matrix containing objective values of current generation
%    RankCh    - Vector containg fitness values (from ranking) of
%                   individuals in Chrom
%
% Output parameter:
%    BestIndNew- Cell array containing best individuals from BestIndOld
%                   and from Chrom
%
% Examples:
%
% % create binary population, calculate obj vals and rank vals
% >> BinPop = initbp(200,5); BinPopObjV = linspace(1, 40, size(BinPop, 1))';
% >> BinPopRank = ranking(BinPopObjV);
% % Perform the collection of the best individuals (each unique individual only ones)
% >> BestIndNew=colbestind([0.4, 0], {}, BinPop, BinPopObjV, BinPopRank)
% % Show the collected individuals pretty printed
% >> prprintf(' %d', {'  ', '\n'}, BestIndNew{1})
%
% % Perform the collection of the best individuals (check for identical objective values)
% % As we have 200 different objective values, the defined percentage (0.4 * 200 = 80)
% % to collect is smaller (80 individuals are collected)
% >> BestIndNew=colbestind([0.4, 2], {}, BinPop, BinPopObjV, BinPopRank)
%
% % Perform the collection of the best individuals (check for identical objective values)
% % Now we have only 40 different objective values (rounded obj vals), thus 40 individuals are collected
% >> BestIndNew=colbestind([0.4, 2], {}, BinPop, ceil(BinPopObjV), BinPopRank)
%
% % Perform the collection of the best individuals (check for identical individuals and objective values)
% % only 20 individuals are collected (0.1 * 200), but the individuals with the best objective values
% >> BestIndNew=colbestind([0.1, 1], {}, BinPop, ceil(BinPopObjV), BinPopRank)
%
% See also: geamain2

% Author:   Hartmut Pohlheim
% History:  30.03.2000  file created
%           31.03.2000  ColBestOpt first definition, first runs
%           05.04.2000  definition and implementation of options
%                       comparison against variable and/or objective values
%                       write data optionally to file
%           30.06.2005  added option to not check for differences (just collect)
%           07.08.2005  removed a bug, which prevented the correct collection of
%                       individuals when comparing the variables (sum for diff was 
%                       operating along the rows and not along the columns)
%           08.01.2006  removed a bug appearing with binary values, added an abs
%                       before the sum of diff calculation
%                       examples added, here with binary population for goood understanding
%
%  to do: check, if implementation with unique is quicker and scales better than 
%         the used sum abs diff implementation


function BestIndNew = colbestind(ColBestOpt, BestIndOld, Chrom, ObjV, RankCh)

   NAIN = nargin;
   
   % Check input parameters
   GoBack = 0; CacheSize = 5 * size(Chrom, 1);

   if NAIN < 1, ColBestOpt = []; end
   
   if NAIN < 2, BestIndOld = []; end
   if isempty(BestIndOld), BestIndOld = {[], []}; end
   
   % Some values for testing the function
   if 0, %  isempty(BestIndOld),
      BestIndOldInd  = [10 20 30 40 50 60 61]' * [ 1 2 3 4 5 6]
      BestIndOldObjV = [11 12 13 14 15 16 17]'
      BestIndOld = {BestIndOldInd, BestIndOldObjV};
   
      Chrom = [10  20  30 140.1 150.48 160.97 30    40]' * [ 1 2 3 4 5 6]
      ObjV =  [21  22  23  24    11     26.4  11.2  17]'
      RankCh =[ 1  0.8 0.6 0.4   0.2    0.49  0.5   0.39];
      NAIN = 5;  % nargin;
   end

   if NAIN < 3, Chrom  = []; end, if isempty(Chrom),  GoBack = 1; end 
   if NAIN < 4, ObjV   = []; end, if isempty(ObjV),   GoBack = 1; end 
   if NAIN < 5, RankCh = []; end, if isempty(RankCh), GoBack = 1; end 

   % An error/warning occured, just return the old best individuals 
   if GoBack == 1, BestIndNew = BestIndOld; return; end

   % Check option parameter
   % Standard parameter: {1}, 1: percentage of population to collect (0.1 = 10%)
   % {1}, 2: save data to file
   % {2}: name of file
   ColIndPartPopStandard = 0.1; ColIndCompWhatStandard = 0;
   ColIndWriteFileStandard = 0; ColIndFileNameStandard = straddtime('BestIndCollected.txt');
   ColBestOptStandard = {ColIndPartPopStandard, ColIndCompWhatStandard, ColIndWriteFileStandard, ColIndFileNameStandard};

   if isempty(ColBestOpt), ColBestOpt = ColBestOptStandard; end

   if all([iscell(ColBestOpt), length(ColBestOpt) > length(ColBestOptStandard)]),
      warning('Too many parameter in ColBestOpt');
      ColBestOpt = ColBestOpt(1:length(ColBestOptStandard));
   elseif ~(iscell(ColBestOpt)),
      if ischar(ColBestOpt), ColBestOpt = {[], [], ColBestOpt};
      else ColBestOpt = num2cell(ColBestOpt); end
   end

   % Assign options to internal variables and check them
   ColBestOptIntern = ColBestOptStandard; [ColBestOptIntern{1:length(ColBestOpt)}] = deal(ColBestOpt{:});
   ColIndPartPop = ColBestOptIntern{1};
   if isnan(ColIndPartPop), ColIndPartPop = ColBestOptStandard{1}; end
   if ColIndPartPop < 0, ColIndPartPop = ColBestOptStandard{1}; end
   ColIndCompWhat = round(ColBestOptIntern{2});
   if isnan(ColIndCompWhat), ColIndCompWhat = ColBestOptStandard{2}; end
   if all(ColIndCompWhat ~= [-1, 0, 1, 2]), ColIndCompWhat = 0; end
   ColIndWriteFile = ColBestOptIntern{3};
   if isnan(ColIndWriteFile), ColIndWriteFile = ColBestOptStandard{3}; end
   ColIndFileName = ColBestOptIntern{4};
   if isnan(ColIndFileName), ColIndFileName = ''; end
   if isempty(ColIndFileName), ColIndFileName = ColBestOptStandard{4}; end

   % Take the old individuals out of the cell array
   BestOldVar = BestIndOld{1}; BestOldObjV = BestIndOld{2};
   % Check the (matching) size of the parameters
   [NindCh, NvarCh] = size(Chrom);
   if ~(isempty(BestOldVar)),
      [NindBestOldVar, NvarBestOldVar] = size(BestOldVar);
      if NvarCh ~= NvarBestOldVar, GoBack = 1; warning(sprintf('The number of variables in Chrom (%g) and BestIndOld (%g) disagree!', NvarCh, NvarBestOldVar)); end
   end
   % Check objective values against Chrom
   [NindObjV, NvarObjV] = size(ObjV);
   if all([NindObjV == 1, NvarObjV > 1]), ObjV = ObjV'; [NindObjV, NvarObjV] = size(ObjV); end
   if NindCh ~= NindObjV, GoBack = 1; warning(sprintf('The number of individuals in Chrom (%g) and objective values in ObjV (%g) disagree!', NindCh, NindObjV)); end
   % Check ranking values against Chrom
   [NindRank, NvarRank] = size(RankCh);
   if all([NindRank == 1, NvarRank > 1]), RankCh = RankCh'; [NindRank, NvarRank] = size(RankCh); end
   if NindCh ~= NindRank, GoBack = 1; warning(sprintf('The number of individuals in Chrom (%g) and rank values in RankCh (%g) disagree!', NindCh, NindRank)); end
   % Check number of objectives in ObjV against BestIndOldObjV
   if ~(isempty(BestOldObjV)),
      [NindBestOldObjV, NvarBestOldObjV] = size(BestOldObjV);
      if NvarObjV ~= NvarBestOldObjV, GoBack = 1; warning(sprintf('The number of objectives in ObjV (%g) and in BestIndOld{2} (%g) disagree!', NvarObjV, NvarBestOldObjV)); end
   end
   % An error/warning occured, just return the old best individuals 
   if GoBack == 1, BestIndNew = BestIndOld; return; end


   % Sort individuals according to RankCh (highest rank value is first, thus sort with -1)
   [Dummy, RankChIx] = sort(-RankCh);
   
   % Calculate number of good individuals to consider
   if ColIndPartPop < 1, NumColInd = ceil(NindCh * ColIndPartPop);
   else NumColInd = min([NindCh, floor(ColIndPartPop)]); end

   icolindcur = 1;
   ColIndChromIx = [];
   while all([icolindcur <= NindCh, NumColInd > 0]),
      % Indicator, if individual should be added, is set to yes (1) at the beginning
      AddInd = 1;
      % Check, if this individual is identical by variable values to the previous best individuals in current generation (Chrom)
      if all([any(ColIndCompWhat == [0, 1]), ~(isempty(ColIndChromIx)), AddInd == 1]),
         Diff2Chrom = sum(abs(Chrom(ColIndChromIx,:) - repmat(Chrom(RankChIx(icolindcur),:), [length(ColIndChromIx), 1])), 2);
         if any(Diff2Chrom == 0), AddInd = 0; end
      end
      % Check, if this individual is identical by variable values to the previous best in BestIndOld (BestOldVar)
      if all([any(ColIndCompWhat == [0, 1]), ~(isempty(BestOldVar)), AddInd == 1]),
         Diff2BestOldVar = sum(abs(BestOldVar - repmat(Chrom(RankChIx(icolindcur),:), [size(BestOldVar, 1), 1])), 2);
         if any(Diff2BestOldVar == 0), AddInd = 0; end
      end
      % Check, if this individual is identical by objective values to the previous best individuals in current generation (Chrom)
      if all([any(ColIndCompWhat == [1, 2]), ~(isempty(ColIndChromIx)), AddInd == 1]),
         Diff2ObjV = sum(abs(ObjV(ColIndChromIx,:) - repmat(ObjV(RankChIx(icolindcur),:), [length(ColIndChromIx), 1])), 2);
         if any(Diff2ObjV == 0), AddInd = 0; end
      end
      % Check, if this individual is identical by objective values to the previous best in BestIndOld (BestOldVar)
      if all([any(ColIndCompWhat == [1, 2]), ~(isempty(BestOldObjV)), AddInd == 1]),
         Diff2BestOldObjV = sum(abs(BestOldObjV - repmat(ObjV(RankChIx(icolindcur),:), [size(BestOldObjV, 1), 1])), 2);
         if any(Diff2BestOldObjV == 0), AddInd = 0; end
      end
      if AddInd == 1, NumColInd = NumColInd - 1; ColIndChromIx = [ColIndChromIx; RankChIx(icolindcur)]; end
      icolindcur = icolindcur + 1;
   end

   BestIndNew = BestIndOld;
   % Check, if good/better individuals are found, otherwise nothing to do
   if length(ColIndChromIx) > 0,
      % Assign newly collected individuals and objective values to the best individuals
      NewInd = Chrom(ColIndChromIx,:); NewObjV = ObjV(ColIndChromIx,:);
      BestIndNew = { [BestOldVar; NewInd], [BestOldObjV; NewObjV]};
   
      % Save/print newly collected individuals and objective values into a text file
      if ColIndWriteFile == 1,
         [fidcol, error_message] = fopen(ColIndFileName, 'r');
         % If file does not exist
         if fidcol == -1, 
            [fidcol, error_message] = fopen(ColIndFileName, 'wt');
            if fidcol == -1, disp(sprintf('error during create/open of collection file for header writing (%s): %s', ColIndFileName, error_message));
            else
               % Write the header
               Header  = sprintf('%s        %s', sprintf(' %7d. objv', 1:length(ObjV(1,:))), sprintf(' %8d. var',1:length(Chrom(1,:))));
               fprintf(fidcol, '%s\n', Header); fclose(fidcol);
            end
         else fclose(fidcol); end
         
         % Open file for appending data
         [fidcol, error_message] = fopen(ColIndFileName, 'at');
         if fidcol == -1, disp(sprintf('error during fopen of collection file for data writing (%s): %s', ColIndFileName, error_message));
         else
            ResString = [];
            for isave = 1:size(NewInd, 1),
               ResString = [ResString, sprintf(' %13.5g', NewObjV(isave,:)), '        ', sprintf(' %13.5g', NewInd(isave,:)), sprintf('\n')];
            end
            % Write the data to file and close file
            fprintf(fidcol, '%s', ResString);
            fclose(fidcol);
         end
      end
   end


% End of function
