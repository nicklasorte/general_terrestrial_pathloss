function [pathloss]=fix_inf_pathloss_rev1(app,pathloss)

if any(isinf(pathloss))
    inf_idx=find(isinf(pathloss))
    inf_pathloss=pathloss(inf_idx,:)
    pos_inf_idx=find(inf_pathloss>=0)
    neg_inf_idx=find(inf_pathloss<0)
    [num_rows,num_cols]=size(pathloss);
    if num_cols>1
        'More than 1 col on'
        pause;
    end
    if ~isempty(neg_inf_idx)
        pathloss(inf_idx)
        inf_idx(neg_inf_idx)
        pathloss(inf_idx(neg_inf_idx))
        pathloss(inf_idx(neg_inf_idx))=1;
        pathloss(inf_idx(neg_inf_idx))
        %'check'
        %pause;
    end
    if ~isempty(pos_inf_idx)
        pathloss(inf_idx)
        inf_idx(pos_inf_idx)
        pathloss(inf_idx(pos_inf_idx))
        pathloss(inf_idx(pos_inf_idx))=999;
        pathloss(inf_idx(pos_inf_idx))
        %'check'
        %pause;
    end
end
end