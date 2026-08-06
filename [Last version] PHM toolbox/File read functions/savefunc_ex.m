function savefunc_ex(src_filepath, dst_filepath, fileList)
for i=1:length(fileList)
    % 입력파일 처리 
    % ex : signal = func([src_filepath '\' num2str(i))
    % 출력파일 처리 
    % ex : save([dst_filepath '\' filename] , 'signal')
end

%% 예 : wav파일 하나를 1초의 여러 신호로 분할하여 mat 파일로 저장하는 코드
% for i=1:length(fileList)
%     [signals, fs]=audioread([src_filepath '\' fileList{i}]);
%     for j=1:4
%         mkdir([dst_filepath '\' fileList{i}(1:end-4) '\ch' num2str(j)]);
%         segnum=size(signals,1)/fs;
%         c=1;
%         for k=1:0.5:segnum
%             signal=signals((k-1)*fs+1 : k*fs, j);
%             save([dst_filepath '\' fileList{i}(1:end-4) '\ch' num2str(j) '\' num2str(c)],'signal', 'fs');
%             c=c+1;
%         end
%     end
% end