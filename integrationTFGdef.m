function [ dx ] = integrationTFGdef(t,x,Vwx,Vwy,mt,lon0,lat0,lon,lat,iso,mgas,mmolecular,T,hora)
%%Variable definition for ODE%%
X=x(1);
Y=x(2);
Z=x(3);
Vbx=x(4);
Vby=x(5);
Vbz=x(6);
g=(3.9820e+14/(6.375e6+Z)^2);
time=[hora*3600 (hora+3)*3600 (hora+6)*3600];
time=single(time);
lat1=lat0+Y/111120;
lon1=lon0+X/(111120*abs(cosd(lat1)));
iso1=((1-2.25569*10^-5*Z)^5.25619)*100000; 
%%Interp velocity%%
Vwxx = interpn(time,iso,lat,lon,Vwx,t,iso1,lat1,lon1);
Vwyy = interpn(time,iso,lat,lon,Vwy,t,iso1,lat1,lon1);
Vwzz = 0;
T = interpn(time,iso,lat,lon,T,t,iso1,lat1,lon1);
Vw=[Vwxx Vwyy Vwzz];
%3D coordinate system (xb,yb,zb) (vbx,vby,vbz)%
%wind velocity (vwx,vwy,vwz)%
%Cd effective drag coefficient%
%Cy effective side force coefficient%
rhoa=iso1*(28.9e-3)/T/8.314;
VB=mgas/mmolecular*8.314*T/iso1;
R=(VB*3/4*pi)^(1/3);
Vb=[Vbx Vby Vbz];
Cd=0.5;
%Cy=0.47;
Cy= 0; %If balloon shape changes so will the coefficient, appearing a lateral force perpendicular to the drag, something equivalent to lift%
Cm=0.3;%virtual mass coefficient 0.25 to 0.5%
Aballoon=2*pi*R^2;
Veff=Vb-Vw;
mv=mt+Cm*rhoa*VB;%mt, added mass determined by the direction of the acceleration Cm 0.5 for a sphere or 0.4-0.65%
Vww=Vw-Vb;
Vmodule=norm(Vww);
alpha=atan2(norm(cross(Veff,[0 0 1])),dot(Veff,[0 0 1]));%alpha balloon angle of attack%
orth=(Vw-Vb)-(dot((Vw-Vb),[0 0 1]))*[0 0 1];%orthogonal projection over xy plane%
phi=atan2(norm(cross([1 0 0],orth)),dot([1 0 0],orth));%phi angle between i and the projection of (vw-vb) over xy plane%
Fd=0.5*rhoa*(norm(Vmodule))^2*Cd*Aballoon;%parallel to wind velocity%
Fl=0.5*rhoa*(norm(Vmodule))^2*Cy*Aballoon;%perpendicular to wind velocity%
Fx=-abs((Fd*sin(alpha)+Fl*cos(alpha))*cos(phi))*Veff(1)/abs(Veff(1));
Fy=-abs((Fd*sin(alpha)+Fl*cos(alpha))*sin(phi))*Veff(2)/abs(Veff(2));
Fdz=-0.5*rhoa*(Vbz)^2*Cd*Aballoon;
dVbxdt=Fx/mv;
dVbydt=Fy/mv;
dVbzdt=(((rhoa)*VB-mt)*g+Fdz)/mv;
dx=[Vbx;Vby;Vbz;dVbxdt;dVbydt;dVbzdt];
end


