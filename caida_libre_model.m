function [dx]=caida_libre_model(t,x,Vwx,Vwy,lon0,lat0,lon,lat,iso,hora)
%definition of the Ordinary differential equation variables
X=x(1);
Y=x(2);
Z=x(3);
Vbx=x(4);
Vby=x(5);
Vbz=x(6);
Vb=[Vbx Vby Vbz];
%Time at which the experiment is carried for the NOAA data extraction
time=[hora*3600 (hora+3)*3600 (hora+6)*3600];
time=single(time);
%latitude and longitude of the balloon at each instant
lat1=lat0+Y/111120;
lon1=lon0+X/(111120*abs(cosd(lat1)));
%atmospheric pressure at the altitude of study
iso1=((1-2.25569*10^-5*Z)^5.25619)*100000;
%wind velocity components at each instant in tieme
Vwxx = interpn(time,iso,lat,lon,Vwx,t,iso1,lat1,lon1);
Vwyy = interpn(time,iso,lat,lon,Vwy,t,iso1,lat1,lon1);
Vwzz = 0;
Vw=[Vwxx Vwyy Vwzz];
%Calculation of effective wind in balloon 
Veff=Vb-Vw;
Vmodule=norm(Veff);
% angles for the direction of the effective wind to put the forces
alpha=atan2(norm(cross(Veff,[0 0 1])),dot(Veff,[0 0 1]));%alpha balloon angle of attack%
orth=(Vw-Vb)-(dot((Vw-Vb),[0 0 1]))*[0 0 1];%orthogonal projection over xy plane%
phi=atan2(norm(cross([1 0 0],orth)),dot([1 0 0],orth));%phi angle between i and the projection of (vw-vb) over xy plane%
%accelerations, only gravity as free fall considered
ax=0;
ay=0;
az=-3.9820e+14/(6.375e6+Z)^2; %gravity which varies with height
dx=[Vbx;Vby;Vbz;ax;ay;az];
