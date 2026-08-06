function [norm_vals, min_val, max_val]=normalization(vals, min_val, max_val)

if nargin<3
    min_val=repmat(min(vals),size(vals,1),1);
    max_val=repmat(max(vals),size(vals,1),1);
end
    

norm_vals=(vals-min_val)./(max_val-min_val);