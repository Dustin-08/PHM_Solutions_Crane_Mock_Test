function [norm_vals, min_val, max_val]=norm_vector(vals, min_val, max_val)

if nargin<3
    min_val=min(vals);
    max_val=max(vals);
end
    

norm_vals=(vals-repmat(min_val, size(vals,1),1))./repmat(max_val-min_val,size(vals,1),1);