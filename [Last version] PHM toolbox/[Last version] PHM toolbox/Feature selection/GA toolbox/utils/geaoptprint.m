% Print GEAOPTions structure of GEA Toolbox nicely formatted into a string
%
% This function takes a GEAOPTions structure, interpretes the parameters 
% and creates a long string containing the parameters nicely formated 
% and commented.
%
% Syntax:  geaoptstr = geaoptprint(geaopt)
%
% Input parameter:
%    geaopt    - Structure with all possible parameters of GEATbx
%
% Output parameter:
%    geaoptstr - String containing the parameters commented for documentation
%
%
% See also: geamain2, geaoptset, paraoptset

% Author:   Hartmut Pohlheim
% History:  12.11.1998  file created
%           xx.11.1998  many updates to include all things
%           14.01.1999  included check for size of additional parameter,
%                          if parameter too large, no pretty printing
%           01.06.1999  replaced call to whos by separate size calculation
%           14.06.1999  added output for variable format output
%           07.12.1999  added output for special initialization
%           04.05.2002  added output for exclusion of parts of save text to file
%           18.01.2004  added output for complementary variables

function [geaoptstrScreen, geaoptstrFile] = geaoptprint(geaopt)

% Define needed global variables
  global DPPVM_MLSLAVEIDS

% Reassign nargin und nargout
  NAIN = nargin; NAOUT = nargout;

% define some defaults
   NF = '%6.3g  ';

% Check options structure
   geaopt = geaoptset(geaopt);

