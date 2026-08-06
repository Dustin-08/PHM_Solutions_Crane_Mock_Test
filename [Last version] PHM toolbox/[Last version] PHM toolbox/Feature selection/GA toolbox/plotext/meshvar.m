% Create search space visualizations (one- and two dimensional slices) of objective functions
%
% See also: plotmesh, graf_msh

% Author:   Hartmut Pohlheim
% History:  16.05.1997  file created, some test systems,
%                       most stuff for dismo system
%                       corresponding changes in plotmesh
%           08.09.1997  new version of dismo3 added,
%                       direct data loading, some other enhancements
%           25.02.1998  new stuff for me problem added


function meshvar(System, PlotDim),

% Global variable used for distribution of calculations, default to not used
   global DPGEA_USE
   DPGEA_USE = 0;

% Check input parameter
   if nargin < 1, System = []; end
   if isempty(System), System = 'fun10'; end

   if nargin < 2, PlotDim = []; end
   if isempty(PlotDim), PlotDim = 1; end

   % Define percent of boundaries to use for variation of variables
   VariationArea = 0.1;
   
   % PlotIndex
   PlotIndex = 1;
   
% Define print parameter
   ResPathMesh = '/home/intelligent/pohlheim/grafics/';
   % ResPathMesh = 'grafmesh\';
   PrintHow = 'c';
   if isempty(PrintHow), PrintHowString = 'sw'; else PrintHowString = PrintHow; end

% Define empty matrix for additional parameters to objective function
   AddParas = [];
   FNExtra = '';

