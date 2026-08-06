% OBJective function as combination of 3 standard obj. functions
%
% This function implements an artificial multi-objective function created
% from three standard objective functions. Only a limited number of the 
% variables contribute to each objective value.
% The function was created to check the utility of a special mechanism 
% inside the GEATbx to handle variables for each objective value 
% separately.
%
% Pareto Properties:
% ??? e.g. Ptrue connected, PFtrue connected and concave ???
%
% Syntax:  ObjV = objfun168(Chrom)
%
% For Input and Output parameters see objfun1.
%                
% See also: objfun1c, objfun6, objfun8

% Author:   Hartmut Pohlheim
% History:  04.10.2002  file created with objfunoptset calling syntax
%                          used for testing of special Var2ObjV/BB stuff


function ObjV = objfun168(Chrom);

   if nargin < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   ObjV = [];
   variant = 0;
   
   % Create option-structure
   if isnan(Chrom(1,1)), 
      if isnan(Chrom(1,2)),
         if Chrom(1,3) <= 10,
            if variant == 0, FunName = 'Combined Function 1, 1c, 6, 1a'; 
            else             FunName = 'Combined Function MOFonseca2, 1, 1c'; end
            ObjV = objfunoptset( 'FunctionName', FunName ...
                               , 'VarBoundMin',  -40, 'VarBoundMax', 50 ...
                               , 'NumVarDefault', 14, 'NumVarMin', 4, 'NumVarMax', Inf ...
                               , 'NumObjDefault',  3, 'NumObjMin', 3, 'NumObjMax', 4 ...
                               , 'GlobalMinVar',   0, 'GlobalMinObjV', 0 ...
                               );
         % Return Var2ObjV
         elseif Chrom(1,3) == 21,
            NumVarUse = [];
            if length(Chrom(1,:)) > 3, NumVarUse = Chrom(1,4); end
            if isempty(NumVarUse), NumVarUse = 10; end
            % Assignment of variables to objective values
            ObjV = CreateVar2ObjV(NumVarUse, variant);
         end
      end


   % compute values of function
   else
      % Get the size of the population, number of variables is important
      [Nind, Nvar] = size(Chrom);
      % Get the Var2ObjV association
      [Var2ObjV, ObjV2Var] = CreateVar2ObjV(Nvar, variant);
      ObjV = repmat(Inf, [size(Chrom,1), size(ObjV2Var,1)]);
      % function 1c/6/8, 
      % n = Nvar, -100 <= xi <= 100
      % global minimum at (xi) = (???) ; fmin = 0
      if variant == 0,
         ObjFun2Use = {'objfun1', 'objfun1c', 'objfun6', 'objfun1a'};
         for ifun = 1:size(ObjV2Var,1),
            % Chrom(:,[ObjV2Var{ifun,2}])
            % ObjV2Var{ifun,1}
            % ObjV2Var{ifun,2}
            % ObjFun2Use{ifun}
            % Chrom(:,[ObjV2Var{ifun,2}])
            % feval(ObjFun2Use{ifun}, Chrom(:,[ObjV2Var{ifun,2}]))
            ObjV(:,ObjV2Var{ifun,1}) = feval(ObjFun2Use{ifun}, Chrom(:,[ObjV2Var{ifun,2}]));
            % ObjV = [ObjV, feval(ObjFun2Use{ifun}, Chrom(:,[Var2ObjV{ifun,1}]))];
         end
      % else
      %    ObjV(:,[1 2]) = mobjfonseca2(Chrom(:,[Var2ObjV{1,1}, Var2ObjV{2,1}])/50);
      %    ObjV(:,[3  ]) = objfun1(Chrom(:,[Var2ObjV{3,1}]));
      %    ObjV(:,[4  ]) = objfun1c(Chrom(:,[Var2ObjV{4,1}]));
      end
      
   end   


% End of function



% private sub function for creation of Var2ObjV
%
% Use this template to define the assignment between the variables
% and the objective values.
% A cell array is used to define the values.
% The first column contains groups of variables, which together
% contribute to the same group of objective values. The associated 
% objective values are defined in the second column. The third 
% column contains a textual description of the variable group
% (can be used later for naming this enzymn), but is optional.
% 
% This Var2ObjV feature is still experimental.
%
% Examples:
% % The variables 1, 2 and 4 contribute only to objective value 1;
% % the variables 3 and 5 to objective values 2 and 3 and
% % the variables 6 and 7 to objective values 1 and 2.
% >> Var2ObjV = { [1 2 4], [1] ...
%               ; [3 5],   [2 3] ...
%               ; [6 7],   [1 2] ... 
%               };
%
% The Var2ObjV array is used inside geamain2. An example
% is given in demofunbb, where you see how to set this array
% into the GEA options structure.

function  [Var2ObjV, ObjV2Var] = CreateVar2ObjV(NumVarUse, variant)

   IxBorder = [floor(NumVarUse/4), floor(NumVarUse/2), floor(3*NumVarUse/4)];
   Var2ObjV = { [1:1:IxBorder(1)],             [1 ], 'Base-simple' ...
              ; [IxBorder(1)+1:1:IxBorder(2)], [2 ], 'Extend-1sthalf' ...
              ; [IxBorder(2)+1:1:IxBorder(3)], [3 ], 'Bonus-2ndhalf' ...
              ; [IxBorder(3)+1:1:NumVarUse],   [4 ], 'Prima-last' ...
              };

              % 1  2  3  4  5  6  7  8  9  10  11  12  13  14  15; ...
   % MainData = [ 1  2  3  4  5  6  7  8  9  10  11  12  13  14  15; ...
                
   %            Var    ObjV
   Var2ObjV1 = { [1:5],   [1 2] ...
               ; [6:10],  [2 3] ...
               ; [11:14], [3] ...
               ... % ; [15:19], [4] ...
               };
   %            Var    ObjV
   Var2ObjV2 = { [1:3],   [1] ...
               ; [4:5],   [1 2] ...
               ; [6:8],   [2] ...
               ; [9:10],  [2 3] ...
               ; [11:14], [3] ...
               ... % ; [15:19], [4] ...
               };

   %            Var    ObjV
   Var2ObjV3 = { [1:3],   [1] ...
               ; [4:5],   [1 2] ...
               ; [6:10],   [2] ...
               ... % ; [9:10],  [2 3] ...
               ... % ; [11:14], [3] ...
               ... % ; [15:19], [4] ...
               };

   Var2ObjV = Var2ObjV3;
   
   % strong coupling
   %             ObjV     Var
   ObjV2Var1 = { [1 2],   [1:10] ...
               ; [3],     [5:14] ...
               ... % ; [4],     [10:19] ...
               };

   % soft coupling
   %             ObjV     Var
   ObjV2Var2 = { [1],     [1:5] ...
               ; [2],     [4:10] ...
               ; [3],     [9:14] ...
               ... % ; [4],     [12:19] ...
               };

   % soft coupling
   %             ObjV     Var
   ObjV2Var3 = { [1],     [1:5] ...
               ; [2],     [4:10] ...
               ... % ; [3],     [9:14] ...
               ... % ; [4],     [12:19] ...
               };
   
   ObjV2Var = ObjV2Var3;
   
   % For the mobjfonseca case we use a MO function for the first 2 objectives
   % Change the Var2ObjV accordingly
   % if variant ~= 0, Var2ObjV(1,2) = {[1 2]}; Var2ObjV(2,2) = {[1 2]}; end

% End of sub function