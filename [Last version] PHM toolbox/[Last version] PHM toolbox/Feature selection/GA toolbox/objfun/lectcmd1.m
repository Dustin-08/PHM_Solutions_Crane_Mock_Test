% CoMmanDs for LECTure for live introduction of EA optimization
%
% Collection opf ready made commands for the lecture on EA optimization 
% (mostly held at the Technical University of Ilmenau).
% Each of the commands serves a special purpose during the lecture. 
% Explanations are given in the source code below.
%
% Syntax:  Result = lectcmd1(Cmd, varargin)
%
% Input parameters:
%    Cmd      - String containg the command 
%
% Output parameters:
%    mostly text nicely formatted or a graphic on the screen
%
% Examples:
%
% % Mesh plot of objlive1 function with 2 dimensions
% >> lectcmd1('meshlive1')
%               
% % Mesh plot of objlive1 function with 1 dimensions
% >> lectcmd1('meshlive1d')
%
% % Table of objlive1 function with 1 and 2 dimensions
% >> lectcmd1('tablelive1d')
%
% % Optimization of objlive1 directly using demogeatbx with 2 or 10 variables
% >> demogatbx(13,1)
% >> demogatbx(14,1)
%
% % online simulation of objfun7 [-500 500] in 1, 2 or more 
% % dimensions with nicely formatted tabular output
% % works identical with objlive1 and more to come
% >> lectcmd1('simfun7',[5 -10; -40 80; -400 500; -500 -400])
% >> lectcmd1('simlive1',[-20; 10; -4; 15; 17; 24; 32])
% >> lectcmd1('simlive1',[-20 -10; 10 5; -4 10; 15 25; 17 -20; 12 24; 32 15])
%
% % Visualize the recombination or mutation of real values
% % produces a plot of a number of offspring produced from 2/1 parents
% % number of offspring can be defined by the second parameter (default 150)
% % supported recombination operators: recdis, recint, reclin, reclinex
% >> lectcmd1('recdis', 2)
% >> lectcmd1('recdis')
% >> lectcmd1('recint')
% >> lectcmd1('reclin', 124)
% >> lectcmd1('reclinex')
% % supported mutation operators: mutreal, mutint, mutrandreal, mutrandint
% >> lectcmd1('mutreal')
% >> lectcmd1('mutint', 12)
%
% % Visualize distribution of ranking/selection
% % first parameter (AddPara) can define selective pressure and ranking method
% % supported selection functions: selrws, selsus, seltour, seltrunc
% >> lectcmd1('selsus');
% >> lectcmd1('selrws', [3,1]);
% >> lectcmd1('seltour', 1.7);
% >> lectcmd1('seltrunc', 1.3);
% >> lectcmd1('seltrunc', [2.9, 1]);
%
% See also: objlive1, objfun7, plotmesh, recdis, recint, reclin, reclinex, mutreal, mutint, mutrandreal, mutrandint

% Author:   Hartmut Pohlheim
% History:  11.01.2003  file created
%           05.01.2004  added command tablelive1
%                       change to switch/case and check for unknown option
%                       extended comment at the top
%                       added the recombination visualization
%           06.12.2004  animated mutation and recombination graphics in one 
%                       implementation
%           29.05.2005  comments and help section extended
%           05.06.2005  randomization of rec/mut data points added


