% Create search space visualizations of objective functions
%
% This function defines parameters of standard objective function
% for creating 3-D surf/mesh plots. 
% In a loop the function for creation and plot of the graphics is
% called (plotmesh). Then the created graphics are saved to a defined
% graphics format using print.
% This enables quick creation of a large number of similar plots 
% without to much interaction. For instance, create one set of graphics
% in black and white, create the next in color eps and the third in 
% color tiff (for conversion to gif for the WWW).
%
% See also: plotmesh

%  Author:  Hartmut Pohlheim
%  History: 11.04.1997  file created
%           09.10.1997  changes for more flexibilty in print format
%           10.10.1997  use cell arrays for storing parameters
%                       use a loop for plotting and meshing, much better handling
%           23.02.1998  use of cell arrays for streamlined function
%           05.03.2005  added more objective functions and more specific regions
%           08.05.2005  input parameter NumGraphics added for definition of needed 
%                       grafics from command line


function graf_msh(NumGraphics)

   if nargin < 1, NumGraphics = []; end
   if isempty(NumGraphics), NumGraphics = []; end
   
   ResPathMesh = 'grafics\grafics_mesh\msh_';
   % ResPathMesh = 'msh_';
   % PrintStyle = {'tiff -r80'};
   PrintStyle = {'tiff -r80', 'jpeg80 -r80', 'png -r80'};   % 'epsc2 -tiff -painters', 
   PrintExt = '';
   % PrintExt = '-tiff';
   Lan = '_en';
   FileSuffix = [Lan '_c'];   % '_sw', '_c';

   % Standard Points and values of minimum
   PStd1 = [ 40, 40];
   PStd2 = [ 0, 0];
   PStd  = [ PStd1; PStd2];
   
   idat = 1; PF = {};
   % De Jong's function 1
   PFi = [{'objfun1'},  {[-500;500]},  {PStd}, {'f1_500'}]; PF = [PF; PFi];
   PFi = [{'objfun1'},  {[ -10; 10]},  {PStd}, {'f1_10'}]; PF = [PF; PFi];
   
   % function 1a
   PFi = [{'objfun1a'}, {[-5;5]}, {PStd}, {'f1a_5'}]; PF = [PF; PFi];
   PFi = [{'objfun1a'}, {[-5;5]}, {[PStd; -1, 10]}, {'f1a_5_10'}]; PF = [PF; PFi];

   % function 1b
   PFi = [{'objfun1b'}, {[-50;50]}, {PStd}, {'f1b_50'}]; PF = [PF; PFi]; 
   PFi = [{'objfun1b'}, {[-50;50]}, {[PStd; -10, 1000]}, {'f1b_50_1000'}]; PF = [PF; PFi]; 

   % Pohlheims function 1c
   PFi = [{'objfun1c'}, {[-500;500]}, {[PStd1; 5, 10; -10, NaN]}, {'f1c_500'}]; PF = [PF; PFi]; 
   PFi = [{'objfun1c'}, {[-500 10 15 -500;500 10 15 500]}, {[PStd1; 5, 20; -10, NaN]}, {'f1c_v14_500'}]; PF = [PF; PFi]; 
   PFi = [{'objfun1c'}, {[-20 10 15 -5;30 10 15 45]},     {[PStd1; 5, 20; -10, 1000]}, {'f1c_v14_50_1000'}]; PF = [PF; PFi]; 

   % Rosenbrock's function
   PFi = [{'objfun2'},  {[  -2; 2]},   {[PStd1; 1, 1; -40, NaN]}, {'f2_2'}]; PF = [PF; PFi]; 
   PFi = [{'objfun2'},  {[  -2; 2]},   {[PStd1; 1, 1; -40, 100]}, {'f2_2_100'}]; PF = [PF; PFi]; 
   PFi = [{'objfun2'},  {[ 0.5;1.5]},  {[PStd1; 1, 1; -4, NaN]}, {'f2_0_5_1_5'}]; PF = [PF; PFi]; 
   PFi = [{'objfun2'},  {[ 0.5;1.5]},  {[PStd1; 1, 1; -2, 5]}, {'f2_0_5_1_5_5'}]; PF = [PF; PFi]; 

   % Rastrigin's function
   PFi = [{'objfun6'}, {[-100; 100]}, {[PStd; -5000, NaN]}, {'f6_100'}]; PF = [PF; PFi];
   PFi = [{'objfun6'}, {[  -5;   5]}, {[101, 101; PStd2; -20,   NaN]}, {'f6_5'}];   PF = [PF; PFi];
   PFi = [{'objfun6'}, {[  -1;   1]}, {[PStd; -10,   NaN]}, {'f6_1'}];   PF = [PF; PFi];
   PFi = [{'objfun6'}, {[ -.5;  .5]}, {[PStd;  -2,   NaN]}, {'f6_0_5'}]; PF = [PF; PFi];

   % Schwefel's function
   PFi = [{'objfun7'}, {[-500;500]},  {[PStd1; 420.9, 420.9]}, {'f7_500'}]; PF = [PF; PFi];
   PFi = [{'objfun7'}, {[-500;-300]}, {[PStd1; 420.9, 420.9]}, {'f7_500_350'}]; PF = [PF; PFi];
   PFi = [{'objfun7'}, {[-500;   0]}, {[PStd1; 420.9, 420.9]}, {'f7_500_0'}]; PF = [PF; PFi];
   PFi = [{'objfun7'}, {[ 300; 500]}, {[PStd1; 420.9, 420.9]}, {'f7_300_500'}]; PF = [PF; PFi];
   PFi = [{'objfun7'}, {[ 000; 500]}, {[PStd1; 420.9, 420.9]}, {'f7_0_500'}]; PF = [PF; PFi];

   % Griewangk's function
   PFi = [{'objfun8'}, {[-500;500]}, {PStd}, {'f8_500'}]; PF = [PF; PFi];
   PFi = [{'objfun8'}, {[ -50; 50]}, {[101, 101; PStd2]}, {'f8_50'} ]; PF = [PF; PFi];
   PFi = [{'objfun8'}, {[  -8;  8]}, {[60, 60; PStd2]}, {'f8_8'}  ]; PF = [PF; PFi];

   % Sum of different power
   PFi = [{'objfun9'}, {[ -1; 1]}, {[PStd]}, {'f9_1'}]; PF = [PF; PFi];

   % Ackley's path
   PFi = [{'objfun10'}, {[ -30; 30]}, {[101, 101; PStd2]}, {'f10_30'}]; PF = [PF; PFi];
   PFi = [{'objfun10'}, {[  -2;  2]}, {[101, 101; PStd2]}, {'f10_2'} ]; PF = [PF; PFi];

   % Langermann's function
   PFi = [{'objfun11'}, {[   0; 10]},       {[100, 100]}, {'f11_v12_0_10'}]; PF = [PF; PFi];
   PFi = [{'objfun11'}, {[0 0 0; 0 10 10]}, {[100, 100]}, {'f11_v23_0_10'}]; PF = [PF; PFi];
   PFi = [{'objfun11'}, {[0 7 0; 0 10 3]},  {[100, 100]}, {'f11_v23_7_10'}]; PF = [PF; PFi];

   % Michalewicz's function
   PFi = [{'objfun12'}, {[   0;  3]},        {[100, 100]}, {'f12_0_3'}    ]; PF = [PF; PFi];
   PFi = [{'objfun12'}, {[1.5,1;2.5,2]},     {[PStd1]}, {'f12_1_2'}    ]; PF = [PF; PFi];
   PFi = [{'objfun12'}, {[0 0 0 0;0 0 3 3]}, {[100, 100]}, {'f12_v34_0_3'}]; PF = [PF; PFi];

   % Branin's function
   PFi = [{'objbran'}, {[-5,0;10,15]}, {[60, 60; -100, NaN]}, {'bran_0_10'}]; PF = [PF; PFi];
   PFi = [{'objbran'}, {[-5,0;10,15]}, {[60, 60; NaN, NaN; -10, 30]}, {'bran_0_10_30'}]; PF = [PF; PFi];

   % Easom's function
   PFi = [{'objeaso'}, {[ -20; 20]}, {[100, 100; pi, pi]}, {'easo_20'} ]; PF = [PF; PFi];
   PFi = [{'objeaso'}, {[   1;  5]}, {[100, 100; pi, pi; NaN, 0.1]}, {'easo_1_5'}]; PF = [PF; PFi];

   % Goldstein/Price's function
   PFi = [{'objgold'}, {[ -3; 3]}, {[PStd1; 0, -1; -1e5, NaN]}, {'gold_3'}]; PF = [PF; PFi];
   PFi = [{'objgold'}, {[ -3; 3]}, {[PStd1; 0, -1; -100, 1000]},  {'gold_3_1000'}]; PF = [PF; PFi];
   PFi = [{'objgold'}, {[ -2, -2; 2, 0]}, {[100, 100; 0, -1; -100, 1000]},  {'gold_2_1000'}]; PF = [PF; PFi];

   % six hump camelback function
   PFi = [{'objsixh'}, {[-2,-1.5; 2,1.5]}, {[PStd1]}, {'sixh_2_1_5'}]; PF = [PF; PFi];
   PFi = [{'objsixh'}, {[-2,-1.1; 2,1.1]}, {[PStd1; NaN, NaN]}, {'sixh_2_1_1'}]; PF = [PF; PFi];
   PFi = [{'objsixh'}, {[-2,-1.1; 2,1.1]}, {[PStd1; NaN, NaN; -1, 3]}, {'sixh_2_1_1_3'}]; PF = [PF; PFi];

   % Four Wings function
   PFi = [{'obj4wings'}, {[-50;50]}, {[101, 101; PStd2]}, {'4wings_c_50'}]; PF = [PF; PFi];
   PFi = [{'obj4wings'}, {[-50;50]}, {[101, 101; PStd2; 0, 4]}, {'4wings_c_50_4'}]; PF = [PF; PFi];

   % Fractal Mandelbrot function
   PFi = [{'objfractal'}, {[-500;500]}, {[101, 101; PStd2]}, {'fractal_c_500'}]; PF = [PF; PFi];
   PFi = [{'objfractal'}, {[ -50; 50]}, {[101, 101; PStd2]}, {'fractal_c_50'}]; PF = [PF; PFi];

   % FLETcher and PoWELL function
   PFi = [{'objfletwell'}, {[-500;500]}, {[101, 101; PStd2]}, {'fletwell_c_500'}]; PF = [PF; PFi];
   PFi = [{'objfletwell'}, {[-500;500]}, {[101, 101; PStd2; -100, 5000]}, {'fletwell_c_500_1000'}]; PF = [PF; PFi];

   % Ridge function
   PFi = [{'objridge'}, {[-50;50]}, {[101, 101; PStd2; -5, 60]}, {'ridge_d_50'}]; PF = [PF; PFi];
   PFi = [{'objridge'}, {[-50;50]}, {[101, 101; PStd2; -3, 20]}, {'ridge_d_50_20'}]; PF = [PF; PFi];

   % SOLAND function
   % PFi = [{'mobjsoland'}, {[0,0;2,3]}, {PStd1}, {'solandm_2_3'}]; PF = [PF; PFi];


   if isempty(NumGraphics), NumGraphics = [1:size(PF, 1)]; end
   for imesh = NumGraphics,
   %  for imesh = 1:size(PF, 1),
      % PF{imesh,1}, PF{imesh,2}, PF{imesh,3}
      plotmesh(PF{imesh,1}, PF{imesh,2}, PF{imesh,3}); 
      for iprint = 1:length(PrintStyle),
         eval(['print ' ' -d' PrintStyle{iprint} ' ' PrintExt ' ',  ResPathMesh, PF{imesh,4} FileSuffix ';'])
         fprintf(1, '%2d: Grafic saved as  %s%s%s  in  %s\n', imesh, ResPathMesh, PF{imesh,4}, FileSuffix, PrintStyle{iprint});
      end
   end
   
   

% End of function


