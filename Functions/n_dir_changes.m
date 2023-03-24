function [n,n_bigger,change_values] = n_dir_changes(vec,threshold)

if ~exist('threshold','var')
    threshold = -1;
    n_bigger=0;
    change_values=[];
end

A = diff(vec)>0;
v=(diff(A));
n = nnz(v);

if(threshold~=-1)
    change_values=[];
    idxs=find(v~=0);
    
    if(~isempty(idxs))
        for j=1:length(idxs)+1
            if(j==1)
                change_values=[change_values,vec(idxs(j)+1)-vec(1)];
            elseif (j>length(idxs))
                change_values=[change_values,vec(end)-vec(idxs(end)+1)];
            else
                change_values=[change_values,vec(idxs(j)+1)-vec(idxs(j-1)+1)];
            end
        end
        n_bigger=nnz(abs(change_values)>threshold);
    else
        n_bigger=0;
    end
end