function draweval(eval_tree, level)
rows=level+1;
cols=2^(level+1)*5;
img_eval=zeros(rows,cols);
for i=1:rows
    inCols=2^(i-1);
    step=cols/inCols;
    index=[1:inCols].*step;
    img_eval(i,1:ceil(index(1)))=eval_tree{i}{1};
    for j=1:size(index,2)-1
        img_eval(i,ceil(index(j)):(ceil(index(j+1)-1e-10)))=eval_tree{i}{j+1};
    end
end

figure, wscalogram('image',img_eval);
xlabel('Node');
ylabel('Level');
colormap(gca, 'jet');