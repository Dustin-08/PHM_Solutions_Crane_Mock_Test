% PLOT of objective functions as MESH Plot 
%
% This function takes the name of an objective function and produces
% a variation mesh plot using 2 dimensions or an variation line plot
% using one dimension. This gives an impression of the objective function
% or of the area around a good (or selected) point.
% The function may be used for a variation analysis or for demos.
%
% Syntax:  plotmesh(OBJ_F, Bounds, Points, varargin)
%
% Input:
%    OBJ_F     - string with function name of objective function
%                if omitted, 'objfun1' is assumed
%    Bounds    - Matrix containing the boundaries of the objective
%                function for mesh plotting, same format as in
%                objective function.
%                Bounds=[lower_bound_x1, lower_bound_x2;
%                        upper_bound_x1, upper_bound_x2]
%                if Bounds has more than 2 columns, than first one or two
%                    columns with Bounds(2)-Bounds(1) are used for variation
%                    plot
%                if Bounds are omitted, the objective function is called using
%                   geaobjpara to get the default boundaries
%    Points    - Scalar/vector containing number of mesh grid points.
%                If 2 scalars are provided, the first is used for
%                points in x1 and the second for points in x2.
%                If 1 scalar is provided it is used for points in x1 and x2
%                if ommitted, 25 points in both directions are assumed
%                "Undocumented features of Points"
%                if Points contains more than one row, each row has the 
%                following meaning:
%                first row:  number of mesh grid points
%                second row: value of optimum for first and second dimension
%                            a doted line is plotted along this value
%                third row: define limits for y-values of 2-D plots
%                           (does sometimes not work for 3-D plots)
%    varargin  - additional parameters for the objective function
%
% Output:
%    Plotdata  - (optional) cell array containing plot data 
%                currently only implemented for 2D-plots
%                see visubase for format description

%
% See also: meshvar
%
% Examples:
%    % plot with default parameters
%       plotmesh('objfun1');
%    % use default boundaries, use 20 grid point in both dimensions
%       plotmesh('objfun1', [], 20);
%    % same boundaries for both dimensions, use 100 grid points per dimension
%       plotmesh('objfun1', [-10; 10], 100); 
%    % define different points for every dimension
%       plotmesh('objfun1', [-10, -5; 10, 5], [40, 30]);
%    % define different points for every dimension, plot lines at x=0 and
%    % y=0 to indiciate optimum
%       plotmesh('objfun8', [-10, -5; 10, 5], [30, 30; 0, 0]);
%    % visualize variable 4 and 7 of multidimensional function, set the remaining 
%    % variable 1,2,3,5,6 and 8 to zero 
%       plotmesh('objfun10', [0,0,0,-20,0,0,-10,0;0,0,0,20,0,0,10,0], [50, 50; 0, 0]);

% Author:   Hartmut Pohlheim
% History:  15.03.1995  file created
%           04.10.1995  parameter Bounds and Points added
%                       examples added
%                       contour plot to mesh plot added
%           05.12.1996  use of plotstd added for standard plot settings
%           11.04.1997  renamed to plotmesh
%           15.05.1997  extension for arbitrary functions and dimensions
%           20.05.1997  if Points includes a second row, dotted lines are
%                          drawn at these positions (one- and two-dimensional
%                          plots), used for marking position of best value
%           21.05.1997  color of best value lines adapted
%           12.06.1997  interp shading fpr 3-D plot, grid off and 256 color
%                          values of colormap added
%           25.11.1997  interp shading is nearly inprintable, thus reverting
%                          to standard style for surf plot
%           21.01.1998  included additional code to use DPGEA for distribution
%                          of tasks, example in meshvar
%                          when global variable DPGEA_USE is 1, dpgeamain('master')
%                          is called for parallel calculation
%           24.02.1998  added setting of y-lim for 2-D plot, works for 3-D plots 
%                          and setting the z-lim as well
%                       added some more examples to show the extended stuff
%           30.03.1998  use of jet as default color map
%           22.04.1998  creation of evalstr slightly changed for 
%                          parameterless objective functions
%           08.11.1999  use of varargin instead of P1-P9
%                       get bounds and title from objective function by utility 
%                          function 'getdata_objfun' inside compdiv
%                       new calling of objective function (varargin)
%           11.01.2003  call of geaobjpara (instead of compdiv2)
%           23.01.2005  introduced output parameter PlotData to return the used data


function PlotData = plotmesh(OBJ_F, Bounds, Points, varargin)


% Set language ('g' german, else english) and colormap
   Lan = 'e';
   UseColors = jet(150);
   % UseColors = hsv(150);
   % UseColors = gray(100);   UseColors = UseColors(5:2:end-5,:);

% Global variable used for distribution of calculations
global DPGEA_USE
if isempty(DPGEA_USE), DPGEA_USE = 0; end
if DPGEA_USE ~= 1, DPGEA_USE = 0; end

