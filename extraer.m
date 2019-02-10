
if hour>=0 && hour<=3
    hora=0;
elseif hour>3 && hour<=6
    hora=3;
elseif hour>6 && hour<=9
    hora=6;
elseif hour>9 && hour<=12
    hora=9;
elseif hour>12 && hour<=15
    hora=12;
elseif hour>15 && hour<=18
    hora=15;
elseif hour>18 && hour<=21
    hora=18;
elseif hour>21 && hour<=24
    hora=21;
end

horacio = hora;
diacio = day;






if exist(['Hora' num2str(hora,'%03d') '.grb2'])==0 || exist(['Hora' num2str(hora+3,'%03d') '.grb2'])==0 || exist(['Hora' num2str(hora+6,'%03d') '.grb2'])==0     
    while day - diacio < 8
    try
    mw = ftp('nomads.ncdc.noaa.gov');
    cd(mw, ['GFS/Grid4/' year month '/' year month diacio]);
    if isempty(dir(mw,['gfs_4_' year month diacio '_0000_' num2str(horacio,'%03d') '.grb2']))
        diacio = diacio - 1;
        horacio = horacio + 24; 
    end
    catch
        disp('Error, trying again...')
    end
    end
    hora = horacio;
    day = diacio;

while exist('files_stored_as')==0 || exist('files_stored_as1')==0 || exist('files_stored_as2')==0 
    if exist('files_stored_as')==0
        try
            mw = ftp('nomads.ncdc.noaa.gov');
            cd(mw, ['GFS/Grid4/' year month '/' year month day]);
            files_stored_as = mget(mw, ['gfs_4_' year month day '_0000_' num2str(hora,'%03d') '.grb2']);
        catch 
            disp('error importing file');
            disp('Retrying............');
        end
        movefile(['gfs_4_' year month day '_0000_' num2str(hora,'%03d') '.grb2'],['Hora' num2str(hora,'%03d') '.grb2']);
    end
    if exist('files_stored_as1')==0
        try
            hora = hora+3;
            if num2str(hora)==24
                hora=0;
            end
            
            
            mw = ftp('nomads.ncdc.noaa.gov');
            cd(mw, ['GFS/Grid4/' year month '/' year month day]);
            files_stored_as1 = mget(mw, ['gfs_4_' year month day '_0000_' num2str(hora,'%03d') '.grb2']);
        catch 
        disp('error importing file');
        disp('Retrying............');
        end
        movefile(['gfs_4_' year month day '_0000_' num2str(hora,'%03d') '.grb2'],['Hora' num2str(hora,'%03d') '.grb2']);
    end
    if exist('files_stored_as2')==0
        try
            hora = hora+3;
            if num2str(hora)==24
                hour=0;
            end
            
            mw = ftp('nomads.ncdc.noaa.gov');
            cd(mw, ['GFS/Grid4/' year month '/' year month day]);
            files_stored_as2 = mget(mw, ['gfs_4_' year month day '_0000_' num2str(hora,'%03d') '.grb2']);
        catch 
        disp('error importing file');
        disp('Retrying............');
        end
        movefile(['gfs_4_' year month day '_0000_' num2str(hora,'%03d') '.grb2'],['Hora' num2str(hora,'%03d') '.grb2']);
    end
end
end
