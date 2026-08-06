% LOOK at saved GEATbx binary RESults 2 (plot)
%
% Syntax:  reslook2s(FileName, PlotOpt, Command, Para1, Para2)
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
%    no output parameter
%
% See also: resplot, geamain2

% Author:   Hartmut Pohlheim
% History:  13.01.1996  file created
%           23.01.1997  simple text interface added, allows changing
%                          all parameters of plot and saving of figure
%                       compatible with saving of data in geamain
%                       compatible with syntax in resplot
%           04.02.1997  added additional input parameters for batch
%                          processing of saving grafics
%           20.04.1998  added VLUB as additional parameter
%           09.12.2001  adapted to new structure in saving binary data
%           11.03.2002  added transfer of remote binary data files
%           29.04.2002  updates for compilation of function (no eval)
%           29.08.2004  correct handling of PosSubPopFilt
%           30.06.2005  added extraction of all individuals and objective values


function [out1, out2] = reslook2s(FileName, PlotOpt, Command, Para1, Para2)

   % Preset internal variables 
   PathNameData = '';
   RemoteMachineName = '';
   RemoteFileName = '';
   % Parameter for remote loop: {1}: 0 - no loop, 1 - loop; {2}: number of loops; {3}: time in s between loops
   RemoteTransferLoopPara = {0, 0, 100};
   % Preset output variables
   ou1 = []; out2 = [];

   % Start checking of PlotOpt
   if nargin < 1, FileName = []; end
   if isempty(FileName), FileName = []; end

   if nargin < 2, PlotOpt = []; end
   if isnan(PlotOpt), PlotOpt = []; end
   % Check for file name in PlotOpt
   if isempty(PlotOpt), VisuOptFileNamePath = 'etvisu1.geaopt';
   elseif ischar(PlotOpt), VisuOptFileNamePath = PlotOpt; PlotOpt = [];
   else VisuOptFileNamePath = ''; end
   % Try to open visualization parameter file
   [fidData, error_message] = fopen(VisuOptFileNamePath, 'r');
   if fidData >= 1, fclose(fidData); else VisuOptFileNamePath = ''; end
   
   
   if nargin < 3, Command = []; end
   if isnan(Command), Command = []; end

   if nargin < 4, Para1 = []; end
   if isnan(Para1), Para1 = []; end

   if nargin < 5, Para2 = NaN; end

   % Preset internal parameters
   PlotOptStandard = [1, NaN, 0, 0, 0];      % PlotStart = 1, PlotEnd = NaN, PlotMask, PlotStyle
   PlotPosition = [];
      
   if all([isempty(PlotOpt), ~(isempty(VisuOptFileNamePath))]),
      [VisuOptPathName, VisuOptFileName, VisuOptFileExt] = fileparts(VisuOptFileNamePath);
      GeaVisuOpt = geaoptload([VisuOptFileName, VisuOptFileExt], VisuOptPathName);
      if isempty(GeaVisuOpt), PlotOpt = [];
      else
         if isfield(GeaVisuOpt, 'Output'),
            PlotOpt = PlotOptStandard; 
            if isfield(GeaVisuOpt.Output, 'GrafikStartGen'), PlotOpt(1) = GeaVisuOpt.Output.GrafikStartGen; end
            if isfield(GeaVisuOpt.Output, 'GrafikEndGen'),   PlotOpt(2) = GeaVisuOpt.Output.GrafikEndGen;   end
            if isfield(GeaVisuOpt.Output, 'GrafikMethod'),   PlotOpt(3) = GeaVisuOpt.Output.GrafikMethod;   end
            if isfield(GeaVisuOpt.Output, 'GrafikStyle'),    PlotOpt(4) = GeaVisuOpt.Output.GrafikStyle;    end
            if isfield(GeaVisuOpt.Output, 'GrafikPosition'), PlotPosition = GeaVisuOpt.Output.GrafikPosition; end
         end
      end
   end

   if length(PlotOpt) > length(PlotOptStandard), 
      warning(' Too many parameter in PlotOpt');
      PlotOpt = PlotOpt(1:length(PlotOptStandard));
   end

   PlotOptIntern = PlotOptStandard; PlotOptIntern(1:length(PlotOpt)) = PlotOpt;
   PlotStart = PlotOptIntern(1); PlotEnd = PlotOptIntern(2);
   PlotMask = PlotOptIntern(3); PlotStyle = PlotOptIntern(4); 
   
   if isnan(PlotStart), Generation = PlotOptStandard(1);
   elseif (PlotStart < 1), PlotStart = 1; warning('Parameter for PlotStart must be greater or equal than 1.'); end

   if isnan(PlotEnd), PlotEnd = PlotOptStandard(2);
   elseif (PlotEnd < PlotStart), PlotEnd = PlotStart; warning('Parameter for PlotEnd must be greater than PlotStart.'); end

   % Variables in the mat-file (or structure in mat-file) and their dimensions
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
   if ~(isempty(Command)),
      if strcmp(Command(1,:), 'tn'),
         action = 'chge';
         RemoteMachineName = FileName{1}, RemoteFileName = FileName{2},
      end
      action = 'chge'; Command = strvcat(['o'], Command); Initial = 1;
   else
      % action = 'chge'; Command = strvcat(['o'; 'p'], Command); Initial = 1;
      action = 'chge'; Command = strvcat(['o'], Command); Initial = 1;
   end
      
   % Do the processing of the different options
   while ~strcmp(action, 'exit'),  
      % Load data, change some of the plot parameters or save figure
      if strcmp(action, 'chge'),
         if ~isempty(Command), 
            % Use command supplied by input parameter
            whattask = Command(1,:);
            if size(Command,1) > 1, Command = Command(2:end,:); else Command = []; end
         else
            % Ask for action to do
            DataString = sprintf(['stArt: %d, End (%d): %d, Mask: %d, stYle: %d, Forward, Back, \n', ...
                                  'Save, Rotate, rePlot, eVal, eXit\nLoad (%s), Transfer (%s)\nCollect all'], ...
                                  PlotStart, MaxGen, PlotEnd, PlotMask, PlotStyle, ...
                                  strrep(FileName,'\','\\'), sprintf('%s  %s', RemoteMachineName, RemoteFileName));
            whattask = input(sprintf('%s\nWhat to do?: ', DataString), 's');
            whattask = lower(whattask);
         end

         if isempty(whattask), whattask = 'f'; end

         % Load data file
         if any([whattask == 'l', whattask == 'o']),
            if any([isempty(FileName), whattask == 'l'])
               FileNameLoad = [PathNameData, '*.mat'];
               [FileNameData, PathNameData] = uigetfile(FileNameLoad, 'Select file with binary result data from optimization!');
               FileNameLoad = [PathNameData, FileNameData];
            elseif whattask == 'o', FileNameLoad = FileName; end
            if ischar(FileNameLoad),   % else an error occured
               FileName = FileNameLoad;
               GD = load(FileName);
               if isfield(GD, 'GEATbxData'),
                  GD = getfield(GD, 'GEATbxData');
               end
            end
            % Set some variables and so on
            MaxGen = GD.GenAll(length(GD.GenAll));
            % Calculate number of individuals of whole population
            Nind = size(getfield(GD, ['ShowChrom' int2str(GD.GenAll(1,1))]), 1);
            % eval(['Nind = size(GD.ShowChrom' int2str(GD.GenAll(1,1)) ', 1);'])
            
            % After load or open plot the data automatically
            action = 'plot';

         % Transfer data file from remote destination
         elseif any([strcmp(whattask, 't'), strcmp(whattask, 'tn'), strcmp(whattask, 'tl')]),
            if any([strcmp(whattask, 't'), isempty(RemoteMachineName)]),
               RemoteMachineName = input('Name of remote machine: ', 's');
               RemoteFileName = input('Name of remote file: ', 's');
            end
            if any([strcmp(whattask, 'tl')]),
               if RemoteTransferLoopPara{2} == 0; end
               RemoteTransferLoopPara{1} = 1;
            end
            EvalString = sprintf('!client %s %s', RemoteMachineName, RemoteFileName);
            eval(EvalString);
            % Crude hack for resetting the PlotEnd generation number
            PlotEnd = Inf;
            
            % Set the file name for the transfered remote file and open the file
            FileName = ['Data_', RemoteFileName]
            action = 'chge';
            Command = ['o'];
            
         % Increase PlotStart and PlotEnd, means plot of next data block, forward
         % Run Forward, show next data block
         elseif whattask == 'f',
            PlotEndOld = PlotEnd;
            PlotEnd = GD.GenAll(min(IxGenPlotEnd + 1, length(GD.GenAll)));
            PlotStart = PlotStart + (PlotEnd - PlotEndOld);
            action = 'plot';
         % Decrease PlotStart and PlotEnd, means plot of previous data block, backward
         elseif whattask == 'b',
            PlotEndOld = PlotEnd;
            PlotEnd = GD.GenAll(max(IxGenPlotEnd - 1, 1));
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

         % Collect all individuals and objective values and return them
         elseif whattask == 'c',
            AllChrom = []; AllObjV = [];
            for igen = 1:length(GD.GenAll),
               ColChrom = getfield(GD, ['ShowChrom' int2str(GD.GenAll(igen))]);
               ColObjV  = getfield(GD, ['ObjV'      int2str(GD.GenAll(igen))]);
               AllChrom = [AllChrom; ColChrom];
               AllObjV = [AllObjV; ColObjV];
            end         
            out1 = AllChrom;
            out2 = AllObjV;
         
         % Give name of file and save figure to file
         elseif whattask == 's',
            if ~isempty(Para1), PrintFileName = Para1; Para1 = [];
            else PrintFileName = input('FileName for printing: ', 's'); end
            if ~isempty(PrintFileName),
               if any([isempty(Para2), ~isnan(Para2)]), PrintHow = Para2; Para2 = NaN;
               else PrintHow = input('print style (EPS, c: epsc, 2: eps2): ', 's'); end
               if strcmp(PrintHow(1), '-'), PrintFormat = PrintHow(1:end);
               else PrintFormat = {['-deps', PrintHow], '-tiff'}; end
               if ~(iscell(PrintFormat)), PrintFormat = {PrintFormat}; end
               % exportfig(gcf, PrintFileName, 'Format', PrintFormat{1}, 'Color', 'rgb')
               print(PrintFormat{:}, PrintFileName)
               disp(sprintf('   Grafic saved in file: %s (%s)', PrintFileName, prprintf(PrintFormat)))
            end

         % Rotate the current axes
         elseif whattask == 'r',
            if ~isempty(Para1), WhatRotate = Para1; Para1 = [];
            else WhatRotate = input('How to rotate (r, l, u, d; f behind for full rotate): ', 's'); end
            if ~isempty(WhatRotate),
               compplot('rotate_axes', WhatRotate);
            end

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
         % Exit function
         elseif whattask == 'x',
            action = 'exit';
         % Close figure and Exit function
         elseif whattask == 'z',
            pause(5); close(gcf);
            action = 'exit';
         else
            disp(sprintf('Unknown task %s! (Press x for exit!)', whattask)); 
         end
         
      % Plot results
      elseif strcmp(action, 'plot'),
         % Calculate the plot parameters
         PlotEnd = min(PlotEnd, MaxGen);
         IxGenPlotEnd = find(GD.GenAll >= PlotEnd);
         IxGenPlotEnd = IxGenPlotEnd(1);
         PlotEnd = GD.GenAll(IxGenPlotEnd);
   
         % Select the variables to send to resplot
         ResShowIndAll    = GD.ShowIndAll(1:PlotEnd,:);
         ResObjVBestAll   = GD.ObjVBestAll(1:PlotEnd,:);
         ResObjVAllAll    = GD.ObjVAllAll(1:(Nind*PlotEnd),:);
         ResSUBPOPAll     = GD.SUBPOPAll(1:PlotEnd,:);
         if isfield(GD, 'PosSubPopFilt'), 
            if size(GD.PosSubPopFilt,1) < PlotEnd, ResPosSubPopFilt = [];
            else, ResPosSubPopFilt = GD.PosSubPopFilt(1:PlotEnd,:); end
         else ResPosSubPopFilt = []; end
         % if exist('PosSubPopFilt') ~= 1, ResPosSubPopFilt = [];
         % elseif size(GD.PosSubPopFilt,1) < PlotEnd, ResPosSubPopFilt = [];
         % else ResPosSubPopFilt = GD.PosSubPopFilt(1:PlotEnd,:); end
         % if isfield(GD, 'PosSubPopFilt'), ResPosSubPopFilt = GD.PosSubPopFilt(1:PlotEnd,:);
         % else ResPosSubPopFilt = []; end
         ResShowChrom = getfield(GD, ['ShowChrom' int2str(PlotEnd)]);
         % eval(['ResShowChrom = GD.ShowChrom' int2str(PlotEnd) ';'])
         ResObjV = getfield(GD, ['ObjV' int2str(PlotEnd)]);
         % eval(['ResObjV = GD.ObjV' int2str(PlotEnd) ';'])
         if ~(isfield(GD, 'VLUB')), GD.VLUB = []; end
         if isempty(GD.VLUB), GD.VLUB = feval(GD.OBJ_F, [], 1); end

         % call the plot function
         resplot(['Results: ' GD.OBJ_F ' - ' int2str(PlotEnd) '. generation (' int2str(PlotStart) '.-' int2str(PlotEnd) '.)'], ...
                 [PlotEnd, PlotStart, PlotMask, PlotStyle], ...
                 ResShowChrom, GD.VLUB, ResShowIndAll, ResObjV, ResObjVBestAll, ResObjVAllAll, ResSUBPOPAll, ResPosSubPopFilt);
                 
         % Set the position of the figure window
         if ~(isempty(PlotPosition)),
            % Get position of current figure
            SaveScreenSize = get(0,'Units');
            set(0, 'Units', 'pixels');
            ScreenSizePix = get(0, 'ScreenSize');
            set(0, 'Units', SaveScreenSize);
            
            bdwidth = 5; topbdwidth = 72;
            
            FigHdl = gcf;
            SaveFigurePos = get(FigHdl, 'Position');
            SaveFigureUnits = get(FigHdl, 'Units');
            set(FigHdl, 'Units', 'pixels');
            CurFigurePos = get(FigHdl, 'Position');
            
            NewFigurePos = CurFigurePos;
            sprintf('cur figure pos: %s', prprintf(NewFigurePos))
            
            if length(PlotPosition) > 0, NewFigurePos(1) = PlotPosition(1) * ScreenSizePix(3) + 1; end
            if length(PlotPosition) > 1, NewFigurePos(2) = PlotPosition(2) * ScreenSizePix(4) + 1; end
            if length(PlotPosition) > 2, NewFigurePos(3) = PlotPosition(3) * ScreenSizePix(3); end
            if length(PlotPosition) > 3, NewFigurePos(4) = PlotPosition(4) * ScreenSizePix(4); end
            sprintf('resized: %s', prprintf(NewFigurePos))
            
            if NewFigurePos(1) < bdwidth, NewFigurePos(1) = bdwidth; end
            if (NewFigurePos(1) + NewFigurePos(3) + bdwidth) > ScreenSizePix(3), 
               NewFigurePos(1) = ScreenSizePix(3) - NewFigurePos(3) - bdwidth;
            end
            if NewFigurePos(2) < bdwidth, NewFigurePos(2) = bdwidth + 5; end
            
            if (NewFigurePos(2) + NewFigurePos(4) + topbdwidth) > ScreenSizePix(4),
               NewFigurePos(2) = ScreenSizePix(4) - NewFigurePos(4) - topbdwidth;
            end
            
            if (NewFigurePos(1) + NewFigurePos(3) + bdwidth) > ScreenSizePix(3), 
               NewFigurePos(3) = ScreenSizePix(3) - NewFigurePos(1) - bdwidth;
            end
            if (NewFigurePos(2) + NewFigurePos(4) + topbdwidth) > ScreenSizePix(4), 
               NewFigurePos(4) = ScreenSizePix(4) - NewFigurePos(2) - topbdwidth;
            end
            NewFigurePos(1:2) = ceil(NewFigurePos(1:2));
            NewFigurePos(3:4) = floor(NewFigurePos(3:4));
            sprintf('rounded: %s', prprintf(NewFigurePos))
            set(FigHdl, 'Position', NewFigurePos);
            
            drawnow;
            set(FigHdl, 'Units', SaveFigureUnits);
            
         end
         action = 'chge';

      end
   end

% End of function