% Reassign number of in- and output arguments
   NAIN = nargin; NAOUT = nargout;

% Set default parameters
   PlotData = {};
   if NAIN < 1, OBJ_F = []; end
   if isempty(OBJ_F), OBJ_F = 'objfun1'; end
   PlotTitle = ''; XLabel = ''; YLabel = ''; ZLabel = '';
   if iscell(OBJ_F),
      if length(OBJ_F) > 1, PlotTitle = char(OBJ_F{2}); end
      if length(OBJ_F) > 2, XLabel = char(OBJ_F{3}); end
      if length(OBJ_F) > 3, YLabel = char(OBJ_F{4}); end
      if length(OBJ_F) > 4, ZLabel = char(OBJ_F{5}); end
      OBJ_F = char(OBJ_F{1});
   end

% Bounds of objective function
   if NAIN < 2, Bounds = []; end
   if isempty(Bounds), Bounds = geaobjpara(OBJ_F, 1, varargin{:}); end
   if size(Bounds, 2) == 1, Bounds = [Bounds(:, 1), Bounds(:, 1)]; end
   if size(Bounds, 2) >= 2,
      IxBounds = find(diff(Bounds) > 0);
      if length(IxBounds) > 2,
         IxBounds = IxBounds([1,2]);
         % disp('Warning: More than two areas defined, set all except two Bounds to same max and min value!');
      end
      if length(IxBounds) == 1,
         OneDim = 1;
         if IxBounds > 1, IxBounds = [IxBounds, IxBounds-1];
         else IxBounds = [IxBounds, IxBounds+1]; end
      else OneDim = 0; end
   else OneDim = 0; IxBounds = [1, 2]; end
   Area1 = Bounds(:, IxBounds(1));
   Area2 = Bounds(:, IxBounds(2));

% Number of mesh grid points
   PointsDef = 40;
   if NAIN < 3, Points = []; end
   if isempty(Points), Points = PointsDef; end
   if size(Points, 2) == 1, Points = repmat(Points(:, 1), [1, 2]); end
   for inan = 1:2, if isnan(Points(1,inan)), Points(1,inan) = PointsDef; end, end
   if OneDim == 1, Points(1, 2) = 1; end


% Compute mesh values
   VarX = linspace(Area1(1), Area1(2), Points(1, 1));
   VarY = linspace(Area2(1), Area2(2), Points(1, 2));

   ValMesh = [];
   x = [];
   for iy = 1:length(VarY),
      % Copy Bounds as often as needed
      Chroms = repmat(Bounds(1,:), [length(VarX), 1]);
      % Set first changing row to x values
      Chroms(:, IxBounds(1)) = VarX';
      % Set second changing row to VarY(iy) value
      Chroms(:, IxBounds(2)) = repmat(VarY(iy), [length(VarX), 1]);
      x = [x; Chroms];
   end
   % Calculate objective values
   if DPGEA_USE == 0, ObjV = feval(OBJ_F, x, varargin{:});
   else ObjV = dpgeamain('master', OBJ_F, x, varargin{:}); end

   ValMesh = ObjV(:,1);
   % ValMesh(prod(size(ValMesh)))

   % Set values larger than defined to NaN for non-plottable or
   % to the maximum for a flat area on top of the grafic
   if size(Points,1) >= 3,
      if ~isnan(Points(3,2)),
         IxValLarger = find(ValMesh > Points(3,2));
         if length(IxValLarger) > 0,
            ValMesh(IxValLarger) = Points(3,2);
            % ValMesh(IxValLarger) = NaN;
         end
      end 
   end
   % length(VarX), length(VarY)
   ValMesh = reshape(ValMesh, length(VarX), length(VarY))';

