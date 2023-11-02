%%%P.2001-2-2015: Find Value in txt data
        function [value] = get_txt_value_GUI(app,lat,lon,temp)
            %Based on the size of the data, find the 4 nearest points and Bilinear Interp
            %This is only valid with nick_import_"data".csv
            data=flipud(temp);
            [y3, x3]=size(data);
            
            if x3==720 %For Tropo Data, take nearest point, no bi-linear interp
                temp_lon=lon+180; %Make Longitude from 0-360
                temp_lat=lat+90;  %Make latitude from 0-180
                spacing_lat=180/(y3);
                spacing_lon=360/(x3);
                
                %find two nearest lats and lons
                series_lon=1:1:x3;
                series_lat=1:1:y3;
                
                %Makes it larger
                small_lat=temp_lat*(y3)/180;
                small_lon=temp_lon*(x3)/360;
                
                %Find 2 nearest lats/longs to small lat/lon
                [lon_val, lon_idx]=sort(abs(small_lon+0.25-series_lon));
                [lat_val, lat_idx]=sort(abs(small_lat+0.25-series_lat));
                
                lon2_idx=sort(lon_idx(1));
                lat2_idx=sort(lat_idx(1));
                
                value=data(series_lat(lat2_idx),series_lon(lon2_idx));
                
            else %All other data files
                spacing_lat=180/(y3-1);
                spacing_lon=360/(x3-1);
                
                
                temp_lat=lat+90;  %Make latitude from 0-180
                if lon<0 %Make longitude from 0-360
                    temp_lon=lon+360;
                else
                    temp_lon=lon;
                end
                
                %find two nearest lats and lons
                series_lon=1:1:x3;
                series_lat=1:1:y3;
                
                %Makes it smaller
                small_lat=temp_lat*(y3-1)/180+1;
                small_lon=temp_lon*(x3-1)/360+1;
                
                %Find 2 nearest lats/longs to small lat/lon
                [lon_val, lon_idx]=sort(abs(small_lon-series_lon));
                [lat_val, lat_idx]=sort(abs(small_lat-series_lat));
                
                lon2_idx=sort(lon_idx(1:2));
                lat2_idx=sort(lat_idx(1:2));
                
                Q11=data(series_lat(lat2_idx(1)),series_lon(lon2_idx(1)));
                Q12=data(series_lat(lat2_idx(2)),series_lon(lon2_idx(1)));
                Q21=data(series_lat(lat2_idx(1)),series_lon(lon2_idx(2)));
                Q22=data(series_lat(lat2_idx(2)),series_lon(lon2_idx(2)));
                
                x=small_lon;
                y=small_lat;
                
                x1=series_lon(lon2_idx(1));
                x2=series_lon(lon2_idx(2));
                y1=series_lat(lat2_idx(1));
                y2=series_lat(lat2_idx(2));
                
                value=((((x2-x)*(y2-y))/((x2-x1)*(y2-y1)))*Q11)+((((x-x1)*(y2-y))/((x2-x1)*(y2-y1)))*Q21)+((((x2-x)*(y-y1))/((x2-x1)*(y2-y1)))*Q12)+((((x-x1)*(y-y1))/((x2-x1)*(y2-y1)))*Q22); %This is the return value
            end
        end