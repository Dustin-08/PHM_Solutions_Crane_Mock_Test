% RESult PLOTing of GEA Toolbox optimization
%
% This function plots most of the results of the evolutionary
% algorithm during computation.
%
% Syntax:  resplot(FigName, PlotOpt, Chrom, VLUB, IndBest, ObjV, ObjVBest, ObjVAll, SUBPOPAll, PosSubPopAll)
%
% Input parameters:
%    FigName   - String containing name for plot figure
%    PlotOpt   - (optional) Vector containing plot parameters
%                PlotOpt(1): Generation - (optional) scalar containing the
%                               number of the current generation
%                            if omitted or NaN, Generation = 1  is assumed
%                PlotOpt(2): PlotStart - (optional) scalar containing start
%                                generation for plotting results.
%                            if omitted or NaN, PlotStart = 1 is assumed
%                PlotOpt(3): PlotMask - (optional) scalar containing
%                            binary mask for used plots
%                           (1: plot; 0,2,3,...: no plot) 
%                PlotOpt(4): PlotStyle - (optional) scalar containing
%                            integer mask for style of every plot
%                PlotOpt(5): LocalDimension - (optional) see comploc
%    Chrom     - Matrix containing the chromosomes of the current population.
%                   Each row corresponds to one individual.
%    VLUB      - Matrix describing the boundaries of each variable of the individuals.
%    IndBest   - Matrix containing the best individual (variables) of each
%                   generation. Each row corresponds to one individual.
%    ObjV      - Vector containing objective values of the current generation
%    ObjVBest  - Matrix containing the best (and average) objective values of each
%                   generation, [best value per generation, average value per generation]
%    ObjVAll   - Matrix containing all objective values of all generations,
%                   each row corresponds to one generation
%                   gen 1: [objvalind_1(1:numobjval)  objvalind_2(1:numobjval) ...;
%                   gen 2:  objvalind_1(1:numobjval)  objvalind_2(1:numobjval) ...;
%                       ...
%                   gen n:  objvalind_1(1:numobjval)  objvalind_2(1:numobjval) ... ]
%    SUBPOPAll - (optional) Matrix/vector containing number of individuals
%                   per subpopulation/number of subpopulations of all generations
%    PosSubPopAll - (optional) Matrix/vector containing positions of subpopulations
%                   of all generations
%
% Output parameter:
%    no output parameter
%
% See also: geamain, compdiv, compplot

