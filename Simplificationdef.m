k=12;
%size of the window to get data , default 7%
Vwxx=zeros(3,31,2*k+1,2*k+1);
Vwyy=zeros(3,31,2*k+1,2*k+1);
Vwzz=zeros(3,31,2*k+1,2*k+1);
TT=zeros(3,31,2*k+1,2*k+1);
[minii,latpos]=min(abs(lat-lat0));
[miniii,lonpos]=min(abs(lon-lon0));
Vwxx(:,:,:,:)=Vwx(:,:,latpos-k:latpos+k,lonpos-k:lonpos+k);
Vwyy(:,:,:,:)=Vwy(:,:,latpos-k:latpos+k,lonpos-k:lonpos+k);
Vwzz(:,:,:,:)=Vwz(:,:,latpos-k:latpos+k,lonpos-k:lonpos+k);
TT(:,:,:,:)=T(:,:,latpos-k:latpos+k,lonpos-k:lonpos+k);

    


Vwx=Vwxx;
Vwy=Vwyy;
Vwz=Vwzz;
T=TT;
latt=lat(latpos-k:latpos+k);
lat=single(latt);
lonn=lon(lonpos-k:lonpos+k);
lon=single(lonn);

