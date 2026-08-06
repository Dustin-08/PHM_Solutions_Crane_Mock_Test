% OBJective function for lateral AUTO controller system 2
%
% This function implements the lateral controll system.
%
% Syntax:  [ObjVal, t, y, ModAll] = objauto2(Chrom, option, Speed, IniOffset)
%
% Input parameters:
%    Chrom     - Matrix containing the chromosomes of the current
%                population. Each row corresponds to one individual's
%                string representation.
%                if Chrom == [NaN xxx], then special values will be returned
%                   xxx == 1 (or []) return boundaries
%                   xxx == 2 return title
%                   xxx == 3 return value of global minimum
%    option    - (optional) Scalar indicating controller and simulation method to use 
%    Speed     - (optional) Scalar indicating  v (speed [m/s])
%    IniOffset - (optional) Scalar indicating StateInit(2) - initial lane offset
%
% Output parameters:
%    ObjVal    - (Column) Matrix containing the objective values of the
%                individuals in the given population Chrom.
%                if called with Chrom == [NaN xxx], then ObjVal contains
%                xxx == 1 (or []), matrix with the boundaries of the function
%                xxx == 2, text for the title of the graphic output
%                xxx == 3, value of global minimum

% Author:   Hartmut Pohlheim
% History:  06.05.99    file created
%           10.05.99    additional outputs added
%                       direct calculation of transfer function added


function [ObjVal, t, y, ModAll] = objauto2(Chrom, option, Speed, IniOffset, Noise),


% global Acon Bcon Ccon Dcon Adis Bdis Cdis Ddis NumContr DenContr STATEInit TIMEdis
  
   NAIN = nargin; NAOUT = nargout;

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check input parameter
   if NAIN < 2, option = []; end
   if isnan(option), option = []; end
   if isempty(option), option = 1; end
   
