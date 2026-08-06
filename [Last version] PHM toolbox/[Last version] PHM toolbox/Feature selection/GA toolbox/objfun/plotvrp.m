% PLOTing of results of VRP optimization
%
% This function plots some of the results during computation
% of the VRP examples.
%
% Syntax:  plotvrp(OBJ_F, chrom, gen, VRPData)
%
% Input parameters:
%    OBJ_F    - Vector containing the (name of the) objective function
%    chrom    - Vector containing the individual for simulation
%    gen      - Scalar containing the number of the current generation
%    VRPData  - additional parameter, structure with VRP data, see objvrp 
%               or vrpgetdata for more info
%
% Output parameter:
%    VRPResult- Matrix containing the results from objvrp
%
% See also: objvrp, dempvrp

% Author:   Hartmut Pohlheim
% History:  28.05.2005  file created


function VRPResult = plotvrp(OBJ_F, chrom, gen, VRPData, varargin);

   % Check input parameters
   if nargin <= 3, VRPData = []; end
   if nargin <= 2, gen = []; end
   if isempty(gen), gen = 1; end

   % Build objective function and compute states of individual(s)
   CalcInd = chrom(1:(min([5, size(chrom,1)])),:);
   [objval, VRPData, VRPResult] = feval(OBJ_F, CalcInd, VRPData, varargin{:});
   Dim = size(VRPData.XYData,1);
   
   % Create title string
   NameTour = geaobjpara(OBJ_F, 2, VRPData);
   TitleStr = sprintf(' %s  in gen %g', NameTour, gen);

   % look for figure, set Name
   FigUserName = 'geatbxfigstateplot_plotvrp';
   figplotvrp = findobj('UserData', FigUserName);
   if isempty(figplotvrp),
      figplotvrp = figure('UserData', FigUserName, 'NumberTitle', 'Off');
   end
   set(figplotvrp,'Name', sprintf('Results of %s: %s', OBJ_F, TitleStr));
   set(figplotvrp, 'defaultaxesfontsize', 8)
   figure(figplotvrp);
   set(figplotvrp, 'PaperPosition', [0.5 2.5 10 10]);
   plotstd(figplotvrp); delete(get(figplotvrp, 'Children'));

   % Get size of individual and states
   [Nind, Nvar] = size(CalcInd);

   pplot(VRPData.XYData, 'r.')
   StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
   % plot of best tours
   DefaultLineColors = get(figplotvrp, 'DefaultAxesColorOrder'); icolor = 1;
   for iplot = 1:Nind,
      CurRouteOrder = VRPResult.RouteOrder{iplot,:};
      for iroute = 1:length(CurRouteOrder),
         pplot(CurRouteOrder(iroute), VRPData.XYData, '--', 'Color', DefaultLineColors(icolor,:));
         icolor = rem(icolor, size(DefaultLineColors,1))+1;
      end
      pplot(CurRouteOrder, VRPData.XYData, num2cellstr(1:Dim))
   end
   set(gca, 'NextPlot', StoreNextPlot);

   % Create legend string and place legend
   LegString = [];
   for irunleg = 1:1,   % Nind,
      % Label for points and 
      LegString = strvcat(LegString, sprintf('all routes (%g) ', objval(irunleg,1)));
      CurRouteCost = VRPResult.RouteCost{irunleg, 1};
      for iroute = 1:length(VRPResult.RouteOrder{irunleg,:}),
         LegString = strvcat(LegString, sprintf('%2g. route (%g) ', iroute, CurRouteCost(iroute)));
      end
   end
   legend(LegString);

   title(sprintf('Route(s): %s', TitleStr));
   xlabel('x-coord'), ylabel('y-coord');

   drawnow;


% End of function
