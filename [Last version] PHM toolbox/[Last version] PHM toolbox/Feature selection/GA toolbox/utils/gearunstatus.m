% Prints RUN STATUS of GEA Toolbox nicely formatted into a string
%
% This function takes a geaoptions structure and many other parameters
% and creates a long string containing the run status of the current
% optimization.
%
% Syntax:  [StatusScreen, StatusFile, HeaderScreen, HeaderFile] = ...
%          gearunstatus(GEAOpt, ObjVBestAll, IndBestAll, PosSubPopAct, WhatTerm, StatusTimes, OutputTextHeader)
%
% Input parameter:
%    GEAOpt    - Structure with all possible parameters of GEATbx
%    other parameters see geamain2
%
% Output parameter:
%    StatusScreen - String containing the status info for screen
%                      if OutputTextHeader is input and only one output,
%                      StatusScreen contains the new OutputTextHeader
%    StatusFile   - String containing the status info for file
%    HeaderScreen - String containing the header info for screen
%    HeaderFile   - String containing the header info for file
%
%
% See also: geamain2, geaoptset

% Author:   Hartmut Pohlheim
% History:  14.12.1999  file created
%           14.03.2000  text and savetext always in first generation
%                          (when output in longer intervals)

function [StatusScreen, StatusFile, HeaderScreen, HeaderFile] = gearunstatus(GEAOpt, ObjVBestAll, IndBestAll, PosSubPopAct, WhatTerm, StatusTimes, OutputTextHeader)

% Reassign arin und argout
  NAIN = nargin; NAOUT = nargout;
  if NAIN < 7, OutputTextHeader = [0, 0]; end

% define some defaults
   NF = '%6.3g  ';

% Create string with standard results: generation, objective function evals, best objective value
   ResultsStandard = sprintf('%5.0d.      %8.0d    ', GEAOpt.Run.Generation, GEAOpt.Run.CountObjFun);
   ResultsObjV = [sprintf(' %13.5g', ObjVBestAll(GEAOpt.Run.Generation,:)), '     '];
   ResultsInd = ['  ', sprintf(' %13.5g ', IndBestAll(GEAOpt.Run.Generation,:)), '     '];

% position/rank of subpopulations and number of individuals in every subpopulation 
   if all([any([GEAOpt.Output.TextExcludeSub == 0, GEAOpt.Output.SaveTextExcludeSub == 0]), length(GEAOpt.NumberIndividuals) > 1]),
      ResultsSub = ['  ', sprintf(' %3g', PosSubPopAct)]; 
      if GEAOpt.Competition.Do > 0, ResultsSub = [ResultsSub, '  ' sprintf(' %5g ', GEAOpt.NumberIndividuals)]; end
      ResultsSub = [ResultsSub, '   '];
   else ResultsSub = []; end

% termination values
   ResultsTerm = ['  [' sprintf('%7.2f%%', 100*WhatTerm(find(~isnan(WhatTerm)))) ']   '];

% Time results
   ResultsTime = ['  (' sprintf('%6.2fmin  ', StatusTimes{1}), datestr(StatusTimes{2}, 13)  ')   '];

% Create the Status string for screen
   StatusScreen = [ResultsStandard, ResultsObjV];
   if GEAOpt.Output.TextExcludeInd  == 0,   StatusScreen =  [StatusScreen, ResultsInd]; end
   if GEAOpt.Output.TextExcludeSub  == 0,   StatusScreen =  [StatusScreen, ResultsSub]; end
   if GEAOpt.Output.TextExcludeTerm == 0,   StatusScreen =  [StatusScreen, ResultsTerm]; end
   if GEAOpt.Output.TextExcludeTime == 0,   StatusScreen =  [StatusScreen, ResultsTime]; end