% look for figure, set Name
   UserDataString = sprintf('demogeatoolbox_figmeshplot%d', IxBounds(1));
   figmesh = findobj('UserData', UserDataString);
   if isempty(figmesh), figmesh = figure('UserData', UserDataString); end
   figure(figmesh);
   if isempty(PlotTitle), PlotTitle = geaobjpara(OBJ_F, 2, varargin{:}); end
   set(figmesh, 'Name', [' Variation Plot of ' PlotTitle],...
                'NumberTitle', 'Off', 'resize', 'on');
   set(figmesh, 'PaperPosition', [0.5 2.5 12 10]);
   plotstd(figmesh); delete(get(figmesh,'Children'));
            
   % Gernerate mesh including contour plot in lower plane
   if OneDim == 0, 
      % Call surf for the actual plot
      surf(VarX, VarY, ValMesh);
      % Set the shading and lighting options
      % shading flat;
      shading interp;
      lighting phong;
      grid off;
      colormap(UseColors(10:size(UseColors, 1)-10,:));
      set(gca, 'XLim', [Area1(1), Area1(2)]);
      set(gca, 'YLim', [Area2(1), Area2(2)]);
      % Limit the z-values, doesn't always work as intended
      if size(Points, 1) >= 3,
         if length(Points(3,:)) >= 2,
            ZLimit = get(gca,'zlim');
            for inan = 1:2, if isnan(Points(3,inan)), Points(3,inan) = ZLimit(inan); end, end
            set(gca, 'ZLim', [Points(3,1), Points(3,2)]);
         end
      end
      % Add a contour plot at the bottom of the grafic
      % needed for setting special lower z-limit
      StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
      ZLowerLimit = get(gca,'zlim'); ZLowerLimit = ZLowerLimit(1);
      % Call contour to get the data
      [dummy,patchhandles] = contour3(VarX, VarY, ValMesh);
      % Set the z position of the data to lower z value
      for izset = 1:length(patchhandles)
         NewZ = get(patchhandles(izset),'Zdata');
         set(patchhandles(izset),'Zdata',ZLowerLimit*ones(size(NewZ)));
      end
      set(gca, 'NextPlot', StoreNextPlot);
      % Plot a line for used best value
      if size(Points, 1) >= 2,
         LineGoodIndX(:,1) = [Points(2,1); Points(2,1)];
         LineGoodIndX(:,2) = get(gca, 'XLim')';
         LineGoodIndY(:,1) = get(gca, 'YLim')';
         LineGoodIndY(:,2) = [Points(2,2); Points(2,2)];
         LineGoodIndZ      = get(gca, 'ZLim');
         LineGoodIndZ      = repmat(LineGoodIndZ(1), [2, 2]);
         StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
         LineHandles = plot3(LineGoodIndX, LineGoodIndY, LineGoodIndZ, ':');
         set(gca, 'NextPlot', StoreNextPlot);
      end
   elseif OneDim == 1,
      % Assign the output parameter of the function
      PlotData = {ValMesh, VarX}; 
      % Plot the data to a 2D-graphic
      plot(VarX, ValMesh);
      set(gca, 'XLim', [Area1(1), Area1(2)]);
      % Limit the y-values
      if size(Points, 1) >= 3,
         if length(Points(3,:)) >= 2,
            set(gca, 'YLim', [Points(3,1), Points(3,2)]);
         end
      end
      % Plot a line for used best value
      if size(Points, 1) >= 2,
         LineGoodIndX = [Points(2,1) Points(2,1)];
         LineGoodIndY = get(gca, 'YLim')';
         StoreNextPlot = get(gca, 'NextPlot'); set(gca, 'NextPlot', 'add');
         LineHandles = plot(LineGoodIndX, LineGoodIndY,'--');
         InternColorOrder = get(gca,'ColorOrder');
         set(LineHandles, 'Color', InternColorOrder(2,:));
         set(gca, 'NextPlot', StoreNextPlot);
      end
   end      

   % Default strings for 3 languages {english, german, another}
   PlotTitleDef = {PlotTitle,                           PlotTitle,                           ''};
   XLabelDef =    {sprintf('variable %d', IxBounds(1)), sprintf('Variable %d', IxBounds(1)), ''};
   if OneDim == 1,
      YLabelDef = {'objective value',                   'Zielfunktionswert',                 ''};
   else, 
      YLabelDef = {sprintf('variable %d', IxBounds(2)), sprintf('Variable %d', IxBounds(2)), sprintf('', IxBounds(2))};
   end
   ZLabelDef =    {'objective value',                   'Zielfunktionswert',                 ''};
   if     Lan == 'g', DefIx = 2;
   elseif Lan == 'a', DefIx = 3;
   else,              DefIx = 1; end
   if isempty(PlotTitle), PlotTitle = PlotTitleDef{DefIx}; end
   if isempty(XLabel),    XLabel    = XLabelDef{DefIx}; end
   if isempty(YLabel),    YLabel    = YLabelDef{DefIx}; end
   if isempty(ZLabel),    ZLabel    = ZLabelDef{DefIx}; end
      
   title(PlotTitle);
   xlabel(XLabel); ylabel(YLabel);
   if OneDim == 0, zlabel(ZLabel); end
   
   %    if     OneDim == 0, ylabel(sprintf('Variable %d', IxBounds(2)));
   %    elseif OneDim == 1, ylabel('Zielfunktionswert'); end
   %    if     OneDim == 0, zlabel('Zielfunktionswert'); end
   % elseif Lan == 'a',
   %    title('');
   %    xlabel('');
   %    if     OneDim == 0, ylabel(sprintf('', IxBounds(2)));
   %    elseif OneDim == 1, ylabel(''); end
   %    if     OneDim == 0, zlabel(''); end
   % else
   %    title(sprintf('%s', PlotTitle));
   %    xlabel(sprintf('variable %d', IxBounds(1)));
   %    if     OneDim == 0, ylabel(sprintf('variable %d', IxBounds(2)));
   %    elseif OneDim == 1, ylabel('objective value'); end
   %    if     OneDim == 0, zlabel('objective value'); end
   % end

   drawnow;


% End of function
