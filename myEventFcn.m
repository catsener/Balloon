function [value,isterminal,direction] = myEventFcn(t,x,T,iso,lat,lon,mgas,mmolecular,VB,R,lon0,lat0,hora)

X=x(1);
Y=x(2);
Z=x(3);
time=[hora*3600 (hora+3)*3600 (hora+6)*3600];
time=single(time);
lon1=lon0+X/111120;

lat1=lat0+Y/111120;

iso1=(1-2.25569*10^-5*Z)^5.2561*101325; 
T = interpn(time,iso,lat,lon,T,t,iso1,lat1,lon1);
P=mgas/mmolecular/VB*8.314*T;
%breaking point%
sigmalimit=55*10e6;
th=2e-3;
% sigmalimit%import%
Pbreaking=sigmalimit*4*th/R;
value=Pbreaking-(P-iso1);
value=Z-29785;
value=round(value);
isterminal=1;
direction=0;
end