% Define the system
   if strcmp(lower(System), 'chopper'),
      OBJ_F = 'objchop5';
      szennum = [1,2,3];
      [SysPar, SysVar] = feval(OBJ_F, [], 4);
      AddParas = [', szennum, Kcfg, SysPar, SysVar'];

      % Define good solutions   
      GoodIndWork9 = [-0.0010118     0.00012177    -0.00028673     0.00023137    -0.00034436    -0.00051687    -0.00015869     8.0217e-06      0.0060744;      % ls12_01.res
                     ]; 
      GoodIndWork = GoodIndWork9(1,:); Kcfg = 12;
   elseif strcmp(lower(System), 'fun10'),
      OBJ_F = 'objfun10';
      % Define good solutions
      UseDim = 6;
      GoodIndWork = repmat(0, [1, UseDim]);
      Bounds = feval(OBJ_F, [], 1);
      Bounds = Bounds(:, [1:UseDim]);
   elseif strcmp(lower(System), 'fun2'),
      OBJ_F = 'objfun2';
      % Define good solutions
      UseDim = 5;
      GoodIndWork = repmat(1, [1, UseDim]);
      Bounds = feval(OBJ_F, [], 1);
      Bounds = Bounds(:, [1:UseDim]);
      % VariationArea = repmat(0.01, [1, UseDim]);
      % VariationArea([3,4]) = [0.001, 0.0005];
   elseif strcmp(lower(System), 'dmot03'),
      ResPathMesh = '/home/intelligent/pohlheim/grafics/';
      OBJ_F = 'objdmot3';
      % Define good individuals and the corresponding scaling
      ResNumber = 10;
      ResPath = ['results/'];
      OptResults = [ 'dmot3_01_BestInd';     % dmot3_03.res/mat last ObjType=1
                     'dmot3_02_BestInd';     % dmot3_03.res/mat second last
                     'dmot3_03_BestInd';     % dmot3_03.res/mat last
                     'dmot3_04_BestInd';     % dmot3_04.res/mat
                     'dmot3_05_BestInd';     % dmot3_05.res/mat
                     'dmot3_06_BestInd';     % dmot3_06.res/mat
                     'dmot3_07_BestInd';     % dmot3_07.res/mat
                     'dmot3_08_BestInd';     % dmot3_08.res/mat
                     'dmot3_09_BestInd';     % dmot3_09.res/mat
                     'dmot3_10_BestInd';     % dmot3_10.res/mat
                   ];
      if ResNumber == 10,
         Bounds = feval(OBJ_F, [], 1);
         DiffBounds = 0.5 .* (Bounds(2,:) - Bounds(1,:));
         GoodIndWork = Bounds(1,:) + DiffBounds;
      else
         eval(['load ' ResPath OptResults(ResNumber-10, :)]); 
         GoodIndWork = BestInd(1,:);
      end
      System = [System '_Res' num2str(ResNumber)];
      % disp(sprintf('GoodInd: %s', sprintf('%11.5g', GoodIndWork(1,:))));

      Scaling = repmat(1, [1, length(GoodIndWork)]);
      ObjType = 2;
      AddParas = [', Scaling, ObjType'];
      VariationArea = 1;
      % VariationArea = [0.1  0.1  0.2  0.1  1  1  0.1];
      % PlotIndex = 1;

   elseif strcmp(lower(System), 'dismo7'),
      ResPathMesh = '/home/intelligent/pohlheim/grafics/';
      OBJ_F = 'objdmot7';
      % Define good individuals and the corresponding scaling
      ResPath = ['results8/'];
      % ResPath = ['results7/'];

      UseData = 1;
      if UseData == 1,
         % Define good individuals and the corresponding scaling
         [FileNameBinData, PathNameBinData]=uigetfile('*.mat', 'Select file with binary data from optimization!');
         if FileNameBinData == 0, error('Error in file load !'); end
         % Load BinData file
         load([PathNameBinData FileNameBinData], 'ShowIndAll', 'ObjVBestAll');
      elseif UseData == 2,
         FileNameBinData = 'dmot5_data1_10_02.mat';
         load([ResPath FileNameBinData], 'ShowIndAll', 'ObjVBestAll');
      end
   
      % Get number of good individuals (identical to number of generations)
      Generation = size(ShowIndAll, 1);
      GoodIndWork = ShowIndAll(Generation,:);
      % GoodIndWork = [140   0.08   0.0     0.08   700   0.3   1.8];
      % GoodIndWork = [200   0.00028 0.0096 0.082  487   0.17  2.08]
      % GoodIndWork = [172   0.01   0.00017 0.068  140   0.96  1.4]
         
      if 0,
         Bounds = feval(OBJ_F, [], 1);
         DiffBounds = 0.5 .* (Bounds(2,:) - Bounds(1,:));
         GoodIndWork = Bounds(1,:) + DiffBounds;
      end
      System = [FileNameBinData(1:length(FileNameBinData)-4) '_Res'];
      % disp(sprintf('GoodInd: %s', sprintf('%11.5g', GoodIndWork(1,:))));

      % Names of DATA files from objective function
      FileNameData = feval(OBJ_F, [], 6);
      % FileNameData = FileNameData([1:5],:);
      % FileNameData = FileNameData([2, 3, 5, 7, 8, 10:14],:);
      FileNameData = FileNameData([1, 4, 6, 9],:);
      Scaling = [];  ObjType = 3;
      AddParas = [', FileNameData, Scaling, ObjType'];
      % VariationArea = 0.1;
      % VariationArea = [0.1  0.1  0.2  0.1  1  1  0.1];
      if PlotDim == 1,
         PlotIndex = [1:7];
         VariationArea = [0.1 0.005 0.1 0.1 1 0.1 0.1];
      else
         PlotIndex = [ 1  1  2  3  4  6;
                       2  3  3  4  6  7 ];
         % VariationArea = [0.05  0.005  0.1  0.02  1  0.08  0.1];
         VariationArea = [0.03  0.005  0.05  0.02  1  0.05  0.05];
      end
      DPGEA_USE = 1;
      
   elseif strcmp(lower(System), 'me'),
      ResPathMesh = '/projects/geatest/me/grafics/';
      OBJ_F = 'objme1';
      % Define good individuals and the corresponding scaling
      ResPath = [''];

      FileNameBinData = 'variation';
      Bounds = feval(OBJ_F, [], 1);

      UseData = 3;
      if UseData == 1,
         FileNameBinData = '???';
         load([ResPath FileNameBinData], 'ShowIndAll', 'ObjVBestAll');
         % Get number of good individuals (identical to number of generations)
         Generation = size(ShowIndAll, 1);
         GoodIndWork = ShowIndAll(Generation,:);

      elseif UseData == 2,
         GoodIndWork = Bounds(1,:);
         % Bounds([1,2],[1,2]) = [   0,  0;  24, 24]; FNExtra = 'corner1_';
         % Bounds([1,2],[1,2]) = [1175,  0;1200, 24]; FNExtra = 'corner2_';
         % Bounds([1,2],[1,2]) = [   0,262;  24,287]; FNExtra = 'corner3_';
         % Bounds([1,2],[1,2]) = [1175,262;1200,287]; FNExtra = 'corner4_';
         % Bounds([1,2],[1,2]) = [  -7, -7;  18, 18]; FNExtra = 'corner1out_';
         % Bounds([1,2],[1,2]) = [  -7, -7;   7,  7]; FNExtra = 'corner1outsmall_';
         % Bounds([1,2],[1,2]) = [1183, -7;1208, 18]; FNExtra = 'corner2out_';
         % Bounds([1,2],[1,2]) = [  -7,270;  18,295]; FNExtra = 'corner3out_';
         % Bounds([1,2],[1,2]) = [1183,270;1208,295]; FNExtra = 'corner4out_';
         PlotDim = 2; Points = [25, 25]; PlotIndex = [1; 2];
         option = 1; AddParas = [', option'];
          
      elseif UseData == 3,  % change shade of pixels
         % GoodIndWork = [100, 100, repmat(500, [1, 841])];
         % Bounds = [[ 100, 100; 100, 100], repmat([1;4095], [1, 841])]; FNExtra = 'changeshade1point_';
         GoodIndWork = [100, 100, round(linspace(1, 4095, 841))];
         Bounds = [[ 100, 100; 100, 100], repmat([1;4095], [1, 841])]; FNExtra = 'chshade1po_contbackshade_';
         PlotDim = 1; Points = [100]; PlotIndex = [416:424];
         option = 1; AddParas = [', option'];

      elseif UseData == 4,  % special shade position run
         GoodIndWork = [100, 100, 420];
         % Bounds = [ 100, 100,   3; 100, 100, 843]; FNExtra = 'shade1point841_fullarea_'; Points = 841; PlotIndex = [3];
         Bounds = [ 100, 100, 340; 100, 100, 500]; FNExtra = 'shade1point841_340_500_';  Points = 161; PlotIndex = [3];
         
         % GoodIndWork = [100, 100, 420, 420];
         % Bounds = [ 100, 100, 380, 380; 100, 100, 460, 460]; FNExtra = 'shade2points841_380_460_'; Points = []; PlotIndex = [3; 4];
         % Bounds = [ 100, 100, 400, 400; 100, 100, 440, 440]; FNExtra = 'shade2points841_400_440_'; Points = [41, 41]; PlotIndex = [3; 4];
         option = 6; AddParas = [', option'];
      else
         DiffBounds = 0.5 .* (Bounds(2,:) - Bounds(1,:));
         GoodIndWork = Bounds(1,:) + DiffBounds;
      end
   
         
      System = [FileNameBinData '_Res'];
      % disp(sprintf('GoodInd: %s', sprintf('%11.5g', GoodIndWork(1,:))));

      VariationArea = [1];

   elseif strcmp(lower(System), 'sortb'),
      ResPathMesh = '/projects/geatest/sortb/grafics/';
      OBJ_F = 'objsortb1';
      % Define good individuals and the corresponding scaling
      ResPath = [''];

      FileNameBinData = 'var_sortb1';
      Bounds = feval(OBJ_F, [], 1);

      UseData = 2;
      if UseData == 1,
         FileNameBinData = '???';
         load([ResPath FileNameBinData], 'ShowIndAll', 'ObjVBestAll');
         % Get number of good individuals (identical to number of generations)
         Generation = size(ShowIndAll, 1);
         GoodIndWork = ShowIndAll(Generation,:);

     elseif UseData == 2,
         % GoodIndWork = round(linspace(Bounds(1,1), Bounds(2,1), 500));
         % GoodIndWork = round(-32767+65500*rand(1,500)); FNExtra = 'rand_ind_'; 
         load('Rand_Ind_Sortb.txt');  % a mat file with this name contains one random ind
         GoodIndWork = Rand_Ind_Sortb - 32768; FNExtra = 'rand_ind_small_';
         PlotDim = 2; Points = [35, 35];
         PlotIndex = [150; 250]; GoodIndWork(PlotIndex) = GoodIndWork(PlotIndex) - [0, 0]; 
         % Bounds(:, PlotIndex(1)) = Bounds(:, PlotIndex(1)) - [-10000; 10000];
         ValPlotIndex = GoodIndWork(PlotIndex)
         ExtendInt = 20;
         VariationArea = ones(1, 500);
         VariationArea(PlotIndex(2)) = Points(2) .* ExtendInt ./ 65535;
         iind = 1; Bounds(:, PlotIndex(iind)) = [ValPlotIndex(iind) - floor(Points(iind)/2*ExtendInt); ValPlotIndex(iind) + floor(Points(iind)/2*ExtendInt)];
         % for iind = 1:length(PlotIndex),
            % Bounds(:, PlotIndex(nd)) = [ValPlotIndex(iind) - floor(Points(iind)/2*ExtendInt); ValPlotIndex(iind) + floor(Points(iind)/2*ExtendInt)];
         % end
         option = 1; AddParas = [', option'];

      else
         DiffBounds = 0.5 .* (Bounds(2,:) - Bounds(1,:));
         GoodIndWork = Bounds(1,:) + DiffBounds;
      end
         
      System = [FileNameBinData '_Res'];
      % disp(sprintf('GoodInd: %s', sprintf('%11.5g', GoodIndWork(1,:))));

      % VariationArea = [1];



   else error('Unknown System!!');
   end
   
   % If Bounds not defined, get them from objective function
   if exist('Bounds') ~= 1, Bounds = []; end
   if isempty(Bounds),
      Bounds = feval(OBJ_F, [], 1);
   end
   
   % Check VariationArea
   if prod(size(VariationArea)) == 1,
      VariationArea = repmat(VariationArea, [1, size(GoodIndWork, 2)]);
   elseif length(VariationArea) > size(GoodIndWork, 2),
      VariationArea = VariationArea(1:size(GoodIndWork, 2));
   elseif length(VariationArea) < size(GoodIndWork, 2),
      error('Think about the defined VariationArea, must be 1 element or as many as variables!');
   end
   
   if any(VariationArea ~= 1),
      DiffBounds = 0.5 .* VariationArea .* (Bounds(2,:) - Bounds(1,:));
      NewBounds(1,:) = GoodIndWork - DiffBounds;
      NewBounds(2,:) = GoodIndWork + DiffBounds;
      NewBounds(1,:) = max(NewBounds(1,:), Bounds(1,:));
      NewBounds(2,:) = min(NewBounds(2,:), Bounds(2,:));
      Bounds = NewBounds;
   end


   % Check PlotIndex
   if prod(size(PlotIndex)) == 1,
      if PlotDim == 1, PlotIndex = [PlotIndex:size(GoodIndWork,2)];
      elseif PlotDim == 2,
         PlotIndex = [PlotIndex:2:size(GoodIndWork,2)-1];
         if PlotIndex(length(PlotIndex)) ~= size(GoodIndWork,2)-1,
            PlotIndex = [PlotIndex, size(GoodIndWork,2)-1];
         end
         PlotIndex = [PlotIndex; PlotIndex+1];
      end
   else
      if PlotDim == 1, PlotIndex = PlotIndex(1,:);
      elseif PlotDim == 2,
         if size(PlotIndex, 1) == 1, PlotIndex = [PlotIndex; PlotIndex+1]; end
      end
   end
   
   % Output some stuff
   if length(GoodIndWork) <= 20,
      fprintf('GoodInd:    %s\n', sprintf('%11.5g', GoodIndWork(1,:)));
      fprintf('Bounds:     %s\n            %s\n', sprintf('%11.5g', Bounds(1,:)), sprintf('%11.5g', Bounds(2,:)));
   else
      fprintf('GoodInd:    %s\n', sprintf('%11.5g', GoodIndWork(1, PlotIndex)));
      fprintf('Bounds:     %s\n            %s\n', sprintf('%11.5g', Bounds(1, PlotIndex)), sprintf('%11.5g', Bounds(2, PlotIndex)));
   end
   fprintf('PlotIndex:  %s\n', sprintf('%11.5g', PlotIndex));
   fprintf('Points:     %s\n', sprintf('%11.5g', Points));

   
   % Start calculation and grafical output
   for idim = 1:size(PlotIndex, 2),
      if PlotDim == 1, 
         Ixidim = PlotIndex(1, idim);
         if isempty(Points), Points = 100; end
         % Add the best ind value to Points, second row of Points
         Points = [Points(1,:); GoodIndWork(PlotIndex(1, idim))];
      elseif PlotDim == 2,
         Ixidim = [PlotIndex(1, idim), PlotIndex(2, idim)];
         if any(Ixidim) > size(GoodIndWork, 2), Ixidim = Ixidim - 1; end
         if isempty(Points), Points = [25, 25]; end
         % Add the best ind values to Points, second row of Points
         Points = [Points(1,:); GoodIndWork(Ixidim)];
      end
      BoundsIntern = [GoodIndWork; GoodIndWork];
      BoundsIntern(:, Ixidim) = Bounds(:, Ixidim);
      evalstr = ['plotmesh(''' OBJ_F ''', BoundsIntern, Points' AddParas ');'];
      % if idim == 1, disp(evalstr); end
      eval(evalstr);
      FileName = sprintf('%s_Var%sArea%s_Value%s_%s%s_tiff', System, sprintf('%d_', Ixidim), ...
                         sprintf('_%g', VariationArea(Ixidim)*100), ...
                         sprintf('_%.4g', GoodIndWork(Ixidim)), FNExtra, PrintHowString);
      IxPoint = findstr(FileName, '.');
      if length(IxPoint) > 0, FileName([IxPoint]) = repmat('_', [1 length(IxPoint)]); end
      % FileName = sprintf('%s%d_%dD%s', SystemShort, idim, length(Ixidim), PrintHow);
      eval(['print  -dmfile ' ResPathMesh FileName ])
      % eval(['print -deps' PrintHow ' -tiff ' ResPathMesh FileName ])
      eval(['print -deps' PrintHow '  ' ResPathMesh FileName ])
      disp(sprintf('Grafic saved in File %s          ', [ResPathMesh FileName]));
      % disp('pausing'); pause
   end


% Global variable used for distribution of calculations, default to not used
   DPGEA_USE = 0;

% End of function