% Check contents of Chrom and do the appropriate thing

   % if Chrom is [], then reset to new parameter getting method
   if isempty(Chrom), warning('use new calling syntax for boundary getting'); Chrom = [NaN, option]; end

   % Return the appropriate values
   if all([Nind == 1, isnan(Chrom(1))]),
      % If only NaN is provided, use RetTask = 1
      if length(Chrom) > 1, RetTask = Chrom(2); else RetTask = 1; end
      % return text of title for graphic output
      if RetTask == 2
         FunTitle = {'Lateral Auto Control 1', 'Lateral Auto Control 2', 'Lateral Auto Control 3'}
         ObjVal = FunTitle{option};
      % return value of global minimum
      elseif RetTask == 3
         ObjVal = 0;
      % define size of boundary-matrix and values
      else   
         % lower and upper bound for all variables
         if option == 1,
            ObjVal = [ -1.0, -2.0, -1.0e-1,  -10.0,  -10.0;
                        2.0,  1.0,  1.0e-1,  200.0,  300.0];
         elseif option == 11,
            ObjVal = [ -2.0, -2.0, -1.0e-1, -10.0, -10.0,  -10.0;
                        1.0,  1.0,  1.0e-1, 100.0, 300.0,  400.0];
         elseif option == 12,
            ObjVal = [    0,    0,    0,    0   ,   0  ,   0  ,    0  ;
                        1.0,  2.0,  1.0,  1.0e-1, 100.0, 300.0,  400.0];
         elseif option == 2,
            ObjVal = [ -1.0, -1.0, -1.0, -1.0, -1.0;
                        1.0,  1.0,  1.0,  1.0,  1.0];
         elseif option == 3,
            ObjVal = [ -1.0, -1.0e-1, -5.0e-1, -2.0, -1.0;
                        1.0,  1.0e-1,  5.0e-1,  0.0,  1.0];
         end
      end

   % compute values of objective function
   else

      % Default parameters
      % yc: border, kritische Abweichung; v: speed, Geschwindigkeit, fuer die linearisiert wurde
      yc = 0.5; v = 20;
      % vehicle mass in kg, wheel base in m (meter), lateral friction in kN/rad
      m = 5800; a = 4.25; k = 150;

      STATEInit = [0, 1.0, 0, 0];
      TIMEdis = 0.05; TIMEsim = 10;
      NoiseVariance = 0.001;
   
      % method of model and simulation
      % 1: continuous system, polynomial controller (5 parameters); old: PID (3)
      % 2: discrete system, polynomial controller (5 parameters)
      % 3: as method 2, but coupled parameters 1-3
      if ~(any(option == [1:3, 11, 12])), option = 1; end
         
      % Check additional parameters
      if NAIN > 2, if ~(isempty(Speed)), v = Speed; end, end     
      if NAIN > 3, if ~(isempty(IniOffset)), STATEInit(2) = IniOffset; end, end
      if STATEInit(2) > 0, OVER = 1; else OVER = -1; end
      if NAIN > 4, if ~(isempty(Noise)), NoiseVariance = Noise; end, end

      % system description (numbers for v = 20)
      Acon = [-2*k/(m*v), 0, 0, v/a-k/(m*v); v, 0, v, 0; 0, 0, 0, v/a; 0, 0, 0, 0];
      % Acon = [-.002586, 0, 0, 4.7046; 20, 0, 20, 0; 0, 0, 0, 4.7059; 0, 0, 0, 0];
      Bcon = [0; 0; 0; 1]; Ccon = [0, 1, 0, 0]; Dcon = [0];
      % assignin('base', 'Acon', Acon); assignin('base', 'Bcon', Bcon); assignin('base', 'Ccon', Ccon); assignin('base', 'Dcon', Dcon);

      % Calculate transfer function directly
      a1 = 2*k/(m*v); a2 = v/a; a3 = v; F1 = a3*(2*a2-(a1/2));
      ModconTF = tf([F1, F1*(2*a1*a2/(4*a2-a1))], [1, a1, 0, 0, 0]);
      % figure(3)
      % pzmap(ModconTF);
      % roots([1, a1, 0, 0, 0])
      % or by matlab: model of continuous system
         % [Nums, Dens] = ss2tf(Acon, Bcon, Ccon, Dcon);
      % minimal realization with tolerance
         % ZeroIx = find(abs(Nums) <= 1e-8); if ~(isempty(ZeroIx)), Nums(ZeroIx) = 0; end
         % ZeroIx = find(abs(Dens) <= 1e-8); if ~(isempty(ZeroIx)), Dens(ZeroIx) = 0; end
         % ModconTF = tf(Nums, Dens)   % sprintf('Nums: %s    Dens: %s', prprintf(Nums), prprintf(Dens))
         % Nums = [0, 0.0, 0.0, 188.21, 2.43407]; Dens = [1, 0.002586, 0, 0, 0];
      if any(option == [1, 11, 12]),
         SIM_F = 'simautoc1';
      elseif any(option == [2, 3]),
         SIM_F = 'simautod1';
         % model of discrete system,  
         ModdisTF = c2d(ModconTF, TIMEdis, 'foh');
         [Numdis, Dendis] = tfdata(ModdisTF, 'v');
         [Adis, Bdis, Cdis, Ddis] = tf2ss(Numdis, Dendis);
         % figure(2); pzmap(ModdisTF);
      end

      ObjVal = zeros(Nind, 6);
      for i = 1:Nind,
         % Get the control parameters from the phenotype
         ControlPara = Chrom(i,:);
         % Closed loop stability test
         if any(option == [1, 11, 12]),
            if option == 1,  ModControlTF = tf(ControlPara(1:3), [1 ControlPara(4:5)]); end
            if option == 11, ModControlTF = tf([0 ControlPara(1:3)], [1 ControlPara(4:6)]); end
            if option == 12, ModControlTF = tf([ControlPara(1:4)], [1 ControlPara(5:7)]); end
            ModClosed = feedback(ModconTF, ModControlTF);
            [NumClosed, DenClosed] = tfdata(ModClosed, 'v');
            % [Num_s Den_s] = series(Numc,Denc,Nums,Dens);
            % [Numcl Dencl] = cloop(Num_s,Den_s,-1);
            % figure(3); pzmap(ModClosed)
            valroots = real(roots(DenClosed));   % continuous system
            if max(valroots) < 0,
               Stable = 1;
               distinstbl = (max(valroots) > -0.05) * (max(valroots) + 0.05);
            else Stable = 0; distinstbl = 0; end
         elseif any(option == [2, 3]),
            % Couple parameters
            if option == 3, ControlPara(2) = ControlPara(2) - 2*ControlPara(1); ControlPara(3) = ControlPara(3) + ControlPara(1); end

            ModControlTF = tf(ControlPara(1:3), [1 ControlPara(4:5)], TIMEdis)
            ModClosed = feedback(ModdisTF, ModControlTF)
            [NumClosed, DenClosed] = tfdata(ModClosed, 'v');
            
            % Closed loop stability test
            % [Num_s Den_s] = series(Numc,Denc,Nums,Dens);
            % [Numcl Dencl] = cloop(Num_s,Den_s,-1);
            % figure(3); pzmap(ModClosed)
            valroots = abs((roots(DenClosed)))   % discrete system
            if max(valroots) < 1,
               Stable = 1;
               distinstbl = (max(valroots) > 0.95) * (max(valroots) - 0.95);
            else Stable = 0; distinstbl = 0; end
            % Stable = 1;
         end

         % if the system is unstable assign a very large objective function value
         if Stable == 0,      % System is unstable
            ObjVal(i,1) = max(valroots)*1.0e10 + 1.0e7;
            T = NaN; yout = NaN; uout = NaN;

         % if the system is stable let the simulation run.
         else
            % System is stable, Start simulation
            [NumContr, DenContr] = tfdata(ModControlTF, 'v');
            SimOpt = simset('OutputPoints', 'all', 'SrcWorkspace', 'current');
            OldW = warning; warning off
            [T, X, YandU] = sim(SIM_F, [0 TIMEsim], SimOpt);
            warning(OldW);

            % Get control u and output y
            yout = YandU(:, 1); uout = YandU(:, 2);

            % Calculate the single objectives
            sumyoutyc = trapz(T, (yout./yc).^6);
            
            sumuoutv = 6.25e2 * trapz(T, (uout.*v).^2);
            
            posover = find((OVER*yout)<0);
            sumyoutover = 5.0e3 * trapz(T(posover), yout(posover).^2);
            if isempty(sumyoutover), sumyoutover = 0; end
            
            posnot0 = ceil(3*size(yout,1)/5):size(yout,1);
            sumyoutnot0 = 1.0e5 * trapz(T(posnot0), yout(posnot0).^2);

            if isempty(distinstbl), sumdistinstbl = 0;
            else sumdistinstbl = 1.0e2 * distinstbl ^ 0.4; end

            ObjVal(i,1) = (sumyoutyc + sumuoutv + sumyoutover + sumyoutnot0) + sumdistinstbl;
            ObjVal(i,2) = sumyoutyc;
            ObjVal(i,3) = sumuoutv;
            ObjVal(i,4) = sumyoutover;
            ObjVal(i,5) = sumyoutnot0;
            ObjVal(i,6) = sumdistinstbl;
         end;

      end;     % of for i=1:Nind

      if NAOUT > 1, t = T; end
      if NAOUT > 2, y = [yout, uout]; end
      if NAOUT > 3, ModAll = ModClosed; end

   end


% End of function