function [Result, Data] = lectcmd(Cmd, varargin);

   if nargin < 1, Cmd = ''; end
   if isempty(Cmd), Cmd = 'meshlive1'; end
   
   if nargin < 2, AddPara = {}; else AddPara = varargin; end
   if length(AddPara) == 1, AddPara = AddPara{1}; end
   
   Result = [];

   switch lower(Cmd),
      case {'simlive1', 'simfun7'},
         if iscell(AddPara), SimChrom = AddPara{1}; else SimChrom = AddPara; end 
         ObjVal = feval(['obj' Cmd(4:end)], SimChrom);
         % ObjVal = objlive1(SimChrom);
         Result = sprintf('\n');
         for ilive1 = 1:size(SimChrom,2),
            Result = [Result, sprintf('   %s\n', prprintf('%8.4g', SimChrom(:, ilive1)))];
         end
         Result = [Result, sprintf('\n   %s', prprintf('%8.4g', ObjVal)), sprintf('\n')];
         Data = ObjVal;

      case 'meshlive1',
         plotmesh('objlive1',[-10; 30], [50 50; NaN NaN; 0 200]);


      case 'meshlive1d',
         plotmesh('objlive1',[-10 0; 30 0], [50 50; NaN NaN; -20 250]);


      case 'tablelive1',
         x1 = [-20:1:-10, -9.5:.5:30, 31:1:40]';
         x2 = [-10:1:20]';
         for ix = 1:length(x2), 
            ox(:,ix) = objlive1([x1, repmat(x2(ix), [length(x1), 1])]); 
         end;
         os=sprintf('%s%s\n', repmat(' ', [1,13]), sprintf('%8.0f', x2)); 
         for ix = 1:length(x1), 
            os=[os, sprintf('%10.1f   %s\n', x1(ix), sprintf('%8.0f', ox(ix,:)) )]; 
         end
         sprintf('%s', os),


      case {'mutreal', 'mutint', 'mutrandreal', 'mutrandint', 'recdis', 'recint', 'reclin', 'reclinex'},
         if isempty(AddPara), AddPara = 150; end
         if iscell(AddPara), NumPoints = AddPara{1}; else NumPoints = AddPara(1); end 
         BoundsData = [-3.2 5.1; 15.4 25.8];
         % Produce the data points and labels for recombination and mutation separately
         switch lower(Cmd),
            case {'recdis', 'recint', 'reclin', 'reclinex'}
               RealData = [1.3 11.1; 11.3 18.9];
               if strcmp(lower(Cmd), 'reclinex'),
                  NewChrom  = feval(Cmd, repmat(RealData,[floor(NumPoints/2), 1]), [1, 1], BoundsData);
               else
                  NewChrom  = feval(Cmd, repmat(RealData,[floor(NumPoints/2), 1]));
               end
               TextTitle = sprintf(' Recombination of  [ %s]  and  [ %s]  by  ''%s''  producing  %g  offspring.', ...
                                   sprintf('%g ', RealData(1,:)), sprintf('%g ', RealData(2,:)), Cmd, NumPoints);
               LineStyleOffsping = 'ro';
               VisuOpt = visuoptset( ... 
                      'Plot.FigureTag', 'Lecture_Recombination_1' ...
                    );
               Data4Visu = {RealData(:,2), RealData(:,1)};
            case {'mutreal', 'mutint', 'mutrandreal', 'mutrandint'},
               RealData = [6.3, 12.5];
               NewChrom  = feval(Cmd, repmat(RealData, [NumPoints, 1]), BoundsData, [NaN, .4, 6]);
               TextTitle = sprintf(' Mutation of  [ %s]  by  ''%s''  producing  %g  offspring.', sprintf('%g ', RealData), Cmd, NumPoints);
               LineStyleOffsping = 'mo';
               VisuOpt = visuoptset( ... 
                      'Plot.FigureTag', 'Lecture_Mutation_1' ...
                    );
               Data4Visu = {RealData(2), RealData(1)};
            otherwise
               sprintf('Unknown command: %s.', Cmd),
         end
         % Get the boundaries of the data
         [DataMin, DataMax, DataDiffScaled] = visuminmaxdiff([NewChrom(:)', RealData(:)']);
         TextXLabel= 'first variable of individual';
         % Define the plot options for figure, axes, boundary lines, parent points and legend
         VisuOpt = visuoptset( VisuOpt ... 
              , 'Plot.FigureName', TextTitle ...
              , 'Plot.Type', '2dpoint', 'Plot.GridMode', 'xy' ...
              , 'Plot.Title', TextTitle ...
              , 'Plot.XCaption', TextXLabel, 'Plot.YCaption', 'second variable of individual' ...
              , 'Plot.LineStyle', {LineStyleOffsping, 'bs'} ...
              , 'Plot.LegendMode', 0, 'Plot.LegendFontScale', 0.8 ...
              , 'Plot.FigureFontSize', 10 , 'Plot.FigureFontName', 'Times New Roman' ...
              , 'Plot.GridValues', {[BoundsData(:,1)', RealData(:,1)'], [BoundsData(:,2)', RealData(:,2)']} ...
              , 'Preproc.Scale', 2 ...
              , 'Preproc.ScalingBorders', {BoundsData(:,1)+[-.5;.5], BoundsData(:,2)+[-.5;.5]} ...
              );
         % Create figure with defined options
         [VisuStatus, FigureHdl] = visubase({NewChrom(1,2)', NewChrom(1,1)'; Data4Visu{:}}, {'offspring'; 'parent'}, VisuOpt);
         % Randomize the data points a bit
         DoRandomize = 1;
         if DoRandomize == 1,
            Rand4NewChrom = rand(size(NewChrom)) .* (1-2*(rand(size(NewChrom))>.5)) .* 0.01;
            Rand4NewChrom = Rand4NewChrom .* repmat([BoundsData(2,:)-BoundsData(1,:)], [size(NewChrom,1),1]);
            NewChrom = NewChrom + Rand4NewChrom;
         end
         % Plot each of the data point with a short pause inbetween for animation
         hold on;
         figure(FigureHdl);
         for ipoint = 2:size(NewChrom,1),
            plot(NewChrom(ipoint,1), NewChrom(ipoint,2), LineStyleOffsping); pause(.1);
            xlabel(sprintf('%s %g', TextXLabel, ipoint));
         end
         xlabel(TextXLabel);
         hold off;


      case {'selrws', 'selsus', 'seltrunc', 'seltour'},
         if isempty(AddPara), AddPara = 2; end
         % RankPara: (1) - selective pressure, (2) - ranking method
         if iscell(AddPara), RankPara = AddPara{1}; else RankPara = AddPara; end 
         NumInd = 19; Inds = [1:1:NumInd]';
         fitnv=ranking(Inds, RankPara);
         SelIx = feval(Cmd, fitnv, 100);
         hist(SelIx, Inds);


      otherwise
         sprintf('Unknown command: %s.', Cmd),

   end


% End of function