% Create the output string
   % Output name of objective function and date and time of begin of computation
   StartTime = now;
   ResultsTitle = sprintf('\nEvolutionary Optimization\n\n');
   ResultsStart = sprintf('Objective function:  %s       Date: %s     Time: %s\n', ...
                          geaopt.System.ObjFunFilename, datestr(StartTime, 1), datestr(StartTime, 13));
   % Number of variables and boundaries of variables
   outvar = [        sprintf('   number of variables: %4g\n', size(geaopt.System.ObjFunVarBounds, 2))];
   if any([isempty(geaopt.System.ObjFunVarBounds), size(geaopt.System.ObjFunVarBounds, 1) < 2]),
      outvar = [outvar, sprintf('   boundaries of variables:  NOT (correctly) DEFINED!\n')];
   else
      outvar = [outvar, sprintf('   boundaries of variables: %s\n', sprintf('%11.3g ', compdiv('diff_num', geaopt.System.ObjFunVarBounds(1,:))))];
      outvar = [outvar, sprintf('                            %s\n', sprintf('%11.3g ', compdiv('diff_num', geaopt.System.ObjFunVarBounds(2,:))))];
   end
   if any([~(isempty(geaopt.System.ObjFunGoals))]),
      outvar = [outvar, sprintf('   goals (multi-objective): %s\n', sprintf('%11.3g ', geaopt.System.ObjFunGoals))];
      % outvar = [outvar, sprintf('   goals for multiple objectives: %s\n', sprintf('%9.3g ', compdiv('diff_num', geaopt.System.ObjFunGoals)))];
   end
   if any([~(isempty(geaopt.System.ObjFunVar2ObjV))]),
      for ivar2objv = 1:size(geaopt.System.ObjFunVar2ObjV,1),
         if ivar2objv == 1, Strvar2objv = sprintf(' ');
         else, Strvar2objv = [Strvar2objv, sprintf('%s', repmat(' ', [1 30]))]; end
         Strvar2objv = [Strvar2objv, sprintf('var:  %s    objv:  %s\n', prprintf(geaopt.System.ObjFunVar2ObjV{ivar2objv,1}), prprintf(geaopt.System.ObjFunVar2ObjV{ivar2objv,2}))]; 
      end
      outvar = [outvar, sprintf('   complementary variables:  %s\n', Strvar2objv)];
   end
   ResultsStart = [ResultsTitle, ResultsStart, outvar];
   
   % String for output of additional problem specific parameters
   ResultsAddPara = [];
   if all([~(isempty(geaopt.System.ObjFunAddPara)), any([geaopt.Output.TextExcludePara == 0, geaopt.Output.SaveTextExcludePara == 0]) ]),
      ResultsAddPara = ['   Additional  parameters:  ']; NewLineIndent = repmat(' ', [1 length(ResultsAddPara)]);
      for i = 1:length(geaopt.System.ObjFunAddPara),
         % Compute size in bytes of parameter
         Para = geaopt.System.ObjFunAddPara{i};
         % Check the size of the parameter, if to large, don't print the contents
         % Special handling, because whos is not supported by the compiler; % ContPara = whos('Para');
         if isstruct(Para), ContPara.bytes = 10000;
         elseif iscell(Para), sz=0; lx=prod(size(Para)); for icell=1:lx, sz=sz+prod(size(Para)); end, ContPara.bytes = sz;
         else ContPara.bytes = prod(size(Para)); end
         ContPara.bytes = ContPara.bytes * 8;
         % if size is too large (here larger than 1225 bytes), don't do prprintf
         % otherwise do pretty print
         if ContPara.bytes > 1225, AddParaString = sprintf('  P%g =  parameter too large for printing', i); Addn = 1;
         else AddParaString = sprintf('  P%g = %s', i, prprintf('%.4g', '  ', geaopt.System.ObjFunAddPara{i})); Addn = 1; end
         if length(AddParaString) > 128, AddParaString = sprintf('%s   ... \n%s', AddParaString(1:128), NewLineIndent);  Addn = 0; end
         ResultsAddPara = [ResultsAddPara, AddParaString];
      end
      if Addn == 1, ResultsAddPara = [ResultsAddPara, sprintf('\n')]; end
   end
   

   out1 = sprintf('\nEvolutionary algorithm parameters:\n');
   % Parameters of the core evolutionary algorithm
   out1 = [out1, sprintf(['   subpopulations = ' NF '  '], geaopt.NumberSubpopulation)];
   out1 = [out1, sprintf('   individuals = %s (at start per subpopulation)\n', sprintf( NF, compdiv('diff_num', geaopt.NumberIndividuals)))];
   % Parameters of termination
   out1 = [out1, sprintf('   termination  ')];
   TermReasonStr = {'max. generations', 'max. comp. time',   'diff to optimum',  'running mean', ...
                    'std. deviation',   'good worst indiv.', 'phi convergence',  'kappa convergence', 'cluster analysis'};
   TermParaAll = [geaopt.Termination.MaxGenerations, geaopt.Termination.MaxTime, geaopt.Termination.Diff2Optimum, ...
                  geaopt.Termination.RunningMean, geaopt.Termination.StdObjV, geaopt.Termination.GoodWorstObjV, ...
                  geaopt.Termination.Phi, geaopt.Termination.Kappa, geaopt.Termination.Cluster];
   if all([length(geaopt.Termination.Method) == 1, geaopt.Termination.Method(1) > 12]), geaopt.Termination.Method = str2num(sprintf('%d', geaopt.Termination.Method)')'; end
   for iterm = 1:length(TermReasonStr),
      if any(geaopt.Termination.Method == iterm), 
         if iterm == 3, ExtraInfo = sprintf(' (Min: %g) ', geaopt.System.ObjFunMinimum(1)); else ExtraInfo = ''; end
         out1 = [out1, sprintf('  %d:  %s = %g%s; ', iterm, TermReasonStr{iterm}, TermParaAll(iterm), ExtraInfo)];
      end
   end
   out1 = [out1, sprintf('\n')];
   
   VarFormatDescr = {'real values - phenotype == genotype', 'real values (phenotype) - binary values (genotype)', 'integer values - phenotype == genotype', ...
                     'integer values (phenotype) - binary values (genotype)', 'binary values - phenotype == genotype', 'permutation representation', 'undefined variable format'};
   if geaopt.VariableFormat(1) < length(VarFormatDescr), VarFormatPrint = VarFormatDescr{geaopt.VariableFormat(1)+1};
   else VarFormatPrint = VarFormatDescr{end}; end
   out1 = [out1, sprintf('   variable format = %4g   (%s)\n', geaopt.VariableFormat, VarFormatPrint)];

   % Parameters of selection
   out1 = [out1, sprintf('   selection\n')];
   out1 = [out1, sprintf('         function = %s\n', prprintf('%s', '  ', compdiv('diff_str', geaopt.Selection.Name)))];
   out1 = [out1, sprintf('         pressure = %s\n', sprintf( NF, compdiv('diff_num', geaopt.Selection.Pressure)))];
   if any(geaopt.Selection.RankingMethod ~= 0),
   out1 = [out1, sprintf('         ranking  = %s\n', sprintf( NF, compdiv('diff_num', geaopt.Selection.RankingMethod)))];
   end
   if any(geaopt.Selection.RankingMultiobj ~= 0),
   out1 = [out1, sprintf('         multiobj = %s\n', sprintf( NF, compdiv('diff_num', geaopt.Selection.RankingMultiobj)))];
   end
   out1 = [out1, sprintf('         gen. gap = %s\n', sprintf( NF, compdiv('diff_num', geaopt.Selection.GenerationGap)))];
   out1 = [out1, sprintf('      reinsertion\n')];
   out1 = [out1, sprintf('             rate = %s\n', sprintf( NF, compdiv('diff_num', geaopt.Selection.ReinsertionRate)))];
   out1 = [out1, sprintf('           method = %s\n', sprintf( NF, compdiv('diff_num', geaopt.Selection.ReinsertionMethod)))]; 
   % Parameters of local model
   if any(strmatch('sellocal', geaopt.Selection.Name)),      % Test, if any local selection (sellocal) is defined
      out1 = [out1, sprintf( '      local model\n')];
      out1 = [out1, sprintf( '         dimension = %s\n', sprintf( NF, geaopt.Selection.LocalDimension))];
      out1 = [out1, sprintf( '          topology = %s\n', sprintf( NF, geaopt.Selection.LocalTopology))];
      out1 = [out1, sprintf( '          distance = %s\n', sprintf( NF, geaopt.Selection.LocalDistance))];
   end

   % Parameters of recombination
   out1 = [out1, sprintf('   recombination\n')];
   out1 = [out1, sprintf('         name = %s\n', prprintf('%s', '  ', compdiv('diff_str', geaopt.Recombination.Name)))];
   out1 = [out1, sprintf('         rate = %s\n', sprintf( NF, compdiv('diff_num', geaopt.Recombination.Rate)))];

   % Parameters of mutation
   out1 = [out1, sprintf('   mutation\n')];
   out1 = [out1, sprintf('           name = %s\n', prprintf('%s', '  ', compdiv('diff_str', geaopt.Mutation.Name)))];
   out1 = [out1, sprintf('           rate = %s\n', sprintf( NF, compdiv('diff_num', geaopt.Mutation.Rate)))];
   if all(geaopt.VariableFormat ~= [1, 3]),
      out1 = [out1, sprintf('          range = %s\n', sprintf( NF, compdiv('diff_num', geaopt.Mutation.Range)))];
      out1 = [out1, sprintf('      precision = %s\n', sprintf( NF, compdiv('diff_num', geaopt.Mutation.Precision)))];
   end

   % Parameters of regional model
   if all([any([geaopt.Migration.Do, geaopt.Competition.Do] > 0), geaopt.NumberSubpopulation > 1]),
      out1 = [out1, sprintf( '   regional model\n')];
   end
   % Parameters for migration between subpopulation
   if all([geaopt.Migration.Do > 0, geaopt.NumberSubpopulation > 1]),
      out1 = [out1, sprintf( '      migration\n')];
      out1 = [out1, sprintf( '            rate = %5.2g    interval = %4g    topology = %4g    selection = %2g\n', ...
                              geaopt.Migration.Rate, geaopt.Migration.Interval, ...
                              geaopt.Migration.Topology, geaopt.Migration.Selection)];
   end
   % Parameters of competition between subpopulation
   if all([geaopt.Competition.Do > 0, geaopt.NumberSubpopulation > 1]),
      out1 = [out1, sprintf( '      competition\n')];
      out1 = [out1, sprintf( '            rate = %5.2g    interval = %4g', geaopt.Competition.Rate, geaopt.Competition.Interval)];
      out1 = [out1, sprintf( '    subpop minimum = %s', sprintf('%5g', compdiv('diff_num', geaopt.Competition.SubpopMinimum)))];
      out1 = [out1, sprintf( '    div. pressure  = %s\n', sprintf('%5g', compdiv('diff_num', geaopt.Competition.DivisionPressure)))];
   end

   % Parameters for output
   OutputTest = [geaopt.Output.TextInterval, geaopt.Output.GrafikInterval, ...
                 geaopt.Output.SaveTextInterval(1), geaopt.Output.SaveBinDataInterval, ...
                 geaopt.Output.StatePlotInterval];
   if any(OutputTest > 0),
      out1 = [out1, sprintf('   output\n')];
   end
   
   % Parameters of text output on screen
   if geaopt.Output.TextInterval > 0, 
      out1 = [out1, sprintf( '      results on screen every  %g  generations\n', geaopt.Output.TextInterval)];
   end
   % Plot of results and plot methods
   if geaopt.Output.GrafikInterval > 0,
      out1 = [out1, sprintf( '      grafical display of results every  %g  generations\n', geaopt.Output.GrafikInterval)];
      out1 = [out1, sprintf( '         method = %s\n', sprintf( '%d', geaopt.Output.GrafikMethod))];
      out1 = [out1, sprintf( '         style  = %s\n', sprintf( '%d', geaopt.Output.GrafikStyle))];
   end
   % Parameters of saving to text file
   if geaopt.Output.SaveTextInterval(1) > 0, 
      out1 = [out1, sprintf( '      results into text file every  %g  generations\n', geaopt.Output.SaveTextInterval(1))];
      out1 = [out1, sprintf( '          file name =  %s\n', geaopt.Output.SaveTextFilename)];
      % Should any part of the printed info be excluded
      OutSavePara = {geaopt.Output.SaveTextExcludeHead, 'header'; ...
                     geaopt.Output.SaveTextExcludePara, 'ea parameter'; ...
                     geaopt.Output.SaveTextExcludeInd,  'best individual'; ...
                     geaopt.Output.SaveTextExcludeSub,  'pos/size subpops'; ...
                     geaopt.Output.SaveTextExcludeTerm, 'termination'; ...
                     geaopt.Output.SaveTextExcludeTime, 'calculation time'};
      ParaEx = find([OutSavePara{:,1}] ~= 0);
      if length(ParaEx) >= 1,
         StrParaEx = '';
         for iparaex = 1:length(ParaEx),
            StrParaEx = [StrParaEx, sprintf( '   %s: %g', OutSavePara{ParaEx(iparaex),2}, OutSavePara{ParaEx(iparaex),1})];
         end
         out1 = [out1, sprintf( '          exclude%s\n', StrParaEx)];
      end
   end
   % Parameters of saving to binary data file
   if geaopt.Output.SaveBinDataInterval > 0,
      out1 = [out1, sprintf( '      results into binary data (mat) file every  %g  generations\n', geaopt.Output.SaveBinDataInterval)];
      out1 = [out1, sprintf( '          file name =  %s\n', geaopt.Output.SaveBinDataFilename)];
   end
   % Parameters of special state plot
   if geaopt.Output.StatePlotInterval > 0,
      out1 = [out1, sprintf( '      special state plot function =  %s  every  %g  generations\n', ...
                              geaopt.Output.StatePlotFunction, geaopt.Output.StatePlotInterval)];
   end

   % Parameters of collecting best individuals
   if geaopt.Special.CollectBest.Interval > 0,
      out1 = [out1, sprintf( '   collect best individuals every  %g  generations\n', geaopt.Special.CollectBest.Interval)];
      out1 = [out1, sprintf( '       rate =  %d,   compare = %d,   cache size = \n', ...
              geaopt.Special.CollectBest.Rate, geaopt.Special.CollectBest.Compare, geaopt.Special.CollectBest.CacheSize)];
      if geaopt.Special.CollectBest.WriteFile == 1,
         out1 = [out1, sprintf( '       save collected data to text file =  %s\n', geaopt.Special.CollectBest.FileName)];
      end
   end

   % Names of special init and plot function
   if geaopt.Special.InitDo > 0,
      out1 = [out1, sprintf('   special initialization:\n')];
      if all([~(isempty(deblank(geaopt.Special.InitFunction))), geaopt.Special.InitDo >= 1])
         out1 = [out1, sprintf( '      init function = %s\n', geaopt.Special.InitFunction)];
      end
      out1 = [out1, sprintf( '      keep preset unchanged (max)  = %s%%  (of population size)\n', sprintf( NF, geaopt.Special.InitPresetKeep*100)), ...
                    sprintf( '      create uniform indiv. (max)  = %s%%  (of population size)\n', sprintf( NF, geaopt.Special.InitUniformCreate*100)), ...
                    sprintf( '      level of normal distribution = %s%%  (random around preset indiv.)\n', sprintf( NF, geaopt.Special.InitPresetRand*100)) ];
   end

   % GUI use
   if geaopt.Gui.Use > 0,
      out1 = [out1, sprintf( '   use GUI:  name of GUI m-file = %s,   name of GUI figure tag = %s\n', ...
              geaopt.Gui.Name, geaopt.Gui.FigureTag)];
   end

   % DPGEA
   if geaopt.Special.DPGEA > 0,
      out1 = [out1, sprintf( '   use DPGEA: number of slaves = %d\n', length(DPPVM_MLSLAVEIDS))];
      % out1 = [out1, '   use DPGEA slaves \n'];
   end

   geaoptstrScreen = ResultsStart;
   if geaopt.Output.TextExcludePara == 0, geaoptstrScreen = [geaoptstrScreen, ResultsAddPara]; end
   geaoptstrScreen = [geaoptstrScreen, out1];

   if NAOUT > 1,
      geaoptstrFile = ResultsStart;
      if geaopt.Output.SaveTextExcludePara == 0, geaoptstrFile = [geaoptstrFile, ResultsAddPara]; end
      geaoptstrFile = [geaoptstrFile, out1];
   end


% End of function