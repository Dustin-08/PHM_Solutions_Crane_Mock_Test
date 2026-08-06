% LOOK at saved RESults
%
% Syntax:  reslook(FileName, PlotOpt, Command, Para1, Para2)
%
% Input parameter:
%    FileName  - String, containing name of mat file with results
%                saved in geamain
%    PlotOpt   - (optional) Vector containing plot parameters
%                PlotOpt(1): PlotStart - (optional) scalar containing start
%                                generation for plotting.
%                            if omitted or NaN, PlotStart = 1 is assumed
%                PlotOpt(2): PlotEnd - (optional) scalar containing the
%                               number of the last generation to plot
%                            if omitted or NaN, Generation = MaxGen is assumed
%                PlotOpt(3): PlotMask - (optional) scalar containing
%                            binary mask for used plots
%                           (1: plot; 0,2,3,...: no plot) 
%                PlotOpt(4): PlotStyle - (optional) scalar containing
%                            integer mask for style of every plot
%
% Output parameter:
%    NO OUT    - no output
%
% See also: resplot, geamain

% Author:   Hartmut Pohlheim
% History:  13.01.96    file created
%           23.01.97    simple text interface added, allows changing
%                          all parameters of plot and saving of figure
%                       compatible with saving of data in geamain
%                       compatible with syntax in resplot
%           04.02.97    added additional input parameters for batch
%                          processing of saving grafics
%           20.04.98    added VLUB as additional parameter


