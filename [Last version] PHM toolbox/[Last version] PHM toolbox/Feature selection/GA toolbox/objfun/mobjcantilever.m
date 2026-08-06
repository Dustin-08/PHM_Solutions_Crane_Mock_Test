% Objective function for multiobjective cantilever beam system
%
% This function implements the multiobjective cantilever beam 
% system minimizing deflection and weight. 
% A description can be found in:
% Deb, Kalyanmoy: Multi-Objective Optimization using Evolutionary
%                 Algorithms. pp. 19-22, .
% The constraints are included by the definition of Goals in the
% evolutionary algorithm ([Inf, 5, 300]).
%
% Syntax:  ObjVal = mobjcantilever(Chrom)
%
% Input parameter:
%    Chrom  - Matrix containing the individuals for calculation of the objective function
%                Chrom(:,1) - diameter [mm]
%                Chrom(:,2) - length [mm]
%             for parameter definition of the objective function see objfun1 and objfunoptset
%
% Output parameter:
%    ObjVal - Matrix containing the objective values, one row for each individual in Chrom
%                ObjVal(:,1) - weight [kg]      (just minimize)
%                ObjVal(:,2) - deflection [mm]  (minimize with goal 5)
%                ObjVal(:,3) - stress [Pa]      (minimize with goal 300)
%
% See also: democantilever, objfun1, objfunoptset, mobjfonseca2

% Author:   Hartmut Pohlheim
% History:  19.08.2004  file created including full description
%           08.05.2005  documentation extended (inputs, outputs, possible solutions)
%           26.01.2006  added MObjGoals in function definition


function ObjVal = mobjcantilever(Chrom);

   if nargin < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   ObjVal = [];

   GoalDefault = [Inf, 5, 300];
   
   % Create option-structure
   if isnan(Chrom(1,1)), 
      if isnan(Chrom(1,2)),
         if Chrom(1,3) <= 10,
           ObjVal = objfunoptset( 'FunctionName', 'CANTILEVER BEAM MO-Function' ...
                                , 'VarBoundMin', [10 200], 'VarBoundMax', [50 1000]...
                                , 'NumVarDefault', 2, 'NumVarMin', 2, 'NumVarMax', 2 ...
                                , 'NumObjDefault', 3, 'NumObjMin', 3, 'NumObjMax', 3 ...
                                , 'MObjGoals', GoalDefault ...
                                );
         end
      end

   % Calculate objective values
   else
      % Description of the cantilever beam system
      % Chrom(:,1) = diameter [mm]
      % Chrom(:,2) = length [mm]
      % Parameters (constant)  Pa = N/m^2
      rho = 7800;        % [kg/m3]
      P = 1e3;           % [N]
      E = 207e9;         % [Pa]
      Sy = 300e6;        % [Pa]
      delta_max = 0.05;  % [m]

      % Calculate objective values for each objective
      % weight [kg]: 1e-9 to convert m^-3 to mm^-3
      % kg * m^-3 * mm^2 * mm
      Weight = 1e-9*0.25*rho*pi*Chrom(:,1).^2.*Chrom(:,2);
      % deflection [mm]: 1e6 to convert Pa (N/m^2) to N/mm^2
      % N * m^2 *mm^3 / (N * mm^4)
      Deflection = 1e6*64*P*Chrom(:,2).^3./(3*E*pi.*Chrom(:,1).^4);
      % stress [Pa]: 1e6 to convert from N/mm^2 to N/m^2 and 1e-6 to convert Pa tp MPa
      % N * mm / mm^3
      Stress = 32 * P * Chrom(:,2) ./ (pi * Chrom(:,1).^3);
      
      ObjVal = [Weight, Deflection, Stress];
   end


% End of function
