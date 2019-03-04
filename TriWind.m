%%tridimensional wind%%
function [Vwx Vwy Vwz T] = TriWind(file)
nco=ncgeodataset(file);
Vwx=nco{'u-component_of_wind_isobaric'}(:);
Vwx=squeeze(Vwx);
Vwy=nco{'v-component_of_wind_isobaric'}(:);
Vwy=squeeze(Vwy);
Vwz=0;
T=nco{'Temperature_isobaric'}(:);
T=squeeze(T);
end