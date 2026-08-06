% OBJective function for the vehicle routing problem
%
% This function provides the objective function for Vehicle 
% routing problems (VRP). A number of examples are provided, 
% see vrpgetdata for the data definition of the problem 
% specific information.
% This function computes the length/cost of the routes given by the
% individuals. The variables of the individuals define the order
% of the points to travel for each of the used vehicles. 
% The format of the route coding in the individuals is described 
% in vrpconvind.
% Beside the maximum load time windows may also used.
%
% Syntax: ObjVal = objvrp(Routes, VRPData)
%
% Input parameter:
%    Routes   - Matrix containg the variables of the individuals 
%               (the points of the routes).
%               The exact format of the coding of the routes and multiple 
%               vehicles is described in vrpconvind (where the conversion 
%               from individuals to routes is done)
%    VRPData  - Structure containg problem specific data for the current VRP
%               or a string with name of VRP
%               see vrpgetdata for more info on names of VRPData elements 
%               and supported examples
%
% Output parameter:
%    ObjVal   - Matrix containing the objective values for the individuals
%               in Routes (length/cost of the routes).
%               elseif Routes == [NaN, NaN, xx], than see objfun1 for options
%
% See also: demovrp, plotvrp, vrpconvind, vrpgetdata, tbxperm, initpp, mutswap, mutexch, recgp, recpm

% Author:   Hartmut Pohlheim
% History:  28.05.2005  file created


function [ObjVal, VRPData, VRPResult] = objvrp(Routes, VRPData)

   NAIN = nargin; NAOUT = nargout;

   if NAIN < 1, Routes = []; end
   if isnan(Routes), Routes = []; end
   if isempty(Routes), Routes = [NaN, NaN, 1]; end
   
   if NAIN < 2, VRPData = []; end
   if isempty(VRPData), VRPData = 'vrpnc1'; end
   
   if ischar(VRPData), VRPData = vrpgetdata(VRPData); end
   
   % Check VRPData for structure, return if not a structure
   if ~(isstruct(VRPData)),
      warning(sprintf('Problem specific vehicle routing problem data are needed. Please provide them as input parameter to %s', mfilename));
      ObjVal = Inf * ones(size(Routes,1)); return;
   end
   
   % Number of customers (XYData - depot)
   NumCustomer = size(VRPData.XYData,1) - 1;
   % Dimension of objective function (number of customers + max number of vehicles)
   Dim = NumCustomer + VRPData.MaxVehicle;

   % create structure
   if isnan(Routes(1)),
      if all([isnan(Routes(2)), Routes(3) <= 10]),
         ObjVal = objfunoptset(...
             'FunctionName', sprintf('Vehicle Routing (%s)', VRPData.FunName), ...
             'VarBoundMin',   1, 'VarBoundMax', Dim, ...
             'NumVarDefault', Dim, 'NumVarMin', Dim, 'NumVarMax', Dim, ...
             'NumObjDefault', 1, 'NumObjMin',   1, 'NumObjMax', 1, ...
             'GlobalMinObjV', VRPData.BestCost);
      elseif Routes(3) == 11,
         NOBJUSE = Routes(4);
      end
   else
      % Get number of routes and their length
      [Nroutes, Lroute] = size(Routes);

      % Calculate the distance of each route
      dist = zeros(Nroutes, 1);
      VRPResult.RouteCost = {};
      for irout = 1:Nroutes,
         % Convert the individuals into routes (as needed by rteTC and pplot)
         rte = vrpconvind('ind2route', Routes(irout,:), VRPData);
         % Calculate the cost of the routes (and further data, when requested by i.e. plot function)
         if nargout > 1,
            [TC, XFlg, out] = rteTC(rte, VRPData.Dists, {VRPData.Demand, VRPData.MaxLoad}, {VRPData.LoadTime, VRPData.TimeWindow}, {'maxTCfeas', VRPData.MaxCost});
         else
            [TC] = rteTC(rte, VRPData.Dists, {VRPData.Demand, VRPData.MaxLoad}, {VRPData.LoadTime, VRPData.TimeWindow}, {'maxTCfeas', VRPData.MaxCost});
         end
         % Objective value is (currently) the sum of the cost of all routes
         % Here we might also use multiple objectives, but I am not sure, if this is really usefull
         ObjVal(irout,1) = sum(TC);
         % Put the route and the cost of each route into the result structure
         VRPResult.RouteOrder{irout,1} = rte;
         VRPResult.RouteCost{irout,1} = TC';
      end
      
   end
   

% End of function