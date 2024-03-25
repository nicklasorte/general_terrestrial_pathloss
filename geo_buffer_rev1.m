function [array_latlon_buffer]=geo_buffer_rev1(app,array_latlon,buffer_km)


%%%Remove NaNs
array_latlon=array_latlon(~isnan(array_latlon(:,1)),:);

[num_rows,~]=size(array_latlon);
buff_lat=cell(num_rows,1);
buff_lon=cell(num_rows,1);
for i=1:1:num_rows
    [buff_lat{i},buff_lon{i}]=scircle1(array_latlon(i,1),array_latlon(i,2),km2deg(buffer_km),[],[],'degrees',50);
end
buff_lat=vertcat(buff_lat{:});
buff_lon=vertcat(buff_lon{:});
lat2=reshape(buff_lat,[],1);
lon2=reshape(buff_lon,[],1);

lat3=lat2(~isnan(lat2));
lon3=lon2(~isnan(lon2));

k=convhull(lon3,lat3);
lat4=lat3(k);
lon4=lon3(k);
array_latlon_buffer=[lat4,lon4];

end