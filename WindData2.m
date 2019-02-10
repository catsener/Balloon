%%wind import data%%
function [iso lat lon] = WindData2(file)
nco=ncgeodataset(file);
lon=nco{'lon'}(:);
lat=nco{'lat'}(:);
iso=nco{'isobaric2'}(:);
end