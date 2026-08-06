% OBJective function for DOuble Integrator
%
% This function implements the Double Integrator.
%
% Syntax:  ObjVal = objdopi(Chrom, method, TSTART, TEND)
%
% Input parameters:
%    Chrom     - Matrix containing the chromosomes of the current
%                population. Each row corresponds to one individual's
%                string representation.
%                if Chrom == [], then special values will be returned
%    method    - if Chrom == [] and
%                method == 1 (or []) return boundaries
%                method == 2 return title
%                method == 3 return value of global minimum
%                if Chrom ~[], method of simulation
%                 1 - sim: simulink model
%                 2 - ode: ordinary differential equations
%                 3 - con: transfer function to state space,
%                          uses Control Toolbox => outcommented (tf2ss, lsim)
%                12 - odv: ordinary differential equations vectorized
%                if method is omitted or empty 12 is assumed
%    TSTART    - (optional) start time, if omitted 0 is assumed
%    TEND      - (optional) end time, if omitted 1 is assumed
%
% Output parameters:
%    ObjVal    - Column vector containing the objective values of the
%                individuals in the current population.
%                if called with Chrom == [], then ObjVal contains
%                method == 1, matrix with the boundaries of the function
%                method == 2, text for the title of the graphic output
%                method == 3, value of global minimum
%    t         - time vector of last simulation
%    x         - matrix containing state values of last simulation
%                
% See also: simdopiv, simdopi1, initdopi, objharv, objlinq, objpush

% Author:   Hartmut Pohlheim
% History:  17.12.1994  file created
%           05.02.1995  trapz used
%           17.02.1995  additional parameters introduced and
%                       function cleaned
%           17.05.1995  vectorized version (method == 12) added
%           26.04.2004  some adjustements


function [ObjVal, t, x] = objdopi(Chrom, method, TSTART, TEND);

% initial conditions
   XINIT = [ 0; -1];

% end conditions
   XEND = [ 0; 0];

% weights for control and end conditions
   XENDWEIGHT = 3 * [1; 1];      % XEND(1); XEND(2)
   UWEIGHT = [1];                % Control vector
   
% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then
   if Nind == 0
      % Default dimension of objective function
      Dim = 20;
      % return text of title for graphic output
      if method == 2
         ObjVal = ['Double Integrator'];
         % if     method == 2, ObjVal = ['Double Integrator (ode)'];
         % elseif method == 3, ObjVal = ['Double Integrator (con)'];
         % elseif method ==12, ObjVal = ['Double Integrator (odv)'];
         % else                ObjVal = ['Double Integrator (sim)'];
         % end
      % return value of global minimum
      elseif method == 3
         ObjVal = 2; % UWEIGHT * 3 * (TEND - TSTART);
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([-10; 10], [1 Dim]);
      end
   % compute values of function
   else
      % Define used method
      if nargin < 2, method = [];           % 1 - sim: simulink model
      elseif isempty(method), method = 12;  % 2 - ode: ordinary differential equations
      else method = method;                 % 3 - con: transfer function to state space
      end                                   % 12- odv: ordinary differential equations vectorized         
      % Set default values, if not defined
      if nargin < 3, TSTART = []; end
      if isempty(TSTART), TSTART = 0; end
      if nargin < 4, TEND = []; end
      if isempty(TEND), TEND = 1; end

      % Compute stepsize and time vector
      STEPSIMU = min(0.1, abs((TEND - TSTART)/(Nvar - 1)));
      TIMEVEC = linspace(TSTART, TEND, Nvar)';
      % Start computation of objective function
      if method == 3,      % Convert transfer function to state space system
         % [Ai2 Bi2 Ci2 Di2] = tf2ss(1, [1 0 0]);   % remove comment for use 
         t = TIMEVEC;
      end
      ObjVal = zeros(Nind,1);
      if method == 12,
         NCONTR = 1;
         XINIT = repmat(XINIT', [Nind, 1]);
         [t, x] = intrk4('simdopiv', [TSTART, TEND], XINIT, ...
                          [1e-3, STEPSIMU, STEPSIMU, NCONTR], Chrom);
         poses = repmat(size(t, 1), [Nind, 1]); TimeSimall = expandm(t, [Nind, 1]);
         % [t, x(1:Nind:Nind*(size(t, 1)-1)+1,:)]

         ObjVal = (UWEIGHT / (Nvar - 1) * trapz((Chrom').^2)');
         ObjVal = ObjVal + sum(repmat(XENDWEIGHT, [1, Nind]) .* ...
                               abs( x(size(x, 1)-Nind+1:size(x, 1),:)' - repmat(XEND, [1, Nind])))';
      else
         for indrun = 1:Nind
            steuerung = [TIMEVEC [Chrom(indrun,:)]'];
            if method == 2,
               [t x] = rk23('simdopiv', [TSTART TEND], XINIT, ...
                            [1e-3; STEPSIMU; STEPSIMU], steuerung);
            elseif method == 3,      % remove comment for use
               % [y x] = lsim(Ai2, Bi2, Ci2, Di2, Chrom(indrun,:), TIMEVEC, XINIT);
            else 
               SimOpt = simset('OutputPoints', 'all', 'SrcWorkspace', 'current');
               OldW = warning; warning off
               [t, x] = sim('simdopi2', [TSTART TEND], SimOpt, steuerung);
               warning(OldW);
               % [t x] = ode23('simdopi2', [TSTART TEND], [], ...
               %              [1e-3; STEPSIMU; STEPSIMU], steuerung);
            end
            % Calculate objective function, endvalues, trapez-integration for control vector
            ObjVal(indrun) = sum(XENDWEIGHT .* abs( x(size(x, 1),:)' - XEND )) + ...
                             (UWEIGHT / (Nvar - 1) * trapz(Chrom(indrun,:).^2));
         end
      end
   end   


% End of function

