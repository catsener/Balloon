%Main winddata%%

[Vwx1 Vwy1 Vwz1 T1] = TriWind(['Hora' num2str(hora,'%03d') '.grb2']);

[Vwx2 Vwy2 Vwz2 T2] = TriWind(['Hora' num2str(hora+3,'%03d') '.grb2']);

[Vwx3 Vwy3 Vwz3 T3] = TriWind(['Hora' num2str(hora+6,'%03d') '.grb2']);


Vwx=zeros(3,31,361,720);
Vwy=zeros(3,31,361,720);
Vwz=zeros(3,31,361,720);
T=zeros(3,31,361,720);
Vwx(1,:,:,:)=Vwx1(:,:,:);
Vwx(2,:,:,:)=Vwx2(:,:,:);
Vwx(3,:,:,:)=Vwx3(:,:,:);
Vwy(1,:,:,:)=Vwy1(:,:,:);
Vwy(2,:,:,:)=Vwy2(:,:,:);
Vwy(3,:,:,:)=Vwy3(:,:,:);
Vwz(1,:,:,:)=Vwz1(:,:,:);
Vwz(2,:,:,:)=Vwz2(:,:,:);
Vwz(3,:,:,:)=Vwz3(:,:,:);
T(1,:,:,:)=T1(:,:,:);
T(2,:,:,:)=T2(:,:,:);
T(3,:,:,:)=T3(:,:,:);