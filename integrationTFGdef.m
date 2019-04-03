function [ dx ] = integrationTFGdef(t,x,g,Vwx,Vwy,mt,lon0,lat0,lon,lat,iso,mgas,mmolecular,T,hora,nn,RHe,R0,h0,R,T0)
%%Variable definition for ODE%%
X=x(1);
Y=x(2);
Z=x(3);
Vbx=x(4);
Vby=x(5);
Vbz=x(6);
time=[hora*3600 (hora+3)*3600 (hora+6)*3600];
time=single(time);
lon1=lon0+X/111120;
lat1=lat0+Y/111120;
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
%% CON TEMPERATURA
syms n
kappa = 0.13;
cp = 5192.6;
rcoord = 0.9;
mu = 300e3;
alpha = 10/11;
VB = 4/3*pi*R^3; %Volumen inicial Globo%
mgas = VB*100000*mmolecular/8.314/288.15; %Masa interior Globo%
D = VB/mgas*kappa/cp;
AA = D*pi^2*n^2/R^2;
if Z < 11000
    VALOR = (288.04*AA*(exp(AA*t)-1)-0.00649*Vbz*(exp(AA*t)*(AA*t-1)+1))/AA^2;
end
if Z >= 11000 && Z < 25000
    VALOR = 216.54*(exp(AA*t)-1)/AA;
end
if Z >= 25000
    VALOR = (141.79*AA*(exp(AA*t)-1)+0.00299*Vbz*(exp(AA*t)*(AA*t-1)+1))/AA^2;
end
T_inside = sym2poly(2/rcoord*symsum((T0/(n^2*pi^2)*(sin(n*pi)-n*pi*cos(n*pi)) + (pi*D/R^2*n*(-1)^(n+1)*VALOR))*exp(-D*(pi*n/R)^2*t)*sin(pi*n*rcoord), n, 1, 250));

% Mooney-Rivlin model
A = iso1;
B = nn*RHe*T_inside/(4*pi/3);
C = 2*mu*h0/R0;
E = (1-alpha)/alpha;
polyn = [A C*R0 0 C*E*R0^3-B 0 0 0 -C*R0^7 0 -C*E*R0^9];
rootsp = roots(polyn);
for j = 1:numel(rootsp)+1
    if j < numel(rootsp)+1
        if isreal(rootsp(j)) == 1 && rootsp(j) > 0
            R = real(rootsp(j));
        end
    end
end

VB=4/3*pi*R^3;

%% Radio - Ogden model
% A = iso1;
% B = nn*RHe*T_inside/(4*pi/3);
% C = 2*h0/R0;
% E = 630000;
% F = 1200;
% G = -10000;
% polyn = [F 0 R0^2*A/C E*R0^4 0 -R0^2*B/C 0 G*R0^7-E*R0^8 0 0 0 -G*R0 0 0 0 -F*R0^15];
% rootsp = roots(polyn);
% for j = 1:numel(rootsp)+1
%     if j < numel(rootsp)+1
%         if isreal(rootsp(j)) == 1 && rootsp(j) > 0
%             R = real(rootsp(j));
%         end
%      end
% end

% VB=4/3*pi*R^3;

%% SIN TEMPERATURA
% VB=mgas/mmolecular*8.314*T/iso1;
% R=(VB*3/4*pi)^(1/3);
%%
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