% Create the Status string for file
   StatusFile = [ResultsStandard, ResultsObjV];
   if GEAOpt.Output.SaveTextExcludeInd  == 0,   StatusFile =  [StatusFile, ResultsInd]; end
   if GEAOpt.Output.SaveTextExcludeSub  == 0,   StatusFile =  [StatusFile, ResultsSub]; end
   if GEAOpt.Output.SaveTextExcludeTerm == 0,   StatusFile =  [StatusFile, ResultsTerm]; end
   if GEAOpt.Output.SaveTextExcludeTime == 0,   StatusFile =  [StatusFile, ResultsTime]; end

   % Generate the header for the tabular output
   if any([NAOUT > 2, any(OutputTextHeader == 0)]),
      ResultsHeader  = 'Generation   f-Count     Obj. Function';
      % Additional x. objv output only when more than 1 objective given
      if length(ObjVBestAll(GEAOpt.Run.Generation,:)) >= 2,
         ResultsHeader  = sprintf('%s%s', ResultsHeader, sprintf(' %7d. objv', 2:length(ObjVBestAll(GEAOpt.Run.Generation,:))));
      end
      HeaderTextInd  = sprintf('  Variables of best individual %s', sprintf(' %9d. var',3:length(IndBestAll(GEAOpt.Run.Generation,:))));
      HeaderTextPos  = '  Pos of subpopulations / size';
      HeaderTextTerm = sprintf('  Term:%s', sprintf('%2d      ', find(~isnan(WhatTerm))));
      HeaderTextTime = sprintf('  Time: cpu/gen,  full');
      
      % Cut or fill the header strings
      ResultsHeader  = compdiv('cutfillstring', ResultsHeader,  length([ResultsStandard, ResultsObjV]));
      HeaderTextInd  = compdiv('cutfillstring', HeaderTextInd,  length(ResultsInd));
      HeaderTextPos  = compdiv('cutfillstring', HeaderTextPos,  length(ResultsSub));
      HeaderTextTerm = compdiv('cutfillstring', HeaderTextTerm, length(ResultsTerm));
      HeaderTextTime = compdiv('cutfillstring', HeaderTextTime, length(ResultsTime));

      % Create the Header string for screen
      HeaderScreen = ResultsHeader;
      if GEAOpt.Output.TextExcludeInd == 0,     HeaderScreen =  [HeaderScreen, HeaderTextInd]; end
      if ~isempty(ResultsSub),
         if GEAOpt.Output.TextExcludeSub == 0,  HeaderScreen = [HeaderScreen, HeaderTextPos]; end
      end
      if GEAOpt.Termination.Method ~= 0,
         if GEAOpt.Output.TextExcludeTerm == 0, HeaderScreen =  [HeaderScreen, HeaderTextTerm]; end
      end
      if GEAOpt.Output.TextExcludeTime == 0,    HeaderScreen =  [HeaderScreen, HeaderTextTime]; end


      % Create the Header string for file
      HeaderFile = ResultsHeader;
      if GEAOpt.Output.SaveTextExcludeInd == 0,     HeaderFile =  [HeaderFile, HeaderTextInd]; end
      if ~isempty(ResultsSub),
         if GEAOpt.Output.SaveTextExcludeSub == 0,  HeaderFile =  [HeaderFile, HeaderTextPos]; end
      end
      if GEAOpt.Termination.Method ~= 0,
         if GEAOpt.Output.SaveTextExcludeTerm == 0, HeaderFile =  [HeaderFile, HeaderTextTerm]; end
      end
      if GEAOpt.Output.SaveTextExcludeTime == 0,    HeaderFile =  [HeaderFile, HeaderTextTime]; end

   end


   if NAOUT < 2,  
      % Display results on screen
      if GEAOpt.Output.TextInterval > 0,
         if any([rem(GEAOpt.Run.Generation, GEAOpt.Output.TextInterval) == 0, GEAOpt.Run.DoTerminate == 1, GEAOpt.Run.Generation == 1]),
            if all([GEAOpt.Run.Generation == 1, OutputTextHeader(1) == 0]),
               if GEAOpt.Output.TextExcludeHead == 0, disp(HeaderScreen); OutputTextHeader(1) = 1; end
            end
            disp(StatusScreen);
         end
      else OutputTextHeader(1) = 1;
      end
  
      % Save output/results to file
      if GEAOpt.Output.SaveTextInterval > 0,
         if any([rem(GEAOpt.Run.Generation, GEAOpt.Output.SaveTextInterval) == 0, GEAOpt.Run.DoTerminate == 1, GEAOpt.Run.Generation == 1]),
            % Open output file and write data to file
            [fidgen, error_message] = fopen(GEAOpt.Output.SaveTextFilename, 'at');
            if fidgen == -1,
               warning(sprintf('error during fopen of result file (%s): %s', GEAOpt.Output.SaveTextFilename, error_message));
            else
               if all([GEAOpt.Run.Generation == 1, OutputTextHeader(2) == 0]), 
                  if GEAOpt.Output.SaveTextExcludeHead == 0, fprintf(fidgen, '%s\n', HeaderFile); end
                  OutputTextHeader(2) = 1;
               end
               fprintf(fidgen, '%s\n', StatusFile); fclose(fidgen);
            end
         end
      else OutputTextHeader(2) = 1;
      end
      if NAIN > 6, StatusScreen = OutputTextHeader; end
   end


% End of function