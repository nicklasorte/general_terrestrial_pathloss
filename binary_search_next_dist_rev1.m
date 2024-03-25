function [next_single_search_dist]=binary_search_next_dist_rev1(app,radar_threshold,temp_binary_data)


lo_km=0;  %%%%%%%%Which is really 1.
hi_km=temp_binary_data(end,1);

if hi_km-lo_km<=1
    mid_km=hi_km; %%%No more search
    next_single_search_dist=NaN(1,1);
else
    tf_binary_search=1;
    while(tf_binary_search==1) %%%Binary Search
        mid_km=ceil((hi_km+lo_km)/2)

        %%%%%See if the mid_km has data
        mid_row_idx=find(temp_binary_data(:,1)==mid_km);

        if isempty(mid_row_idx)
            next_single_search_dist=mid_km;
            tf_binary_search=0;
        elseif mid_km==hi_km
            next_single_search_dist=NaN(1,1);
            tf_binary_search=0;
        else
            if temp_binary_data(mid_row_idx,2)<radar_threshold
                hi_km=mid_km;
            else
                lo_km=mid_km;
            end
        end
    end
end
end