%  Author:  Hartmut Pohlheim
%  History: 16.09.1994  file created
%           05.02.1995  labels shortened
%           06.03.1995  new plot: distance distribution histogram
%           24.04.1995  Parameter FigName added
%           20.06.1995  input parameter checking and plot check added
%           30.06.1996  order of parameters changed
%           02.08.1996  display of true number of generation in plot of
%                          values of multiple generation added
%                       parameter and plot of SUBPOPAll (size of 
%                          subpopulations) added
%           06.08.1996  limit to x-axis of most plots set, usefull for odd
%                          number of variables using all space
%                       limit to y-axis of plot all obj values set to
%                          80% of good individuals, title of plot changed
%           07.10.1996  switches for plot or not of individual subplots added
%                       new style for plot of all objective values in current
%                          generation, added mean and standard derivation
%           08.10.1996  new plot styles added
%                       all plots reviewed and some enhanced
%                       handling of which plot to use enhanced, can be defined 
%                          by variables at the beginning of the file, more
%                          flexibility in plot selection
%                       default background color changed to white
%           09.10.1996  subpopulation dividers in plot of all objective values
%                          in current generation added
%                       plot of mean/std objective values of all generations
%                          only, when std is smaller than 10*diff in best 
%                          objective values
%           22.10.1996  image plot for all variables of current generation
%                          added
%                       fitness distance scatter plot added, uses data of
%                          current generation
%           23.10.1996  flexible handling of graphics to display added, look
%                          for DoPlotMask
%                       paperposition and corresponding figuresize/position
%                          added, needed for printing of figure to file
%                       automatic saving of figure after every display, see
%                          end of function
%           12.11.1996  use of imagesc instead of image
%           05.12.1996  use plotstd for standard plot settings
%                       better scaling for imagesc plots
%                       XLim and YLim in fitness-distance plot defined
%           23.01.1997  support for two languages added (german and english),
%                          labels for both languages added
%           29.01.1997  new plot methods added:
%                          best individuals over all generations (3-d 
%                             line, color quilt)
%                          all objective values over all generations 
%                             (3-d line, color quilt)
%                       correct std in plot of best and mean objective 
%                          values implemented
%           27.02.1997  new plots added for: best ObjV for every subpopulation
%                          option in first plot (best ObjV over all generations)
%                       some collisions excluded, if called after one
%                          generation or with data of only one generation
%                          (some plots need data from more than one generation)
%           28.02.1997  new plots added for local neighbourhood (2-D)
%                          all objective values of current generation
%                          distance between neighbours
%           20.04.1998  added VLUB as additional parameter
%           22.04.1998  included scaling of variable values according to VLUB
%                          in style 2 and 4
%           23.04.1998  introduced Variables with numbers of styles for future 
%                          extensions (BOVAll, VBIAll, ...)
%           05.05.1998  solved problem with YLim scaling at multiple places, 
%                          functionality moved to visuminmaxdiff(compplot/'get_min_max_diff')
%           06.05.1998  output of generation number in title of state plots (infos 
%                          about one generation)
%           05.10.1998  included surf plot in visualization of best individuals of 
%                          all generations (new option 2 there), nearly the same as
%                          plot3 variant
%                       introduced meshgrid instead of this calculation by hand, easier
%                          to understand
%           08.04.1999  plot of all objective values of all generations shows just the 
%                        first (of possible multiple) objective value per individual
%           25.05.1999  when new data is added to figure, figure does NOT pop up
%                          (just current figure, and not visible figure)
%           28.06.1999  changed label description from "number of ..." to "index of ..."
%           09.11.1999  plot of cluster analysis results added
%           29.03.2000  all plot stuff to private functions moved (for c++ compilation needed)
%           15.05.2000  new type for best objective values over really all generations (BOVAllGen)
%                          mostly used for presentations to present the whole optimization
%                          type is numer 8 (fdc was disabled)
%           27.05.2001  index error corrected in plotvarbestindall when extracting data
%           22.08.2004  use always PaperUnits 'inches' (otherwise the printed grafics have 
%                          a different size and resolution with user specific setting inches 
%                          or centimeters
%           09.10.2004  extended most of the graphic labels to full words (especially 
%                          necessary for printed publications)
%           09.01.2005  fill color of the plot of all obj. values of one generation defined as 
%                          index in the current color map (this produces a gray filled area when
%                          using a gray color map - useful for printed publication in black/white)


function resplot(FigName, PlotOpt, Chrom, VLUB, IndBest, ObjV, ObjVBest, ObjVAll, SUBPOPAll, PosSubPopAll);


% Define language to use, g: german, e: english; everything else than 'g' is english
   Lan = 'e';
% Define colors to use for surf and so on
   colors1 = jet(90);
   % colors1 = gray(90);

% Check input parameters
   if nargin < 1,FigName = []; end 
   if isempty(FigName), FigName = ['Results of Evolutionary Algorithm']; end
   if nargin < 2, Plotopt = []; end
   if nargin < 3, Chrom = []; end
   if nargin < 4, VLUB = []; end
   if nargin < 5, IndBest = []; end
   if nargin < 6, ObjV = []; end
   if nargin < 7, ObjVBest = []; end
   if nargin < 8, ObjVAll = []; end
   if nargin < 9, SUBPOPAll = []; end
   if nargin <10, PosSubPopAll = []; end

% Check and set plot parameters
   NumPossibleGraphics = 9;
   BOVAll = 1; VBIAll = 2; OVAll = 3; VAIGen = 4; OVGen = 5; SUBAll = 6; DDGen = 7; FDDGen = 10; CluAna = 9;
   BOVAllGen = 8;
   % Generation = 1, PlotStart = 1, PlotMask, PlotStyle, LocalDimension = 0
   PlotOptStandard = [1, 1, 111110000, 211112111, 0];

   if isnan(PlotOpt), PlotOpt = []; end
   if length(PlotOpt) > length(PlotOptStandard), error(' Too many parameter in PlotOpt'); end

   PlotOptIntern = PlotOptStandard; PlotOptIntern(1:length(PlotOpt)) = PlotOpt;
   Generation = PlotOptIntern(1);
   PlotStart  = PlotOptIntern(2);
   PlotMask   = PlotOptIntern(3);
   PlotStyle  = PlotOptIntern(4); 
   LocalDimension = PlotOptIntern(5);

   if isnan(Generation), Generation = PlotOptStandard(1);
   elseif (Generation < 0), warning('Parameter for Generation must be greater or equal than 0.'); Generation = 1; end

   if isnan(PlotStart), PlotStart = PlotOptStandard(2);
   else PlotStart = max(1, PlotStart); end
   if (PlotStart >= Generation), PlotStart = max(1, Generation - 40); end

   if any([isnan(PlotMask), PlotMask == 0]), PlotMask = PlotOptStandard(3);
   elseif (PlotMask >= 10^NumPossibleGraphics), 
      warning(sprintf('Parameter for PlotMask must be a scalar with %d or less positions.', NumPossibleGraphics));
   end
   PlotMask = str2num(sprintf('%d', PlotMask)')';
   PlotMask = (PlotMask==ones(size(PlotMask)));
   PlotMask = PlotMask(1:min([length(PlotMask), NumPossibleGraphics]));

   if any([isnan(PlotStyle), PlotStyle == 0]), PlotStyle = PlotOptStandard(4);
   elseif (PlotStyle >= 10^NumPossibleGraphics), 
      warning(sprintf('Parameter for PlotStyle must be a scalar with %d or less positions.', NumPossibleGraphics));
   end
   PlotStyle = str2num(sprintf('%d', PlotStyle)')';
   PlotStyle = PlotStyle(1:min([length(PlotStyle), NumPossibleGraphics]));

% Reshape matrix of all objective values (before: [gen*Nind NObj], after: [gen Nind*NObj])
   if ~isempty(ObjVAll),
      if ((Generation * size(Chrom, 1)) == size(ObjVAll, 1)),
         ObjVAll = reshape(ObjVAll',(size(ObjVAll, 2)*size(ObjVAll, 1)/Generation), Generation)'; % size(ObjVAll);
      else warning('Size of ObjVAll and number of individuals in Chrom disagree!'); end
   end


% Define graphics to plot
   StandardPlotMask = zeros(1, NumPossibleGraphics);
   StandardPlotStyle = str2num(sprintf('%d', PlotOptStandard(4))')';
   
   DoPlotMask = [PlotMask, StandardPlotMask(length(PlotMask)+1:length(StandardPlotMask))];
   PlotStyle = [PlotStyle, StandardPlotStyle(length(PlotStyle)+1:length(StandardPlotStyle))];

% Define, if subplots are plotted; 0: no plot; >= 1: plot and style of plot
   DoPlotGraphic = zeros(1, NumPossibleGraphics);

% Check, if variables are available for the special plots

   % plot of best and mean value per generation
   % 1: 2-D line plot of best objective value per generation
   % 2: 2-D line plot (errorbar) of best objective value and standard
   %    deviation of all objective values
   % 3: 2-D log-y line plot of best objective value per generation
   % 5: 2-D line plot of best objective value of every subpopulation per generation
   % 6: 2-D log-y line plot of best objective value of every subpopulation per generation
   if all([~isempty(ObjVBest)]),
      DoPlotGraphic(BOVAll) = PlotStyle(BOVAll);
      if ~any(DoPlotGraphic(BOVAll) == [1:3, 5, 6, 7]), DoPlotGraphic(BOVAll) = StandardPlotStyle(BOVAll); end
   end
   if all([~isempty(ObjVBest)]),
      DoPlotGraphic(BOVAllGen) = PlotStyle(BOVAllGen);
      if ~any(DoPlotGraphic(BOVAllGen) == [1:3, 5, 6]), DoPlotGraphic(BOVAllGen) = StandardPlotStyle(BOVAllGen); end
   end

   % plot of variables of best individual in all generations
   % 1: 2-D (multi) line plot of variable of best individual
   %    in every generation, 1 line per variable
   % 2: 3-D surf plot of variables of best individual
   %    in every generation, 1 line per variable
   % 3: 3-D line plot of variables of best individual
   %    in every generation, 1 line per variable
   % 4: 2-D image plot (color quilt) of variables of best individual
   %    in every generation, color is variable value
   % 6:9: same as 1:4 with scaled variables using VLUB
   if all([~isempty(IndBest), ~isempty(VLUB)]),
      DoPlotGraphic(VBIAll) = PlotStyle(VBIAll);
      if ~any(DoPlotGraphic(VBIAll) == [1:4, 6:9]), DoPlotGraphic(VBIAll) = StandardPlotStyle(VBIAll); end
   end

   % plot of all objective values of all generations
   % 1: 2-D (multi) line plot of all objective values of all
   %    generations, 1 line per individual
   % 3: 3-D line plot of all objective values of all
   %    generations, 1 line per individual
   % 4: 2-D image plot (color quilt) of all objective values of all
   %    generations, color is objective value
   if all([~isempty(ObjVAll), size(ObjVAll,1) > 1]),
      DoPlotGraphic(OVAll) = PlotStyle(OVAll);
      if ~any(DoPlotGraphic(OVAll) == [1, 3, 4]), DoPlotGraphic(OVAll) = StandardPlotStyle(OVAll); end
   end

   % plot of variables of all individuals in current generation
   % 1: 2-D line grafic of all variables of all individuals
   %    in current generation, 1 line per individual
   % 2: 2-D line grafic (errorbar) of all variables of all
   %     individuals in current generation
   % 3: 3-D line grafic of all variables of all individuals
   %    in current generation, 1 line per individual
   % 4: 2-D image plot (color quilt) of all variables of all
   %    individuals in current generation
   % 6:9: same as 1:4 with scaled variables using VLUB
   if all([~isempty(Chrom), ~isempty(VLUB)])
      DoPlotGraphic(VAIGen) = PlotStyle(VAIGen);
      if ~any(DoPlotGraphic(VAIGen) == [1:4, 6:9]), DoPlotGraphic(VAIGen) = StandardPlotStyle(VAIGen); end
   end
   
   % plot of all objective values in current generation
   % 1: 2-D point plot scaled to some% best of the objective values
   % 2: 2-D fill plot  scaled to some% best of the objective values
   % 3: 2-D image plot scaled to some% best of the objective values (2-D neighbourhood) 
   % 4: same as 1 with exchanged axes
   if all([~isempty(ObjV)]),
      DoPlotGraphic(OVGen) = PlotStyle(OVGen);
      if ~any(DoPlotGraphic(OVGen) == [1:5]), DoPlotGraphic(OVGen) = StandardPlotStyle(OVGen); end
   end
   
   % plot of size of subpopulation
   % 1: 2-D line plot of number of individuals in every subpopulation,
   %    1 line per subpopulation, 
   % 2: 2-D line plot of relative number of individuals in every
   %    subpopulation, 1 line per subpopulation
   % 3: 2-D line plot of positions of subpopulations, 1 line
   %    per subpopulation
   if any([all([size(SUBPOPAll,1) > 1, any(diff(SUBPOPAll))]), all([size(PosSubPopAll, 1) > 1, size(PosSubPopAll, 2) > 1])])
      DoPlotGraphic(SUBAll) = PlotStyle(SUBAll);
      if ~any(DoPlotGraphic(SUBAll) == [1, 2, 3]), DoPlotGraphic(SUBAll) = StandardPlotStyle(SUBAll); end
   end
   
   % plot of distance distribution
   % 1: 2-D stairs plot of distance between variables of all individuals (no neighbourhood)
   % 2: 2-D stairs plot of distance between variables of neighbours (1-D neighbourhood)
   % 3: 2-D image plot of distance between variables of neighbours (2-D neighbourhood)
   % 4: 3-D surf plot of distance between variables of neighbours (2-D neighbourhood)
   %    in current generation
   if all([~isempty(Chrom), size(Chrom, 1) > 4]),
      DoPlotGraphic(DDGen) = PlotStyle(DDGen);
      if ~any(DoPlotGraphic(DDGen) == [1, 2, 3, 4]), DoPlotGraphic(DDGen) = StandardPlotStyle(DDGen); end
   end

   % plot of fitness-distance scatter diagram
   % 1: 2-D point plot of fitness distance distribution of current generation
   % if all([~isempty(Chrom), ~isempty(IndBest), size(Chrom, 1) > 9]),
   %    DoPlotGraphic(FDDGen) = PlotStyle(FDDGen);
   %    if ~any(DoPlotGraphic(FDDGen) == [1]), DoPlotGraphic(FDDGen) = StandardPlotStyle(FDDGen); end
   % end
   
   % plot of cluster analysis results (dendrogram and cluster tree)
   % 1: only dendrogram of whole population
   % 2: only cluster tree diagram of whole population
   % 3: dendrogram and cluster tree diagram of whole population
   % 5: dendrogram of whole population and every subpopulation
   % 6: cluster tree diagram of whole population and every subpopulation
   % 7: dendrogram and cluster tree diagram of whole population and every subpopulation
   if all([~isempty(Chrom), ~isempty(VLUB)]),
      DoPlotGraphic(CluAna) = PlotStyle(CluAna);
      if ~any(DoPlotGraphic(CluAna) == [1:3, 5:6]), DoPlotGraphic(CluAna) = StandardPlotStyle(CluAna); end
   end

   % Create PlotMask
   DoPlotGraphic = DoPlotGraphic .* DoPlotMask;
   AllSubPlots = sum(DoPlotGraphic ~= 0);
   if (DoPlotGraphic(CluAna) ~= 0), AllSubPlots = AllSubPlots - 1; end

   % Create figure, when something to plot
   if AllSubPlots > 0,
      % Calculate number of rows and columns of subplots
      NumRowSubplots = floor(sqrt(AllSubPlots));
      NumColSubplots = ceil(AllSubPlots/NumRowSubplots);

      % look for figure, set name, paperposition, position and all standard settings
      UserDataString = 'geatbx_fig_resplot';
      figresplot = findobj('UserData', UserDataString);
      if isempty(figresplot),
         figresplot = figure('UserData', UserDataString, 'NumberTitle', 'Off', 'PaperUnits', 'inches');
      end
      set(figresplot, 'Name', FigName);
      
      % Set PaperPosition for saving of figure
      PaperPos = [0.5, 2.5, (1 + NumColSubplots * 9/2), (1.5 + NumRowSubplots * 7/2)];
      set(figresplot, 'PaperPosition', PaperPos);
      % Set all standard settings defined in plotstd
      plotstd(figresplot);
      % Clear all objects in figure
      delete(get(figresplot,'Children'));
      
      set(0, 'CurrentFigure', figresplot);
      SubPlotNum = 1;
      colormap(colors1(10:size(colors1,1),:)); 
   end

   % Loop over all plot types
   for igraphic = 1:NumPossibleGraphics,
      if DoPlotGraphic(igraphic) ~= 0,
         subplot(NumRowSubplots, NumColSubplots, SubPlotNum); SubPlotNum = SubPlotNum + 1;
         % Create PlotOptions intern
         PlotOptInt = {DoPlotGraphic(igraphic), PlotStart, Lan, NumRowSubplots*NumColSubplots, Generation};
         % Call private function for plotting
         % plot of best objective value per generation (and mean objective value  and standard derivation)
         if igraphic == BOVAll, plotbestobjvalall(PlotOptInt, ObjVBest, ObjVAll, SUBPOPAll); end
         % Same as above with plotting of all generations
         if igraphic == BOVAllGen, PlotOptInt{2} = 1; plotbestobjvalall(PlotOptInt, ObjVBest, ObjVAll, SUBPOPAll); end
         % plot of variables of best individuals in all generations
         if igraphic == VBIAll, plotvarbestindall(PlotOptInt, IndBest, VLUB); end
         % plot of all objective values of all generations
         if igraphic == OVAll,  plotallobjvalall(PlotOptInt, ObjVAll, ObjV); end
         % plot of variables of all individuals in current generation
         if igraphic == VAIGen, plotvarallindgen(PlotOptInt, Chrom, IndBest, VLUB); end
         % plot of variables of all individuals in current generation
         if igraphic == OVGen,  plotallobjvalgen(PlotOptInt, ObjV, SUBPOPAll, Chrom, LocalDimension); end
         % plot of variables of all individuals in current generation
         if igraphic == SUBAll, plotsubpopall(PlotOptInt, SUBPOPAll, PosSubPopAll); end
         % plot of distance distribution histogram
         if igraphic == DDGen, plotdistdistribution(PlotOptInt, Chrom, SUBPOPAll, LocalDimension); end
         % plot of fitness - distance scatter plot
         % if igraphic == FDDGen, plotfitdist(PlotOptInt, IndBest, Chrom, ObjV); end
         % plot of cluster analysis results
         if igraphic == CluAna, plotclusteranalysis(PlotOptInt, SUBPOPAll, Chrom, VLUB, ObjV); end
      end
   end

   drawnow;


% End of function






% Private function for plotting best objective values
%
% Syntax:  plotbestobjvalall(PlotOptInt, ObjVBest, ObjVAll, SUBPOPAll)
%
% Input parameters:
%    PlotOptInt- Cell array containing the internal plot options
%       PlotType  - String containing name for plot figure
%       PlotStart - Scalar containing first generation to plot
%       Lan       - String containing language
%       NumSubplots- Scalar containing number of subplots (Rows*Cols)
%       Generation - Scalar containing number of generation (used for titles)
%    all other input parameters see private function call
%
% Output parameter:
%    no output parameter
%
% See also: resplot

%  Author:  Hartmut Pohlheim
%  History: 29.03.2000  file created

function plotbestobjvalall(PlotOptInt, ObjVBest, ObjVAll, SUBPOPAll)

   % Reassign internal plot options
   PlotType = PlotOptInt{1}; PlotStart = PlotOptInt{2}; Lan = PlotOptInt{3}; 

   IxObjVBest = [max(1, PlotStart):size(ObjVBest,1)];
   PlotObjVBest = ObjVBest(IxObjVBest,:);
   
   % 1: 2-D line plot of best objective value per generation
   % 2: 2-D line plot (errorbar) of best objective value and standard
   %    derivation of all objective values
   if any(PlotType == [1, 2, 5]),
      % Stuff for sortb
      % PlotObjVBest = PlotObjVBest./10497.*20998;
      LineHandle = plot(IxObjVBest, PlotObjVBest(:, 1));
      

   % 3: 2-D log-y line plot of best objective value per generation
   elseif any(PlotType == [3, 6]),
      LineHandle = semilogy(IxObjVBest, PlotObjVBest(:, 1));
   % 7: same as 5, axes exchanged
   elseif any(PlotType == [7]),
      LineHandle = plot(-PlotObjVBest(:, 1), IxObjVBest);
   end
   set(LineHandle, 'LineWidth', 4 * get(gca, 'LineWidth'));
   if Lan == 'g', TitleString = 'Beste Zielfktwerte'; 
   else           TitleString = 'Best objective values'; end

   if (PlotType == 1),
      % everything is already done above

   elseif all([PlotType == 2, ~isempty(ObjVAll)]),
      PlotObjVAll = ObjVAll(IxObjVBest,:);
      % Look for NaN and set them top maximal value 
      if any(any(isnan(PlotObjVAll))),
         IxIsNaN = find(isnan(PlotObjVAll));
         PlotObjVAll(IxIsNaN) = repmat(max(max(PlotObjVAll)), [1, length(IxIsNaN)]);
      end
      % calculation mean of all objective values
      MeanObjVAll = mean(PlotObjVAll');
      % Add plot with mean and standard derivation only, when
      % max diff between min Mean and max ObjVBest is smaller
      % than 10*diff between max and min ObjVBest
      diffObjVBest = max(max(PlotObjVBest)) - min(min(PlotObjVBest));
      diffMeanObjVAll = min(min(MeanObjVAll)) - max(max(PlotObjVBest));
      if diffMeanObjVAll < (10 * diffObjVBest),
         % Calculate std of objective values smaller and bigger than mean
         % for producing a more correct std plot, for loop must be used
         StdObjVAllSmaller = zeros(size(IxObjVBest));
         StdObjVAllBigger = zeros(size(IxObjVBest));
         for istd = 1:length(IxObjVBest),
            IxSmaller = find(PlotObjVAll(istd,:) < MeanObjVAll(istd));
            ObjSmaller = PlotObjVAll(istd, IxSmaller);
            ObjSmaller = [ObjSmaller, (2 * MeanObjVAll(istd) - ObjSmaller)];
            StdObjVAllSmaller(istd) = std(ObjSmaller);
            IxBigger = find(PlotObjVAll(istd,:) > MeanObjVAll(istd));
            ObjBigger = PlotObjVAll(istd, IxBigger);
            ObjBigger = [ObjBigger, (2 * MeanObjVAll(istd) - ObjBigger)];
            StdObjVAllBigger(istd) = std(ObjBigger);
         end
         % Add mean and std plot (not replacing)
         StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
         errorbar(IxObjVBest, MeanObjVAll, StdObjVAllSmaller, StdObjVAllBigger);
         % errorbar(IxObjVBest, MeanObjVAll, StdObjVAllSmaller, StdObjVAllBigger);
         set(gca, 'NextPlot', StoreNextPlot);
         if Lan == 'g', TitleString = 'Beste Zielfktwerte u.a.';
         else           TitleString = 'Best/mean objective values'; end
      end
   elseif all([any(PlotType == [5, 6, 7]), ~isempty(ObjVAll), ~isempty(SUBPOPAll)]),
      PlotObjVBestSubpop = repmat(NaN, [length(IxObjVBest), size(SUBPOPAll,2)]);
      % Check for multiple objective values per individual
      objvmulti = size(ObjVAll, 2) / sum(SUBPOPAll(1,:));
      for iobjv = 1:length(IxObjVBest),
         for isubpop = 1:size(SUBPOPAll,2),
            % Use only the first objective value per individual (if objvmulti ~= 1)
            IxSubPop = [sum(SUBPOPAll(IxObjVBest(iobjv), 1:isubpop-1))*objvmulti+1:objvmulti:...
                        sum(SUBPOPAll(IxObjVBest(iobjv), 1:isubpop))*objvmulti];
            PlotObjVBestSubpop(iobjv, isubpop) = min(ObjVAll(IxObjVBest(iobjv), IxSubPop));
            % disp([sprintf('%4d (%d) %2d: ', iobjv, IxObjVBest(iobjv), isubpop), ...
            %       '  IxSubPop: ', sprintf('%3d ', IxSubPop), ...
            %       '  ObjVAll: ',  sprintf('%8.3g  ', ObjVAll(IxObjVBest(iobjv), IxSubPop)),...
            %       '  BestObjV: ', sprintf('%8.3g  ', PlotObjVBestSubpop(iobjv, isubpop))]);
            % pause
         end
      end
      if length(IxObjVBest) == 1, IxObjVBest = [1:size(PlotObjVBestSubpop, 2)]; end
      % Add best objective value of each subpopulation (not replacing)
      StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
      if any(PlotType == [5]),
         LineHandle2 = plot(IxObjVBest, PlotObjVBestSubpop);
      % swtest special method
      elseif any(PlotType == [7]),
         LineHandle2 = plot(-PlotObjVBestSubpop, IxObjVBest);
      elseif (PlotType == 6),
         LineHandle2 = semilogy(IxObjVBest, PlotObjVBestSubpop);
      end
      set(gca, 'NextPlot', StoreNextPlot);
      if Lan == 'g', TitleString = 'Beste Zielfktwerte je Unterpopulation';
      else           TitleString = 'Best objective values per subpopulation'; end
   end
   % swtest special method
   if any(PlotType == [7]),
      set(gca, 'YLim', [IxObjVBest(1)-1,  IxObjVBest(length(IxObjVBest))+1]);
      set(gca, 'XLim', [0, 40]);
      % Plot a vertical line for possible minimum
      DivLinePos = 30; CurXLim = get(gca, 'XLim'); CurYLim = get(gca, 'YLim');  
      StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
      DivLineHandle = plot([DivLinePos DivLinePos], CurYLim, '--', 'LineWidth', 2);
      DrawPatches = 0;
      if DrawPatches < 2, delete(LineHandle); delete(LineHandle2); end
      if DrawPatches > 0,
      % Get the corners of the patches, then plot them
         PatchVert = [CurXLim(1) CurYLim(1); CurXLim(1) CurYLim(2); DivLinePos CurYLim(2); ...
                      DivLinePos CurYLim(1); CurXLim(2) CurYLim(1); CurXLim(2) CurYLim(2)];
         PatchHandles = patch('Vertices', PatchVert, ...
                              'Faces', [ 1 2 3 4; 3 4 5 6], 'FaceVertexCData', [.4 1 .7; 1 .5 .5], ...
                              'FaceColor', 'flat', 'EdgeColor', 'none');
         % Repeat the plot lines from above to be drawn above the patches
         LineHandle = plot(-PlotObjVBestSubpop, IxObjVBest, 'LineWidth', 2);
         if DrawPatches < 2, delete(LineHandle); end
         % LineHandle = plot(-PlotObjVBest(:, 1), IxObjVBest, 'LineWidth', 3);
      end
      
      set(gca, 'NextPlot', StoreNextPlot, 'Layer', 'top');

      if Lan == 'g', ylabel('Generation'), xlabel('Zielfunktionswert');
      else           ylabel('generation'), xlabel('max. execution time [ms]'); end
   else
      set(gca, 'XLim', [IxObjVBest(1)-1,  IxObjVBest(length(IxObjVBest))+1]);
      if Lan == 'g', xlabel('Generation'), ylabel('Zielfunktionswert');
      else           xlabel('generation'), ylabel('objective value'); end
   end
   title(TitleString);

% End of private function


% Private function for plotting variables of best individuals
%
% Syntax:  plotvarbestindall(PlotOptInt, IndBest)
%
% Input parameters:
%    see plotbestobjvalall and private function call
%
% Output parameter:
%    no output parameter
%
% See also: resplot

%  Author:  Hartmut Pohlheim
%  History: 29.03.2000  file created

function plotvarbestindall(PlotOptInt, IndBest, VLUB)

   % Reassign internal plot options
   PlotType = PlotOptInt{1}; PlotStart = PlotOptInt{2}; Lan = PlotOptInt{3};  NumSubplots = PlotOptInt{3};

   % Assign label strings depending on language 
   if Lan == 'g', TextVarBestInds_Ylabel_1 = 'Wert der Variable';
   else           TextVarBestInds_Ylabel_1 = 'value of variable'; end
   if Lan == 'g', TextVarBestInds_Ylabel_2 = 'Wert der Variable (skaliert)';
   else           TextVarBestInds_Ylabel_2 = 'value of variable (scaled)'; end
   if Lan == 'g', TextVarBestInds_Ylabel_3 = 'Index der Variable'; 
   else           TextVarBestInds_Ylabel_3 = 'index of variable'; end
   if Lan == 'g', TextVarBestInds_Title_1 = 'Variablen der besten Individuen';
   else           TextVarBestInds_Title_1 = 'variables of best individuals'; end
   if Lan == 'g', TextVarBestInds_Title_2 = 'Variablen der besten Individuen (skaliert)';
   else           TextVarBestInds_Title_2 = 'variables of best individuals (scaled)'; end
   if Lan == 'g', TextVarBestInds_Xlabel = 'Generation';
   else           TextVarBestInds_Xlabel = 'generation'; end

   % Select individuals to plot
   MaxInd2Plot = 200;
   if size(IndBest,2) > MaxInd2Plot, IxIndBest = round(linspace(max(1, PlotStart), size(IndBest,1), MaxInd2Plot));
   else IxIndBest = [max(1, PlotStart):size(IndBest,1)]; end
   % Select variables to plot
   IxVarsVarBestInds = 1:1:size(IndBest,2);
   PlotIndBest = IndBest(IxIndBest, IxVarsVarBestInds);

   % 6, 7, 8, 9: same as 1, 2, 3, 4 with scaled variables using VLUB
   % Scale variables according to VLUB
   ScaledVarBestInds = 0;
   if any(PlotType == [6, 7, 8, 9]),
      ScaledVarBestInds = 1;
      PlotIndBest = compplot('scale_variables', PlotIndBest, VLUB);
      PlotType = PlotType - 5;
   end
   
   % Calculate difference for axes scaling
   [MinPlotIndBest, MaxPlotIndBest, DiffPlotIndBest] = visuminmaxdiff(PlotIndBest, [1, 0.03, 1e-5]);


   % 1: 2-D (multi) line plot of variables of best individuals
   %    in every generation, 1 line per variable
   if any(PlotType == [1]),
      if size(PlotIndBest,1) == 1, IxIndBest = [1:size(PlotIndBest,2)]; end
      HandleLines = plot(IxIndBest, PlotIndBest);
      set(gca, 'YLim', [MinPlotIndBest - DiffPlotIndBest, MaxPlotIndBest + DiffPlotIndBest]);
      ylabel(TextVarBestInds_Ylabel_1);
      if ScaledVarBestInds == 1, ylabel(TextVarBestInds_Ylabel_2); end
      % Do legend plot only for single/triple grafics and a few variables
      if all([NumSubplots <= 2, size(IndBest,2) < 10]),
         % Change style of Lines and place legend
         compplot('set_linestyle', HandleLines);
         LegString = [];
         for irunleg = IxVarsVarBestInds, LegString = [LegString; sprintf('%2g ', irunleg)]; end
         % Place legend outside plot
         legend(LegString, -1);
      end
      
   % 3: 3-D line plot of variables of best individual
   %    in every generation, 1 line per variable
   elseif any(PlotType == [2, 3]),
      % Define maximal number of data sets to visualize in 3-D
      if PlotType == 2, NumUseGenAll = 50; else NumUseGenAll = 100; end
      % Extract the data to visualize, when too much data
      if length(IxIndBest) > NumUseGenAll,
         IxIndBest3D = round(linspace(1, size(PlotIndBest,1), NumUseGenAll));
         PlotIndBest = PlotIndBest(IxIndBest3D,:);
         IxIndBest = IxIndBest(IxIndBest3D);
      end
      % Get the mesh grid needed for the 3-D grafics
      [GenPIB, NvarPIB] = size(PlotIndBest);
      [X3D, Y3D] = meshgrid(IxIndBest, 1:NvarPIB);
      if PlotType == 2, surf( X3D', Y3D', PlotIndBest);
      else                           plot3(X3D', Y3D', PlotIndBest);  end
      set(gca, 'ZLim', [MinPlotIndBest*(1-eps) - DiffPlotIndBest, MaxPlotIndBest*(1+eps) + DiffPlotIndBest]);
      set(gca, 'YLim', [1-.4  NvarPIB+.4]);
      zlabel(TextVarBestInds_Ylabel_1);
      if ScaledVarBestInds == 1, zlabel(TextVarBestInds_Ylabel_2); end
   
   % 4: 2-D image plot (color quilt) of variables of best individual
   %    in every generation, color is variable value
   elseif any(PlotType == [4]),
      if size(PlotIndBest,1) == 1, IxIndBest = [1:size(PlotIndBest,2)]; end
      imagesc([IxIndBest], [1:size(PlotIndBest, 2)], PlotIndBest');
      colorbar;
   end
   % Set Xlim for all plots
   set(gca, 'XLim', [IxIndBest(1)-1, IxIndBest(length(IxIndBest))+1]);

   title(TextVarBestInds_Title_1);
   if ScaledVarBestInds == 1, title(TextVarBestInds_Title_2); end
   xlabel(TextVarBestInds_Xlabel);
   if any(PlotType == [2, 3, 4]), ylabel(TextVarBestInds_Ylabel_3); end

% End of private function


% Private function for plotting objective values of all individuals of all generations
%
% Syntax:  plotallobjvalall(PlotOptInt, ObjVAll, ObjV)
%
% Input parameters:
%    see plotbestobjvalall and private function call
%
% Output parameter:
%    no output parameter
%
% See also: resplot

%  Author:  Hartmut Pohlheim
%  History: 29.03.2000  file created

function plotallobjvalall(PlotOptInt, ObjVAll, ObjV);

   % Reassign internal plot options
   PlotType = PlotOptInt{1}; PlotStart = PlotOptInt{2}; Lan = PlotOptInt{3};

   % Check for multiobjective case, show only first objective value
   NumMultiObjV = size(ObjV, 2);
   UseObjVAll = ObjVAll(:,[1:NumMultiObjV:size(ObjVAll, 2)]);
   % UseObjVAll = ObjVAll;    & use all ObjV
   % Select generations and individuals to plot
   MaxGen2Use = 150;
   if (size(UseObjVAll, 1)-PlotStart) > MaxGen2Use,
      IxUsedGen = round(linspace(max(1, PlotStart), size(UseObjVAll, 1), MaxGen2Use));
   else IxUsedGen = [max(1, PlotStart):1:size(UseObjVAll, 1)]; end
   MaxObjV2Use = 100;
   if size(UseObjVAll, 2) > MaxObjV2Use, 
      IxUsedInd = round(linspace(1, size(UseObjVAll, 2), MaxObjV2Use));
   else IxUsedInd = [1:1:size(UseObjVAll, 2)]; end
   PlotObjVAll = UseObjVAll(IxUsedGen, IxUsedInd);

   % scale the objective values: set worse objective values to objective value
   % of individual at position 1-
   GoodIndForScale = 0.85;     % percent of good individuals not scaled
   [MinObjVal, MaxObjVal, DiffObjVal] = visuminmaxdiff(PlotObjVAll, [GoodIndForScale, 0.03, 1e-5]);

   PlotObjVAll = PlotObjVAll .* (PlotObjVAll <= MaxObjVal) + ...
                                 MaxObjVal .* (PlotObjVAll > MaxObjVal);

   % 1: 2-D (multi) line plot of all objective values of all
   %    generations, 1 line per individual
   if PlotType == 1,
      plot(IxUsedGen, PlotObjVAll','o');
      set(gca, 'YLim', [MinObjVal - DiffObjVal, MaxObjVal + DiffObjVal]);
      if Lan == 'g', ylabel('Zielfunktionswert');
      else           ylabel('objective value');   end
      
   % 3: 3-D line plot of all objective values of all
   %    generations, 1 line per individual
   elseif PlotType == 3,
      [NindPOA, NvarPOA] = size(PlotObjVAll);
      % Get the mesh grid for the 3-D function
      [X3D, Y3D] = meshgrid(IxUsedGen, IxUsedInd);
      plot3(X3D', Y3D', PlotObjVAll);
      set(gca, 'ZLim', [MinObjVal*(1-eps) - DiffObjVal, MaxObjVal*(1-eps) + DiffObjVal]);
      if Lan == 'g', zlabel('Zielfunktionswert');
      else           zlabel('objective value');   end

   % 4: 2-D image plot (color quilt) of all objective values of all
   %    generations, color is objective value
   elseif PlotType == 4,
      imagesc(IxUsedGen, IxUsedInd, PlotObjVAll');
      colorbar;
   end
   % Set XLim for all plots
   set(gca, 'XLim', [IxUsedGen(1)-1, IxUsedGen(length(IxUsedGen))+1]);
   % Define labels      
   if Lan == 'g', title(sprintf('Zielfktw. je Gen. (%g%% besten)',  (GoodIndForScale)*100));
   else           title(sprintf('Objective values of all generations (%g%% best)',(GoodIndForScale)*100)); end
   if Lan == 'g', xlabel('Generation');
   else           xlabel('generation'); end
   if any(PlotType == [3, 4]),
      if Lan == 'g', ylabel('Index des Individuums');
      else           ylabel('index of individual');   end
   end

% End of private function


% Private function for plotting variables of all individuals of current/one generations
%
% Syntax:  plotvarallindgen(PlotOptInt, Chrom, IndBest)
%
% Input parameters:
%    see plotbestobjvalall and private function call
%
% Output parameter:
%    no output parameter
%
% See also: resplot

%  Author:  Hartmut Pohlheim
%  History: 29.03.2000  file created

function plotvarallindgen(PlotOptInt, Chrom, IndBest, VLUB)

   % Reassign internal plot options
   PlotType = PlotOptInt{1}; PlotStart = PlotOptInt{2}; Lan = PlotOptInt{3}; Generation = PlotOptInt{5};

   IxIndsVarIndsGen = 1:1:size(Chrom,1);     % Select individuals to plot
   IxVarsVarIndsGen = 1:1:size(Chrom,2);     % Select variables to plot
   PlotChrom = Chrom(IxIndsVarIndsGen, IxVarsVarIndsGen);

   % 6-9: same as 1-4 with scaled variables using VLUB
   % Scale variables according to VLUB
   ScaledVarIndsGen = 0;
   if any(PlotType == [6:9]),
      ScaledVarIndsGen = 1;
      PlotChrom = compplot('scale_variables', PlotChrom, VLUB);
      PlotType = PlotType - 5;
   end

   if any(PlotType == [1, 2]),
      % 1: 2-D line grafic of all variables of all individuals
      %    in current generation
      if any(PlotType == [1]),
         plot(PlotChrom');

      % 2: 2-D line grafic (errorbar) of all variables of all
      %     individuals in current generation
      elseif any(PlotType == [2]),
         MeanChrom = mean(PlotChrom);      % mean of variables
         StdChrom = std(PlotChrom);        % standard derivation of variables 
         XNum = [1:size(PlotChrom,2)];
         errorbar(XNum', MeanChrom', StdChrom');

      end
      
      % Add plot of best individual
      if ~isempty(IndBest),
         BestChrom = IndBest(size(IndBest,1),:);
         if ScaledVarIndsGen == 1; BestChrom = compplot('scale_variables', BestChrom, VLUB); end
         StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
         AxesColorOrder = get(gca, 'ColorOrder');
         LineHandle = plot(BestChrom); 
         set(LineHandle, 'Color', AxesColorOrder(3,:), 'LineWidth', 4 * get(gca, 'LineWidth'));
         set(gca, 'NextPlot', StoreNextPlot);
      end

   % 3: 3-D line grafic of all variables of all individuals
   %    in current generation
   elseif any(PlotType == [3]),
      [NPCH, VPCH] = size(PlotChrom');
      [X3D, Y3D] = meshgrid(IxVarsVarIndsGen, IxIndsVarIndsGen );
      plot3(X3D', Y3D', PlotChrom');
      % Calculate difference for axes scaling
      [MinPlotChrom, MaxPlotChrom, DiffPlotChrom] = visuminmaxdiff(PlotChrom, [1, 0.03, 1e-5]);

      set(gca, 'ZLim', [MinPlotChrom*(1-eps) - DiffPlotChrom, MaxPlotChrom*(1+eps) + DiffPlotChrom]);

   % 4: 2-D image plot (color quilt) of all variables of all
   %    individuals in current generation
   elseif any(PlotType == [4]),
      imagesc([1:size(PlotChrom, 2)], [1:size(PlotChrom, 1)], PlotChrom);
      colorbar;
   end
   
   % Set XLim for all plots
   % set(gca, 'XLim', [0.9, size(Chrom, 2)+.1]);
   set(gca, 'XLim', [0.4, size(Chrom, 2)+.6]);

   % Define labels for plots
   if any(PlotType == [2]),
      if Lan == 'g', TextVarIndsGen_Title_1 = 'Var. des besten und mittleren Ind.';
      else           TextVarIndsGen_Title_1 = 'variables of best and mean individual'; end
   else
      if Lan == 'g', TextVarIndsGen_Title_1 = 'Variablen aller Ind.';
      else           TextVarIndsGen_Title_1 = 'variables of all individuals'; end
   end
   if Lan == 'g', TextVarIndsGen_Ylabel_1 = 'Wert der Variable';
   else           TextVarIndsGen_Ylabel_1 = 'value of variable'; end
   if ScaledVarIndsGen == 1;
      if Lan == 'g', TextVarIndsGen_Ylabel_1 = [TextVarIndsGen_Ylabel_1 ' (skaliert)'];
      else           TextVarIndsGen_Ylabel_1 = [TextVarIndsGen_Ylabel_1 ' (scaled)']; end
      if Lan == 'g', TextVarIndsGen_Title_1 = [TextVarIndsGen_Title_1 ' (skaliert)'];
      else           TextVarIndsGen_Title_1 = [TextVarIndsGen_Title_1 ' (scaled)']; end
   end
   if Lan == 'g', TextGen = 'Gen:'; else TextGen = 'gen:'; end
   title(sprintf('%s [%s %d]', TextVarIndsGen_Title_1, TextGen, Generation));
   if Lan == 'g', xlabel('Index der Variable');
   else           xlabel('index of variable'); end
   if any(PlotType == [1, 2]),
      ylabel(TextVarIndsGen_Ylabel_1);
   else
      if Lan == 'g', ylabel('Index des Individ.');
      else           ylabel('index of individual'); end
      zlabel(TextVarIndsGen_Ylabel_1);
   end

% End of private function


% Private function for plotting all objectives values current/one generations
%
% Syntax:  plotallobjvalgen(PlotOptInt, ObjV, SUBPOPAll, Chrom, LocalDimension)
%
% Input parameters:
%    see plotbestobjvalall and private function call
%
% Output parameter:
%    no output parameter
%
% See also: resplot

%  Author:  Hartmut Pohlheim
%  History: 29.03.2000  file created

function plotallobjvalgen(PlotOptInt, ObjV, SUBPOPAll, Chrom, LocalDimension)

   % Reassign internal plot options
   PlotType = PlotOptInt{1}; PlotStart = PlotOptInt{2}; Lan = PlotOptInt{3}; Generation = PlotOptInt{5};

   % Check for multiobjective case
   ShowObjV = ObjV(:, 1);
   
   UseIndsForScale = 0.85;     % percent of worse objective values not used for scaling
   [minObjV, maxObjV, diffminmaxObjV] = visuminmaxdiff(ShowObjV, [UseIndsForScale, 0.05, 1e-5]);
   IxHigherObjV = find(ShowObjV > maxObjV);
   ScaledPlotObjV = ShowObjV;
   ScaledPlotObjV(IxHigherObjV) = repmat(maxObjV, [length(IxHigherObjV), 1]);
   % disp([sprintf('maxObjV: %g', maxObjV), sprintf('size ShowObjV: %s  size ScaledPlotObjV: %s ', sprintf('%d  ', size(ShowObjV)), sprintf('%d  ', size(ScaledPlotObjV)))]);
         
   % Check for dimension of local neighbourhood
   if any(PlotType == [3, 4]),
      if ~isempty(SUBPOPAll), LocNind = SUBPOPAll(1); else LocNind = size(Chrom, 1); end
      LocalDimensionObjV = comploc('local_dimension', LocalDimension, LocNind);
      % If number of dimensions of neighbourhhod is 1, use 1-D plot
      if length(LocalDimensionObjV) == 1, PlotType = 2; end
   end

   if (PlotType == 1),
      % Plot values as points
      plot(ScaledPlotObjV, '+');
   % swtest special method
   elseif (PlotType == 5),
      % Plot values as points
      % swtest 
      LineHandle = plot(-ScaledPlotObjV, 1:size(ScaledPlotObjV,1), 'b*');
      % Set limits of axes
      set(gca, 'YLim', [0, size(ShowObjV, 1) + 1]);
      % set(gca, 'XLim', [minObjV - diffminmaxObjV, maxObjV + 0.3*diffminmaxObjV]);
      set(gca, 'XLim', [0 40]);
      DivLinePos = 30; CurXLim = get(gca, 'XLim'); CurYLim = get(gca, 'YLim');  
      StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
      % Plot a vertical line for possible minimum
      LineHandles = plot([DivLinePos DivLinePos], CurYLim, '--', 'LineWidth', 2);
      DrawPatches = 0;
      if DrawPatches > 0,
         % Get the corners of the patches, then plot them
         PatchVert = [CurXLim(1) CurYLim(1); CurXLim(1) CurYLim(2); DivLinePos CurYLim(2); ...
                      DivLinePos CurYLim(1); CurXLim(2) CurYLim(1); CurXLim(2) CurYLim(2)];
         PatchHandles = patch('Vertices', PatchVert, ...
                              'Faces', [ 1 2 3 4; 3 4 5 6], 'FaceVertexCData', [.4 1 .7; 1 .5 .5], ...
                              'FaceColor', 'flat', 'EdgeColor', 'none');
      end
      if DrawPatches < 2, delete(LineHandle); end
      set(gca, 'NextPlot', StoreNextPlot, 'Layer', 'top');

   elseif PlotType == 2,
      % Compute filled area, min (lower bound) is identical for all
      % max (upper bound) is first previous and than the actual value,
      % thus producing a stair of the objective values
      minYLimfill = (minObjV - 0.8 * diffminmaxObjV);
      XFillData = expandm([([1:size(ShowObjV, 1)] - 0.5), size(ShowObjV, 1) + 0.5], [1, 2]);
      % Get the color for the fill
      CurrentColormap = colormap; Color4Fill = CurrentColormap(10,:);
      fill(XFillData, [minYLimfill; expandm(ScaledPlotObjV, [2, 1]); minYLimfill], Color4Fill);   % [0.2 .7 0.2]
   elseif PlotType == 3,
      % Convert/reshape data from vector to matrix of size of LocalDimensionObjV
      XYScaledPlotObjV = reshape(ScaledPlotObjV(1:prod(LocalDimensionObjV(1:2))), LocalDimensionObjV(1), LocalDimensionObjV(2));
      imagesc([1:size(XYScaledPlotObjV, 2)], [1:size(XYScaledPlotObjV, 1)], XYScaledPlotObjV);
      colorbar;
   end
   if any(PlotType == [1, 2]),
      % Set limits of axes
      set(gca, 'XLim', [0, size(ShowObjV, 1) + 1]);
      set(gca, 'YLim', [minObjV - diffminmaxObjV, maxObjV + 0.3*diffminmaxObjV]);
      
      % Plot vertical lines between subpopulation
      if all([~isempty(SUBPOPAll), 1]),
         SUBPOP = SUBPOPAll(size(SUBPOPAll, 1), :);
         SUBPOP = compdiv('checksubpop', SUBPOP, size(ObjV, 1));
         NumSubPop = length(SUBPOP)-1;
         if NumSubPop > 0, 
            LinesSubPopDivX = repmat(cumsum(SUBPOP(1:NumSubPop)), [1, 2])' + 0.5;
            LinesSubPopDivY = repmat(get(gca, 'YLim'), [NumSubPop, 1])';
            StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
            LineHandles = plot(LinesSubPopDivX, LinesSubPopDivY,':');
            set(gca, 'NextPlot', StoreNextPlot);
         end
      end
   end
   
   % Define title of plot
   if Lan == 'g', title(sprintf('Zielfktw. (%g%% besten) [Gen: %d]', UseIndsForScale*100, Generation));
   else           title(sprintf('Objective values (%g%% best) [gen: %d]',   UseIndsForScale*100, Generation)); end
   % Define labels of plot
   if any([PlotType == [1, 2]]),
      if Lan == 'g', xlabel('Index des Individuums'); ylabel('Zielfunktionswert');
      else           xlabel('index of individual');  ylabel('objective value'); end
   % swtest special method
   elseif any([PlotType == [5]]),
      if Lan == 'g', ylabel('Index des Individuums'); xlabel('Zielfunktionswert');
      else           ylabel('index of individual');   xlabel('max. execution time [ms]'); end  % xlabel('objective value')
   elseif any([PlotType == [3]]),
      if Lan == 'g', xlabel('Position in Dimension 2'); ylabel('Position in Dimension 1');
      else           xlabel('position in dimension 2'); ylabel('position in dimension 1'); end
   end

% End of private function


% Private function for plotting position and size of subpopulations
%
% Syntax:  plotsubpopall(PlotOptInt, SUBPOPAll, PosSubPopAll)
%
% Input parameters:
%    see plotbestobjvalall and private function call
%
% Output parameter:
%    no output parameter
%
% See also: resplot

%  Author:  Hartmut Pohlheim
%  History: 29.03.2000  file created

function plotsubpopall(PlotOptInt, SUBPOPAll, PosSubPopAll)

   % Reassign internal plot options
   PlotType = PlotOptInt{1}; PlotStart = PlotOptInt{2}; Lan = PlotOptInt{3}; NumSubplots = PlotOptInt{4};

   % If size of subpopulations is empty or no diff, or method == 3, 
   % then use ranking of subpopulations
   if any([isempty(SUBPOPAll), ~any(diff(SUBPOPAll)), PlotType == 3]),
      PlotSubPop = PosSubPopAll; PlotType = 3;
   else PlotSubPop = SUBPOPAll; end

   % Use generations from PlotStart    % Use all generations
   IxSubPop = [max(1, PlotStart):size(PlotSubPop,1)];     % 1:size(PlotSubPop,1); % [max(1, PlotStart):size(PlotSubPop,1)];

   if PlotType == 1,
      HandleLines = plot(IxSubPop, PlotSubPop(IxSubPop,:));
      set(gca, 'YLim', [min(min(PlotSubPop))-0.5, max(max(PlotSubPop))+0.5]);
      if Lan == 'g', title('Größe der Unterpop.');
      else           title('size of subpopulations'); end
   elseif PlotType == 2,
      HandleLines = plot(IxSubPop, cumsum(PlotSubPop(IxSubPop,:)')');
      set(gca, 'YLim', [0.5, sum(PlotSubPop(1,:))+0.5]);
      if Lan == 'g', title('rel. Größe der Unterpop.');
      else           title('relative size of subpopulations'); end
   elseif PlotType == 3,
      HandleLines = plot(IxSubPop, PlotSubPop(IxSubPop,:));
      % plot(IxSubPop, cumsum(PlotSubPop(IxSubPop,:)')');
      set(gca, 'YLim', [min(min(PlotSubPop))-0.2, max(max(PlotSubPop))+0.2]);
      % set(gca, 'YLim', [0.5, sum(PlotSubPop(1,:))+0.5]);   % for cumsum
      if Lan == 'g', title('Ordnung der Unterpop.');
      else           title('order of subpopulations'); end
   end
   set(gca, 'XLim', [IxSubPop(1)-0.5  IxSubPop(length(IxSubPop))+0.5]);
   % Change sytele of Lines and place legend
   compplot('set_linestyle', HandleLines);
   if NumSubplots <= 2,
      LegString = [];
      for irunleg = 1:size(PlotSubPop, 2), LegString = [LegString; sprintf('%2g ', irunleg)]; end
      % Place legend outside plot
      legend(LegString, -1);
   end

   if Lan == 'g', xlabel('Generation');
   else           xlabel('generation'); end
   if any(PlotType == [1, 2]),
      if Lan == 'g', ylabel('Anzahl von Individuen');
      else           ylabel('number of individuals'); end
   elseif PlotType == 3,
      if Lan == 'g', ylabel('Rang einer Unterpopulation');
      else           ylabel('rank of subpopulation'); end
   end

% End of private function


% Private function for plotting distance distribution graphics
%
% Syntax:  plotdistdistribution(PlotOptInt, Chrom, SUBPOPAll, LocalDimension)
%
% Input parameters:
%    see plotbestobjvalall and private function call
%
% Output parameter:
%    no output parameter
%
% See also: resplot

%  Author:  Hartmut Pohlheim
%  History: 29.03.2000  file created

function plotdistdistribution(PlotOptInt, Chrom, SUBPOPAll, LocalDimension)

   % Reassign internal plot options
   PlotType = PlotOptInt{1}; PlotStart = PlotOptInt{2}; Lan = PlotOptInt{3}; Generation = PlotOptInt{5};

   [DistNind, DistNvar] = size(Chrom);

   if any([PlotType == [2, 3, 4]]),
      if ~isempty(SUBPOPAll), LocNind = SUBPOPAll(1); else LocNind = size(Chrom, 1); end
      LocalDimensionDist = comploc('local_dimension', LocalDimension, LocNind);
      % If number of dimensions of neighbourhhod is 1, use 1-D plot
      if length(LocalDimensionDist) == 1, PlotType = 2; end
   end

   if any([PlotType == [1]]),
      DistMaxInd = min(DistNind, 100);     % number of individuals
      DistMaxVar = min(DistNvar, 100);     % number of variables
      if any([DistNind > DistMaxInd, DistNvar > DistMaxVar])
         ChromDist = Chrom(1:floor(DistNind/DistMaxInd):DistNind, 1:floor(DistNvar/DistMaxVar):DistNvar);
      else ChromDist = Chrom; end
      Dist = compdiv('distance_chrom', ChromDist);
      Dist = Dist / DistMaxVar;
      [HistVals, HistBins] = hist(Dist, 50);

   % Employ a local neighbourhood (distances only correct when using one subpopulation))
   elseif any([PlotType == [2, 3, 4]]),
      IxDistChrom = [1:1:size(Chrom, 1)];
      IxNeighChrom = comploc('local_neighbourhood', size(Chrom, 1), IxDistChrom, [0 0 1]);
      DistNeighChrom = zeros(size(Chrom, 1), 1);
      for irun = 1:size(IxNeighChrom, 2),
         DistNeighChrom = DistNeighChrom + sqrt(sum(((Chrom(IxNeighChrom(:,irun),:) - Chrom).^2)')'); 
      end
      DistNeighChrom = DistNeighChrom/size(IxNeighChrom, 2);
      % pause
      HistBins = IxDistChrom; HistVals = DistNeighChrom;
   end

   % Typ specific plot commands
   if any([PlotType == [1, 2]]),
      stairs(HistBins, HistVals);
      set(gca, 'XLim', [HistBins(1), HistBins(length(HistBins))]);
   elseif any([PlotType == [3]]),
      % Convert/reshape data from vector to matrix of size of LocalDimensionDist
      XYHistVals = reshape(HistVals(1:prod(LocalDimensionDist(1:2))), LocalDimensionDist(1), LocalDimensionDist(2));
      imagesc([1:size(XYHistVals, 2)], [1:size(XYHistVals, 1)], XYHistVals);
      colorbar;
   elseif any([PlotType == [4]]),
      % Convert/reshape data from vector to matrix of size of LocalDimensionDist
      XYHistVals = reshape(HistVals(1:prod(LocalDimensionDist(1:2))), LocalDimensionDist(1), LocalDimensionDist(2));
      [NPCH, VPCH] = size(XYHistVals');
      X3D = repmat(1:NPCH, [VPCH, 1])'; Y3D = repmat(1:VPCH, [NPCH, 1]);
      % surf(X3D, Y3D, XYHistVals','*');
      surf(X3D, Y3D, XYHistVals');
      if Lan == 'g', zlabel('Distanz');
      else           zlabel('distance'); end         
   end
   % Define title
   if any([PlotType == [1]]),
      if Lan == 'g', DistTitle = 'Distanzverteilung';
      else           DistTitle = 'distance distribution'; end
   elseif any([PlotType == [2, 3, 4]]),
      if Lan == 'g', DistTitle = 'Distanz zu Nachbarn';
      else           DistTitle = 'distance to neighbours'; end
   end
   if Lan == 'g', TextGen = 'Gen:'; else TextGen = 'gen:'; end
   title(sprintf('%s [%s %d]', DistTitle, TextGen, Generation));
   % Define labels
   if any([PlotType == [1]]),
      if Lan == 'g', xlabel('Distanz');  ylabel('Häufigkeit');
      else           xlabel('distance'); ylabel('frequency'); end
   elseif any([PlotType == [2]]),
      if Lan == 'g', xlabel('Index des Individuums'); ylabel('Distanz');
      else           xlabel('index of individual');   ylabel('distance'); end
   elseif any([PlotType == [3, 4]]),
      if Lan == 'g', xlabel('Position in Dimension 2'); ylabel('Position in Dimension 1');
      else           xlabel('position in dimension 2'); ylabel('position in dimension 1'); end
   end

% End of private function


% Private function for plotting fitness distance distribution
%
% Syntax:  plotfitdist(PlotOptInt, IndBest, Chrom, ObjV)
%
% Input parameters:
%    see plotbestobjvalall and private function call
%
% Output parameter:
%    no output parameter
%
% See also: resplot

%  Author:  Hartmut Pohlheim
%  History: 29.03.2000  file created

function plotfitdist(PlotOptInt, IndBest, Chrom, ObjV)

   % Reassign internal plot options
   PlotType = PlotOptInt{1}; PlotStart = PlotOptInt{2}; Lan = PlotOptInt{3}; Generation = PlotOptInt{5};

   BestChrom = IndBest(size(IndBest,1),:);
   [fdccoeff, Fitnesses, Distances] = compdiv('fdc', ObjV(:,1), Chrom, BestChrom);

   plot(Distances, Fitnesses, 'o');
   set(gca, 'XLim', [0.9 * min(Distances), 1.1 * max(Distances)]);
   set(gca, 'YLim', [0.9 * min(Fitnesses)*(1-10*eps), 1.1 * max(Fitnesses)*(1+10*eps)]);
   if Lan == 'g', FitDistTitle = 'Fitneß-Distanz:';   TextGen = 'Gen:';
   else           FitDistTitle = 'Fitness-Distance:'; TextGen = 'gen:'; end
   title(sprintf('%s%.3g [%s %d]', FitDistTitle, fdccoeff, TextGen, Generation));
   if Lan == 'g', xlabel('Distanz');  ylabel('Fitneß');
   else           xlabel('distance'); ylabel('fitness'); end

% End of private function


% Private function for plotting cluster analysis graphics
%
% Syntax:  plotclusteranalysis(PlotOptInt, SUBPOPAll, Chrom, VLUB, ObjV)
%
% Input parameters:
%    see plotbestobjvalall and private function call
%
% Output parameter:
%    no output parameter
%
% See also: resplot

%  Author:  Hartmut Pohlheim
%  History: 29.03.2000  file created

function plotclusteranalysis(PlotOptInt, SUBPOPAll, Chrom, VLUB, ObjV)

   % Reassign internal plot options
   PlotType = PlotOptInt{1}; PlotStart = PlotOptInt{2}; Lan = PlotOptInt{3}; Generation = PlotOptInt{5};

   CluAnaOutput = [];
   if any(PlotType == [1, 3, 5, 7]), CluAnaOutput = 1; else CluAnaOutput = 0; end
   if any(PlotType == [2, 3, 6, 7]), CluAnaOutput = [CluAnaOutput 1]; else CluAnaOutput = [CluAnaOutput 0]; end
   CluAnaSUBPOP = 1;
   if any(PlotType == [5:7]), 
      if all([~isempty(SUBPOPAll), 1]),
         SUBPOP = SUBPOPAll(size(SUBPOPAll, 1), :);
         SUBPOP = compdiv('checksubpop', SUBPOP, size(ObjV, 1));
         CluAnaSUBPOP = SUBPOP;
      end
   end
   
   % Create plot title for cluster analysis diagrams
   if Lan == 'g', CluAnaTitle = sprintf('Clusteranalyse [Gen: %d]',   Generation);
   else           CluAnaTitle = sprintf('cluster analysis [gen: %d]', Generation); end
   
   % Call main cluster analysis function with default parameter for missing parameter
   clusmain(Chrom, VLUB, CluAnaSUBPOP, ObjV, CluAnaOutput, [], [], [], CluAnaTitle);

% End of private function
