% RE-INSertion of offspring in population replacing parents LOCal
%
% This function performs local insertion of offspring into the current 
% population, replacing parents with offspring and returning the
% resulting population. If sellocal was used for selection, reinsloc
% must be used for reinsertion. This is the only chance to
% keep the local neighbourhood unchanged.
% The calling syntax is very similar to reins.
% This function doesn't support subpopulations. Thus, for a hybrid
% model of regional and local model reinsloc must be called
% from reins. Then reins handles all the regional stuff.
%
% Syntax:  [Chrom, ObjVCh] = reinsloc(Chrom, SelCh, SUBPOPCh, SUBPOPSel, InsOpt, ObjVCh, ObjVSel, RankCh, RankSel, SelIx)
%
% Input parameters:
%    Chrom     - see reins
%    SelCh     - see reins
%    SUBPOPCh  - see reins
%    SUBPOPSel - see reins
%    InsOpt    - (optional) Vector containing the insertion method parameters
%                InsOpt(1): Select - number indicating kind of insertion
%                           0 - every offspring replace randomly
%                           1 - every offspring replace weakest
%                           2 - fitter than weakest replace weakest
%                           3 - fitter than weakest replace parents
%                           4 - fitter than weakest replace randomly
%                           5 - fitter than parent replace parent
%                           6 - replace parents
%                           if omitted or NaN, 2 is assumed
%                InsOpt(2): not used
%                InsOpt(5): local dimension (see comploc)
%                InsOpt(6): local structure (see comploc)
%                InsOpt(7): local distance  (see comploc)
%    ObjVCh    - see reins
%    ObjVSel   - see reins
%    RankCh    - see reins
%    RankSel   - see reins
%    SelIx     - Matrix containing indices of selected parents in Chrom, output parameter
%                of selection/sellocal
%
% Output parameters:
%    Chrom     - Matrix containing the individuals of the current
%                population after reinsertion.
%    ObjVCh    - if ObjVCh and ObjVSel are input parameter, than column vector containing
%                the objective values of the individuals of the current
%                generation after reinsertion.
%
% See also: reins, reinsreg, sellocal

% Author:   Hartmut Pohlheim
% History:  12.02.97    file created
%           31.07.97    flipud included for handling of NaN


