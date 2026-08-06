% Plot function for Multidimensional scaling (SAMMON mapping)
%
% This function plots the results if SAMMON mapping, a multi-
% dimensional scaling method used for scaling multidimensional
% data to a lower dimension (normally to two or three dimensions).
% The initial data and the optimized data is shown and compared.
%
% Syntax:  samplot(DataLowOpt, DataLowStart, Labels, SamPlotOpt, FigName)
%
% Input parameter:
%    DataLowOpt- Matrix of optimized low-dimensional data
%                   every row corresponds to one data point 
%    DataLowStart- same as DataLowOpt before optimization
%                  (initialization of low-dimensional data)
%    Labels    - Array of strings used for labeling data points  
%    SamPlotOpt- Vector containing options for sammon mapping visu
%                SamOpt(1): SamPlotNumber
%                   number of the figure for sammon plot (used for 
%                   multiple successive plots into different figures)
%                   if omitted or NaN SamPlotNumber=1 is assumed
%
% Output parameter:
%    no output
%
% See also: sammon, plotstd

% Author:   Hartmut Pohlheim
% History:  05.06.97    file created
%           09.06.97    font size setting of labels added
%                       adjustment of some other settings
%           10.06.97    labels slightly moved away from points for better
%                          readability


function samplot(DataLowOpt, DataLowStart, Labels, SamPlotOpt, FigName)

% Set standard sammon parameter
   SamPlotOptStandard = [1];      % SamPlotNumber = 1

% Check input parameter
   if nargin < 4, SamPlotOpt = []; end 
   if isnan(SamPlotOpt), SamPlotOpt = []; end
   if length(SamPlotOpt) > length(SamPlotOptStandard),
      warning(' Too many parameters in SamPlotOpt');
      SamPlotOpt = SamPlotOpt(1:length(SamPlotOptStandard));
   end

   SamPlotOptIntern = SamPlotOptStandard; SamPlotOptIntern(1:length(SamPlotOpt)) = SamPlotOpt;
   SamPlotNumber = SamPlotOptIntern(1);

   if ~(SamPlotNumber >= 0),
      if  ~(isnan(SamPlotNumber)), warning('Parameter for sammon figure number must be larger or equal 0!'); end
      SamPlotNumber = SamPlotOptStandard(1);
   end

   if nargin < 5, FigName = []; end 
   if isnan(FigName), FigName = []; end


   [NPOpt, NDOpt] = size(DataLowOpt);
   [NPSt,  NDSt]  = size(DataLowStart);
   if NDOpt ~= NDSt, error('Dimension of data disagree.'); end
   if any(NDOpt == [2, 3]); PlotDim = NDOpt;
   else error('Dimension of Data must be 2 or 3!'); end

% look for figure, set Name
   FigUserDataString = ['geatbxfigsammon_' num2str(SamPlotNumber)];
   figplot = findobj('UserData', FigUserDataString);
   if isempty(figplot),
      figplot = figure('UserData', FigUserDataString, 'NumberTitle', 'Off');
   end
   
   if isempty(FigName), FigName = 'MDS results'; end
   set(figplot, 'Name', sprintf('%s %g', FigName, SamPlotNumber));
   figure(figplot);
   
   DoPlots = [1 3];
   DoSlideStyle = 0;

% Compute number of subplots according to DoPlots
   SubX = ceil(length(DoPlots)/2); SubY = ceil(length(DoPlots)/SubX);
   SubPlotPos = reshape(1:(SubX*SubY),SubY, SubX);

   % Set PaperPosition to choose enough area on paper
   PaperPos = [0.5 2.5 4+2.0*SubY 3+2.0*SubX];

   set(figplot, 'PaperPosition', PaperPos);
   % Set all the standard settings for a plot
   plotstd(figplot);

   AktPlotPos = 1;
   TitleLabel = {'optimized data', 'initial data', 'comparison'};
   ColorsPlot = get(gca, 'ColorOrder');

% Perform plotting
   for iplot = 1: length(DoPlots),
      subplot(SubX, SubY, SubPlotPos(iplot));
      if any(DoPlots(iplot) == [1, 3]),
         if PlotDim == 2,
            HandlePoints = plot(DataLowOpt(:,1), DataLowOpt(:,2), ...
                                '.', 'MarkerSize', 10, 'Color', ColorsPlot(1,:));
            if DoPlots(iplot) == 1,
               NextPlotOld = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
               % HandleLines = plot(DataLowOpt(:,1), DataLowOpt(:,2), ':', 'Color', ColorsPlot(1,:));
               set(gca, 'NextPlot', NextPlotOld);
            end
            [LimX] = get(gca, 'XLim'); DiffLimX = 0.02 * (LimX(2) - LimX(1));
            text(DataLowOpt(:,1) + DiffLimX, DataLowOpt(:,2), Labels, ...
                 'FontSize', 9, 'FontUnits', 'points', 'Interpreter', 'none');
         else
            HandlePoints = plot3(DataLowOpt(:,1), DataLowOpt(:,2), DataLowOpt(:,3), ...
                                 '.', 'MarkerSize', 10, 'Color', ColorsPlot(1,:));
            text(DataLowOpt(:,1), DataLowOpt(:,2), DataLowOpt(:,3), Labels);
            set(gca, 'ZTickLabel', []); set(gca, 'ZTick', []);
         end
         set(gca, 'XTickLabel', []); set(gca, 'YTickLabel', []);
         set(gca, 'XTick', []);      set(gca, 'YTick', []);
      end
      if any(DoPlots(iplot) == [2, 3]),
         if DoPlots(iplot) == 3, NextPlotOld = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add'); end
         if PlotDim == 2,
            HandlePoints = plot(DataLowStart(:,1), DataLowStart(:,2), '*', 'Color', ColorsPlot(2,:));
            if DoPlots(iplot) == 2, text(DataLowStart(:,1), DataLowStart(:,2), Labels, ...
                                         'FontSize', 0.02, 'FontUnits', 'normalized', 'Interpreter', 'none'); end
         else
            HandlePoints = plot3(DataLowStart(:,1), DataLowStart(:,2), DataLowStart(:,3), '*', 'Color', ColorsPlot(2,:));
            if DoPlots(iplot) == 2, text(DataLowStart(:,1), DataLowStart(:,2), DataLowStart(:,3), Labels); end
         end            
      end
      if any(DoPlots(iplot) == 3),
         CompData = [DataLowOpt'; DataLowStart'];
         if PlotDim == 2,
            HandleLines = plot(CompData([1, 3],:), CompData([2, 4],:), '-', 'Color', ColorsPlot(3,:));
         else
            HandleLines = plot3(CompData([1, 4],:), CompData([2, 5],:), CompData([3, 6],:), '-', 'Color', ColorsPlot(3,:));
         end
         % when using color solid lines (for slides), overwrites LineStyle to solid
         if DoSlideStyle == 1, set(HandleLines, 'LineWidth', 1.5); end
         if DoSlideStyle == 2, set(HandleLines, 'LineWidth', 1.5, 'LineStyle', '-'); end
         set(gca, 'NextPlot', NextPlotOld);
      end
      % set(gca,'XLim',[0 0.5]);   % grid;
      % set(gca,'YLim',[-1500 4100]);
      xlabel('dimension 1'); ylabel('dimension 2');
      if PlotDim == 3, zlabel('dimension 3'); end
      title(sprintf('%s (%s)', FigName, TitleLabel{DoPlots(iplot)}));
      % Legend only for first szenario
      % if iplot == 1, legend(['UNetz  ';'PLast1 ';'PLast2 ']); end
   end

   drawnow;


% End of function