function reslook(FileName, PlotOpt, Command, Para1, Para2)


   % Start checking of PlotOpt
      if nargin < 1, FileName = []; end
      if isnan(FileName), FileName = []; end

      if nargin < 2, PlotOpt = []; end
      if isnan(PlotOpt), PlotOpt = []; end

      if nargin < 3, Command = []; end
      if isnan(Command), Command = []; end

      if nargin < 4, Para1 = []; end
      if isnan(Para1), Para1 = []; end

      if nargin < 5, Para2 = NaN; end

   % Check parameter
      PlotOptStandard = [1, NaN, 0, 0, 0];      % PlotStart = 1, PlotEnd = NaN, PlotMask, PlotStyle
         
      if length(PlotOpt) > length(PlotOptStandard), error(' Too many parameter in PlotOpt'); end
 
      PlotOptIntern = PlotOptStandard; PlotOptIntern(1:length(PlotOpt)) = PlotOpt;
      PlotStart = PlotOptIntern(1); PlotEnd = PlotOptIntern(2);
      PlotMask = PlotOptIntern(3); PlotStyle = PlotOptIntern(4); 
      
      if isnan(PlotStart), Generation = PlotOptStandard(1);
      elseif (PlotStart < 1), error('Parameter for PlotStart must be greater or equal than 1.'); end
 
      if isnan(PlotEnd), PlotEnd = PlotOptStandard(2);
      elseif (PlotEnd < PlotStart), error('Parameter for PlotEnd must be greater than PlotStart.'); end

   % Variables in the mat-file and their dimensions
      % OBJ_F:          Name of objective function                   [1 Length]
      % GenAll:         Generation, where saved                      [NGenSaved 1]
      % ShowChrom[Gen]: Chrom of generation Gen                      [Nind Nvar]
      % ShowIndAll:     Best Chrom of every generation               [gen Nvar]
      % ObjV[Gen]:      ObjV of last saved generation                [Nind NObj]
      % ObjVBestAll:    Best ObjV of every generation                [gen NObj]
      % ObjVAllAll:     ObjV of all Ind of every generation          [gen*Nind NObj]
      % SUBPOPAll:      size of subpopulations of every generation   [gen NumSUBPOP]
      % PosSubPopFilt:  filtered order of subpopulations             [gen NumSUBPOP]
      % VLUB:           boundaries of variables                      [2 Nvar]
      
   % Load file internally
      action = 'chge'; Command = strvcat(['o'; 'p'], Command); Initial = 1;
      
   % Do the processing of the different options
      while ~strcmp(action, 'exit'),  
         % Plot results
         if strcmp(action, 'plot'),
            % Calculate the plot parameters
               PlotEnd = min(PlotEnd, MaxGen);
               IxGenPlotEnd = find(GenAll >= PlotEnd);
               IxGenPlotEnd = IxGenPlotEnd(1);
               PlotEnd = GenAll(IxGenPlotEnd);
      
            % Select the variables to send to resplot
               ResShowIndAll    = ShowIndAll(1:PlotEnd,:);
               ResObjVBestAll   = ObjVBestAll(1:PlotEnd,:);
               ResObjVAllAll    = ObjVAllAll(1:(Nind*PlotEnd),:);
               ResSUBPOPAll     = SUBPOPAll(1:PlotEnd,:);
               if exist('PosSubPopFilt') ~= 1, ResPosSubPopFilt = [];
               elseif size(PosSubPopFilt,1) < PlotEnd, ResPosSubPopFilt = [];
               else ResPosSubPopFilt = PosSubPopFilt(1:PlotEnd,:); end
               eval(['ResShowChrom = ShowChrom' int2str(PlotEnd) ';'])
               eval(['ResObjV = ObjV' int2str(PlotEnd) ';'])
               if exist('VLUB') ~= 1, VLUB = []; end
               if isempty(VLUB), VLUB = feval(OBJ_F, [], 1); end

            % call the plot function
               resplot(['Results: ' OBJ_F ' - ' int2str(PlotEnd) '. generation (' int2str(PlotStart) '.-' int2str(PlotEnd) '.)'], ...
                       [PlotEnd, PlotStart, PlotMask, PlotStyle], ...
                       ResShowChrom, VLUB, ResShowIndAll, ResObjV, ResObjVBestAll, ResObjVAllAll, ResSUBPOPAll, ResPosSubPopFilt);
            action = 'chge';

         % Change some of the plot parameters or save figure
         elseif strcmp(action, 'chge'),
            if ~isempty(Command), 
               % Use command supplied by input parameter
               whattask = Command(1,:);
               Command = Command(2:size(Command,1),:);
            else
               % Ask for action to do
               DataString = sprintf(['stArt: %d, End (%d): %d, Mask: %d, stYle: %d, Forward, Back, \n', ...
                                     'Save, Rotate, rePlot, eVal, Load (%s), eXit'], ...
                                     PlotStart, MaxGen, PlotEnd, PlotMask, PlotStyle, strrep(FileName,'\','\\'));
               whattask = input(sprintf('%s\nWhat to do?: ', DataString), 's');
               whattask = lower(whattask);
            end

            % Increase PlotStart and PlotEnd, means plot of next data block, forward
            if isempty(whattask), whattask = 'f'; end
            % Run Forward, show next data block
            if whattask == 'f',
               PlotEndOld = PlotEnd;
               PlotEnd = GenAll(min(IxGenPlotEnd + 1, length(GenAll)));
               PlotStart = PlotStart + (PlotEnd - PlotEndOld);
               action = 'plot';
            % Decrease PlotStart and PlotEnd, means plot of previous data block, backward
            elseif whattask == 'b',
               PlotEndOld = PlotEnd;
               PlotEnd = GenAll(max(IxGenPlotEnd - 1, 1));
               PlotStart = max(1, PlotStart - (PlotEndOld - PlotEnd));
               action = 'plot';
            % Define new PlotStart
            elseif whattask == 'a',
               PlotStart = input(sprintf('New PlotStart (%d): ', PlotStart));
               if PlotStart > PlotEnd, PlotEnd = min(MaxGen, PlotStart + 40); end
            % Define new PlotEnd
            elseif whattask == 'e',
               PlotEnd   = input(sprintf('New PlotEnd (%d of %d): ', PlotEnd, MaxGen));
            % Define new PlotMask
            elseif whattask == 'm',
               PlotMask  = input('New PlotMask: ');
            % Define new PlotStyle
            elseif whattask == 'y',
               PlotStyle = input('New PlotStyle: ');

            % Give name of file and save figure to file
            elseif whattask == 's',
               if ~isempty(Para1), PrintFileName = Para1; Para1 = [];
               else PrintFileName = input('FileName for printing: ', 's'); end
               if ~isempty(PrintFileName),
                  if any([isempty(Para2), ~isnan(Para2)]), PrintHow = Para2; Para2 = NaN;
                  else PrintHow = input('print style (EPS, c: epsc, 2: eps2): ', 's'); end
                  eval(['print -deps' PrintHow ' -tiff ' PrintFileName ])
                  % eval(['print -deps' PrintHow  ' ' PrintFileName ])
                  disp(sprintf('   Grafic saved in file: %s', PrintFileName))
               end

            % Rotate the current axes
            elseif whattask == 'r',
               if ~isempty(Para1), WhatRotate = Para1; Para1 = [];
               else WhatRotate = input('How to rotate (r, l, u, d; f behind for full rotate): ', 's'); end
               if ~isempty(WhatRotate),
                  compplot('rotate_axes', WhatRotate);
               end

            % Load data file
            elseif any([whattask == 'l', whattask == 'o']),
               if any([isempty(FileName), whattask == 'l'])
                  if exist('PathNameData', 'var') ~= 1, PathNameData = ''; end
                  FileNameLoad = [PathNameData, '*.mat'];
                  [FileNameData, PathNameData] = uigetfile(FileNameLoad, 'Select file with binary result data from optimization!');
                  FileNameLoad = [PathNameData, FileNameData];
               elseif whattask == 'o', FileNameLoad = FileName; end
               if ischar(FileNameLoad),   % else an error occured
                  FileName = FileNameLoad;
                  load(FileName);
               end
               % Set some variables and so on
               MaxGen = GenAll(length(GenAll));
               % Calculate number of individuals of whole population
               eval(['Nind = size(ShowChrom' int2str(GenAll(1,1)) ', 1);'])

            % Eval the stuff 
            elseif whattask == 'v',
               if ~isempty(Para1), WhatEval = Para1; Para1 = [];
               else WhatEval = input('What to eval [eval(whatever is typed)]: ', 's'); end
               if ~isempty(WhatEval),
                  eval(WhatEval);
               end
            % Plot the results, finish of changing parameters
            elseif whattask == 'p',
               action = 'plot';
            % If nothing of the above, then exit function
            elseif whattask == 'x',
               action = 'exit';
            else
               disp(sprintf('Unknown task %s! (Press x for exit!)', whattask)); 
            end
         end
      end

% End of function
