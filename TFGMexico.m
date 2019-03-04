clc 
clear all 
close all
tic
run setup_nctoolbox.m
%% Condiciones iniciales modificables %%
mp=5.4; %mp m payload, suspended mass%
deltaT=20;
mb=0.3; %mb m balloon material%
R=1.1;  %Radio inicial Globo Aproximado%
lat0=38.936;%dato exacto de la latitud%
lon0=353.41;%dato exacto de longitud positivo%
Zi=900; %Altitud sobre el nivel del mar%
year='2018';%año de vuelo%
month='02';%mes de vuelo%
day='08';%etc%
hour=0;
minute=0;
segundos=0;
run extraer.m
%% Condiciones Iniciales No Tocar %%
T0=288.15+deltaT; %Temperatura inicial ISA DetlaT=0%
rhog=0.17; %Densidad Gas interior%
g=9.81; %constante gravitatoria%
mg=mb+mp;   %gross system mass% 
VB=4/3*pi*R^3; %Volumen inicial Globo%
mmolecular=4e-3;   %Masa molecular gas%
mgas=VB*100000*mmolecular/8.314/288.15; %Masa interior Globo%
mt=mg+mgas; %total mass%
iso0=100000;%Referencia inical de pressure-altitude%
Xi=0; %Referencia%
Yi=0;   %Referencia%
%% Inicializar Codigo %%
run setup_nctoolbox.m; %programa para leer gribdata%
Mainwinddata1 %Variable definition of wind speeds and Temperatures%
[iso lat lon] = WindData2(['Hora' num2str(hora,'%03d') '.grb2']);%Definition of grid points from gribdata%
initialconditions=[Xi;Yi;Zi;0;0;0];%Latitude Longitude Altitude%
deltaT=0;%variacion de temperatura con respecto a ISA standard%
Simplificationdef%Reduction of all data to a manageable window of datapoints%
secc=hour+minute*60+segundos;%Tiempo inicial vuelo en segundos desde prediccion hecha a las doce de la mañana%
seccf=18000+secc;%Tiempo final de vuelo de globo asumiendo maximo cinco horas%
%% Integracion Datos y Plot %%
%[t,x]=ode23(@(t,x) integrationTFGdef(t,x,g,Vwx,Vwy,mt,lon0,lat0,lon,lat,iso,mgas,mmolecular,T,hora),[secc:1:seccf], initialconditions);
opts=odeset('Events',@(t,x) myEventFcn(t,x,T,iso,lat,lon,mgas,mmolecular,VB,R,lon0,lat0,hora));
[t,x,te,xe,ie]=ode23(@(t,x) integrationTFGdef(t,x,g,Vwx,Vwy,mt,lon0,lat0,lon,lat,iso,mgas,mmolecular,T,hora), [secc:1:seccf], initialconditions,opts);
toc
plot(x(:,1),x(:,2))
title('Trayectoria del globo en el plano xy')
xlabel('Distancia en el eje x con respecto a la longitud inicial [m]')
ylabel('Distancia en el eje y con respecto a la latitud inicial [m]')
figure
plot(t,x(:,3))
title('Altura del globo con respecto al tiempo')
xlabel('Tiempo [s]')
ylabel('Altura [m]')