function [Chrom, ObjVCh] = reinsloc(Chrom, SelCh, SUBPOPCh, SUBPOPSel, InsOpt, ObjVCh, ObjVSel, RankCh, RankSel, SelIx);

   % Parameter in InsOpt
   Select = InsOpt(1); SelOpt = InsOpt(5:7);

   % Get number of individuals/offspring in actual subpopulation
   NindCh = SUBPOPCh;
   NindSel = SUBPOPSel;

   % Get indices of odd parents (center of neighbourhood)
   SelIxOdd = SelIx(1:2:size(SelIx,1)-1);
   SelIxOdd = SelIxOdd(:);

   % Construct matrix containing neighbours of first parents,
   % one row per neighbourhood, as many columns as neighbours
   MatInd2 = comploc('local_neighbourhood', NindCh, SelIxOdd, SelOpt);
   MatInd2 = [SelIxOdd, MatInd2];
   
   % Select according structure
   if Select == 0,       % every offspring replace randomly from all
      % Select randomly individuals (parents) in neighbourhood
      [Dummy, INSCh] = sort(rand(size(MatInd2))');
      INSCh = (INSCh([1,2],:)'-1)*size(MatInd2,1)+[1:size(MatInd2,1);1:size(MatInd2,1)]';
      INSCh = MatInd2(INSCh)';
      INSCh = INSCh(1:size(INSCh,1)*size(INSCh,2))';
      % Select all offspring
      INSSel = [1:2*size(SelIxOdd,1)]';
   elseif Select == 1,   % every offspring replace weakest from all 
      % Select weakest individuals (parents) in neighbourhood
      Temp1 = repmat(RankCh,[1,size(MatInd2,2)]);
      % Sort first for best individual (-highest rank val is first) and 
      % flip afterwards - necessary for NaN, NaN should be the first to replace
      [Dummy, INSCh] = sort(-Temp1(MatInd2)');
      INSCh = flipud(INSCh);
      INSCh = (INSCh([1,2],:)'-1)*size(MatInd2,1)+[1:size(MatInd2,1);1:size(MatInd2,1)]';
      INSCh = MatInd2(INSCh)';
      INSCh = INSCh(1:size(INSCh,1)*size(INSCh,2))';
      % Select all offspring
      INSSel = [1:2*size(SelIxOdd,1)]';
   elseif Select == 2,   % fitter than weakest replace weakest from all
      % Select weakest individuals (parents) in neighbourhood
      Temp1 = repmat(RankCh,[1,size(MatInd2,2)]);
      % Sort first for best individual (-highest rank val is first) and 
      % flip afterwards - necessary for NaN, NaN should be the first to replace
      [Dummy, INSCh] = sort(-Temp1(MatInd2)');
      INSCh = flipud(INSCh);
      INSCh = (INSCh([1,2],:)'-1)*size(MatInd2,1)+[1:size(MatInd2,1);1:size(MatInd2,1)]';
      INSCh = MatInd2(INSCh)';
      INSCh = INSCh(1:size(INSCh,1)*size(INSCh,2))';
      % Select offspring fitter than weakest individual in neighbourhood
      INSSel = [1:2*size(SelIxOdd,1)]';
      TempWorstCh = min(Temp1(MatInd2)');
      TempWorstCh = TempWorstCh(repmat(1:size(TempWorstCh,2),[2,1]))';
      TempMax3 = (TempWorstCh < RankSel(INSSel)).*[1:size(INSSel,1)]';
      TempMax4 = TempMax3;
      TempMax3(TempMax3 == 0) = [];
      TempMax4 = sort(-(reshape(TempMax4, 2, length(TempMax4)/2)));
      TempMax4 = find(TempMax4 ~= 0);
      TempMax4 = TempMax4(:);
      % Select according from all parents and offspring
      INSCh = INSCh(TempMax4);
      INSSel = INSSel(TempMax3);
   elseif Select == 3,   % fitter than weakest replace parents
      % Select offspring fitter than weakest individual in neighbourhood
      INSSel = [1:2*size(SelIxOdd,1)]';
      Temp1 = repmat(RankCh,[1,size(MatInd2,2)]);
      TempWorstCh = min(Temp1(MatInd2)');
      TempWorstCh = TempWorstCh(repmat(1:size(TempWorstCh,2),[2,1]))';
      TempMax3 = (TempWorstCh < RankSel(INSSel)).*[1:size(INSSel,1)]';
      TempMax4 = TempMax3;
      TempMax3(TempMax3 == 0) = [];
      TempMax4 = sort(-(reshape(TempMax4, 2, length(TempMax4)/2)));
      TempMax4 = find(TempMax4 ~= 0);
      TempMax4 = TempMax4(:);
      % Select according from all parents and offspring
      INSCh = SelIx(TempMax4);
      INSSel = INSSel(TempMax3);
   elseif Select == 4,   % fitter than weakest replace randomly from all
      % Select randomly individuals (parents) in neighbourhood
      [Dummy, INSCh] = sort(rand(size(MatInd2))');
      INSCh = (INSCh([1,2],:)'-1)*size(MatInd2,1)+[1:size(MatInd2,1);1:size(MatInd2,1)]';
      INSCh = MatInd2(INSCh)';
      INSCh = INSCh(1:size(INSCh,1)*size(INSCh,2))';
      % Select offspring fitter than weakest individual in neighbourhood
      INSSel = [1:2*size(SelIxOdd,1)]';
      Temp1 = repmat(RankCh,[1,size(MatInd2,2)]);
      TempWorstCh = min(Temp1(MatInd2)');
      TempWorstCh = TempWorstCh(repmat(1:size(TempWorstCh,2),[2,1]))';
      TempMax3 = (TempWorstCh < RankSel(INSSel)).*[1:size(INSSel,1)]';
      TempMax4 = TempMax3;
      TempMax3(TempMax3 == 0) = [];
      TempMax4 = sort(-(reshape(TempMax4, 2, length(TempMax4)/2)));
      TempMax4 = find(TempMax4 ~= 0);
      TempMax4 = TempMax4(:);
      % Select according from all parents and offspring
      INSCh = INSCh(TempMax4);
      INSSel = INSSel(TempMax3);
   elseif Select == 5,   % fitter than parents replace randomly
      % Select randomly individuals (parents) in neighbourhood
      [Dummy, INSCh] = sort(rand(size(MatInd2))');
      INSCh = (INSCh([1,2],:)'-1)*size(MatInd2,1)+[1:size(MatInd2,1);1:size(MatInd2,1)]';
      INSCh = MatInd2(INSCh)';
      INSCh = INSCh(1:size(INSCh,1)*size(INSCh,2))';
      % Select offspring fitter than weakest individual in neighbourhood
      INSSel = [1:2*size(SelIxOdd,1)]';
      % -RankCh(SelIx(INSSel))'
      % -RankSel(INSSel)'
      % (RankCh(SelIx(INSSel)) > RankSel(INSSel))', pause
      TempMax3 = (RankCh(SelIx(INSSel)) < RankSel(INSSel)).*[1:size(INSSel,1)]';
      TempMax3(TempMax3 == 0) = [];
      % Select according from all parents and offspring
      INSCh = SelIx(TempMax3);
      INSSel = INSSel(TempMax3);
   else           % replace parents
      % Select both parents and all offspring
      INSCh = SelIx([1:2*size(SelIxOdd,1)])';
      INSSel = [1:2*size(SelIxOdd,1)]';
   end
   % MatInd2
   % disp(['SelIx:   ' sprintf('% 3d  ', SelIx)]);
   % disp(['INSCh:   ' sprintf('% 3d  ', INSCh)]);
   % disp(['ObjVCh:  ' sprintf('% 6.4g ', ObjVCh)]);
   % disp(['INSSel:  ' sprintf('% 3d  ', INSSel)]);
   % disp(['ObjVSel: ' sprintf('% 6.4g ', ObjVSel)]);
   % pause
   
   % if odd offspring reinsert last offspring
   if rem(NindSel,2) == 1,
      if any(Select == [0, 1]),       % every offspring replace
         INSSel = [INSSel(:); size(SelCh,1)];
         INSCh = [INSCh(:); SelIx(NindSel)];
      else                   % if any(Select == [2:5]),   % fitter than (parent)
         % RankSel(size(SelCh,1)); RankCh(SelIx(NindSel));
         if RankSel(size(SelCh,1)) <= RankCh(SelIx(NindSel)),
            INSSel = [INSSel(:); size(SelCh,1)];
            INSCh = [INSCh(:); SelIx(NindSel)];
         end
      end
   end

   % Insert offspring in subpopulation -> new subpopulation
   Chrom(INSCh,:) = SelCh(INSSel,:);
   if nargout > 1, ObjVCh(INSCh,:) = ObjVSel(INSSel,:); end


% End of function
