clear;


fullname2 = 'G:\SIOLAprocessingTest\3080eiz80001 (2).adb';
F2 = fopen(fullname2, 'rb');

fseek(F2, 0, 'bof');
head = fread(F2, 256);
fclose(F2);


fullname1 = 'C:\Users\Artyom\Documents\MATLAB\Bandpass6_16fs100o6.mat';
sp_per = struct2cell(load(fullname1));
used_filter = sp_per{1};


pathToDir = 'G:\SIOLAprocessingTest\100 Hz november 2016 extra\';
list = dir(pathToDir);

pathToDirOfDetectionList = 'F:\100 Hz november 2016 array network plus\network\';
listOfDetectionList = dir(pathToDirOfDetectionList);

% FileInitTimeString = '2016-08-04_15-00-00';
% DetectSample = 214855;

for kkkkk = 3:1:length(listOfDetectionList)

    listOfDetectionList1 = dir([pathToDirOfDetectionList listOfDetectionList(kkkkk).name]);
    for kkkkkk = 3:1:length(listOfDetectionList1)
        if listOfDetectionList1(kkkkkk).isdir ==0
    FileInitTimeString = listOfDetectionList1(kkkkkk).name(15:33);
    DetectSampleBegin = findstr(listOfDetectionList1(kkkkkk).name, '_sample_') + 8;
    DetectSampleEnd = findstr(listOfDetectionList1(kkkkkk).name, '_time_') - 1;
    DetectSample = str2num(listOfDetectionList1(kkkkkk).name(DetectSampleBegin:DetectSampleEnd));
    
for kkk=3:length(list)
    
    if list(kkk).isdir() ~= 0
        list1 = dir([pathToDir list(kkk).name]);
        for kk = 3:length(list1)
            if strcmp(list1(kk).name, 'p1') == 1
                list2 = dir([pathToDir list(kkk).name '\' list1(kk).name '\']);
                for kkkk = 3:1:length(list2)
                    fname3 = [pathToDir list(kkk).name '\' list1(kk).name '\' list2(kkkk).name];
                    if strcmp(list2(kkkk).name(14:32), FileInitTimeString) == 1
       
        
        



[X,I] = rdmseed(fname3);  % p1

p0filename = list2(kkkk).name;
p0filename(11:12) = 'p0';

p2filename = list2(kkkk).name;
p2filename(11:12) = 'p2';



[Xp0,Ip0] = rdmseed([pathToDir list(kkk).name '\' 'p0' '\' p0filename]);
[Xp2,Ip2] = rdmseed([pathToDir list(kkk).name '\' 'p2' '\' p2filename]);

Number_of_channels = 3;


    k = Ip0(1).XBlockIndex;
    xxP0 = cat(1,Xp0(k).t);
    Ap0 = cat(1,Xp0(k).d);

    k = I(1).XBlockIndex;
    xx = cat(1,X(k).t);
    A1 = cat(1,X(k).d);

    k = Ip2(1).XBlockIndex;
    xxP2 = cat(1,Xp2(k).t);
    Ap2 = cat(1,Xp2(k).d);



l = zeros(1,3);
l(1) = length(Ap0);
l(2) = length(A1);
l(3) = length(Ap2);

l1 = zeros(1,3);
l1(1) = xxP0(1);
l1(2) = xx(1);
l1(3) = xxP2(1);
l1max = l1(1);
if (l1(1)~=l1(2) | l1(2)~=l1(3) | l1(1)~=l1(3))
    for i = 1:1:3
        if l1(i) > l1max
            l1max = l1(i);
        end
    end
    for i=1:1:length(xx{1})
        if xx{1}(i) == l1max
            l11start = i;
        end
    end
    for i=1:1:length(xx{2})
        if xx{2}(i) == l1max
            l12start = i;
        end
    end
    for i=1:1:length(xx{3})
        if xx{3}(i) == l1max
            l13start = i;
        end
    end
else
    l11start = 1;
    l12tstart = 1;
    l13start = 1;
end

lmin = l(1);
if (l1(1)==l1(2) & l1(2)==l1(3) & l1(1)==l1(3))
    if (l(1)~=l(2) | l(2)~=l(3) | l(1)~=l(3))
        lmin = l(1);
        for i = 1:1:3
            if l(i) < lmin
                lmin = l(i);
            end
        end
    end
end


if (l1(1)~=l1(2) | l1(2)~=l1(3) | l1(1)~=l1(3))
    lengthOfFragment = length(A1{1}) - l11start;
end
if (l1(1)==l1(2) & l1(2)==l1(3) & l1(1)==l1(3))
   
        lengthOfFragment = lmin - 1;
    
end

DVec = datevec(l1max);
DateTimeInit = strcat(num2str(DVec(1)), '-', num2str(DVec(2)), '-', num2str(DVec(3)), '_', num2str(DVec(4)), '-', num2str(DVec(5)), '-',...
    num2str(DVec(6)));
fname_template = strcat(list2(kkkk).name(1:10), list2(kkkk).name(14:length(list2(kkkk).name)-6));
Number_of_channels = 3;
ChannelSampleNumber = lengthOfFragment;
Begin_year = DVec(1);
Begin_month = DVec(2);
Begin_day = DVec(3);
Begin_hour = DVec(4);
Begin_minute = DVec(5);
Begin_second = floor(DVec(6));
Begin_millisecond = (DVec(6) - floor(DVec(6)))*1000;
SampleRate = X(1,1).SampleRate;

count = zeros(1,3);
Samples = cell(1,3);
Samples_seconds = cell(1,3);
Samples_hours = cell(1,3);
Samples_minutes = cell(1,3);
Samples_abshour = cell(1,3);
Samples_absminute = cell(1,3);
Samples_abssecond = cell(1,3);
Samples_abs_day = cell(1,3);
Samples_abssecond_drob = cell(1,3);


AA = cell(1,3);
A = cell(1,3);
if (l1(1)~=l1(2) | l1(2)~=l1(3) | l1(1)~=l1(3))
    A{1} = detrend(Ap0(l11start:end));
    A{2} = detrend(A1(l12start:end));
    A{3} = detrend(Ap2(l13start:end));
end
if (l1(1)==l1(2) & l1(2)==l1(3) & l1(1)==l1(3))
    A{1} = detrend(Ap0(1:lmin));
    A{2} = detrend(A1(1:lmin));
    A{3} = detrend(Ap2(1:lmin));
end
clear A1;
AA{1} = filter(used_filter, A{1});  % 
AA{2} = filter(used_filter, A{2});  %
AA{3} = filter(used_filter, A{3});  % 


Samples{2}(1) = DetectSample;



mkdir(pathToDir, 'filtered');
mkdir(strcat(pathToDir, 'filtered') ,strcat('Channel','2'));
mkdir(strcat(pathToDir, 'filtered\Channel', '2'), 'adb');
mkdir(strcat(pathToDir, 'filtered\Channel', '2'), 'fig');
mkdir(strcat(pathToDir, 'filtered\Channel', '2'), 'mat');
mkdir(strcat(pathToDir, 'filtered\Channel', '2'), 'mseed');
    
for j = 2:1:2
    
    folder_name_adb{j} = strcat(pathToDir, 'filtered\Channel', num2str(j), '\', 'adb');%uigetdir;
    folder_name_fig{j} = strcat(pathToDir, 'filtered\Channel', num2str(j), '\', 'fig');
    folder_name_mat{j} = strcat(pathToDir, 'filtered\Channel', num2str(j), '\', 'mat');
    
    for i = 1:1:length(Samples{j})
        if (Samples{j}(i) > 90*SampleRate && Samples{j}(i)  < length(AA{j}) - 3*60*SampleRate)
            
            h = figure('visible', 'on');
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:90*SampleRate + 3*60*SampleRate)/SampleRate)', AA{t}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i) + 3*60*SampleRate));
            end
            
            grid on
            xlabel('Sec')
            
            Samples_abssecond{j}(i) = Begin_second + (Samples{j}(i) - 90*SampleRate)/SampleRate + Begin_millisecond/1000; 
            Samples_absminute{j}(i) = fix(Begin_minute + Samples_abssecond{j}(i)/60);
            Samples_abshour{j}(i) = fix(Begin_hour + Samples_absminute{j}(i)/60);
            Samples_abs_day{j}(i) = fix(Begin_day + Samples_abshour{j}(i)/24);
            
            Samples_abshour{j}(i) =  Samples_abshour{j}(i) - fix(Samples_abshour{j}(i)/24)*24;
            Samples_absminute{j}(i) = Samples_absminute{j}(i) - fix(Samples_absminute{j}(i)/60)*60;
            Samples_abssecond{j}(i) = vpa(Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)/60)*60, 4);
            
            Samples_abssecond_drob{j}(i) = (Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)))*1000;
            
            
                                
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = AA{t}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate);
            end
            save(file_name_mat, 's', '-mat');
            clear s;
            
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            F = fopen(file_name_adb, 'wb');
            
            fseek(F, 0, 'bof');
            fwrite(F, head);
            
            fseek(F, 44, 'bof');
            fwrite(F, Begin_year, 'integer*2');
            fseek(F, 46, 'bof');
            fwrite(F, Begin_month, 'integer*2');
            fseek(F, 48, 'bof');
            fwrite(F, Samples_abs_day{j}(i), 'integer*2');
            fseek(F, 50, 'bof');
            fwrite(F, Samples_abshour{j}(i), 'integer*2'); 
            fseek(F, 52, 'bof');
            fwrite(F, Samples_absminute{j}(i), 'integer*2');
            fseek(F, 54, 'bof');
            fwrite(F, fix(Samples_abssecond{j}(i)), 'integer*2');
            fseek(F, 56, 'bof');
            fwrite(F, Samples_abssecond_drob{j}(i), 'integer*2'); 
            lengthOfFragment1 = length(AA{1}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate))-1;
            fseek(F, 58, 'bof');
            fwrite(F, X(1,1).SampleRate, 'integer*2');
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment1, 'integer*4');

            fseek(F, 256, 'bof');
            s = horzcat(AA{1}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate), AA{2}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate), AA{3}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
            
            DVectForsave = [Begin_year Begin_month Samples_abs_day{j}(i) Samples_abshour{j}(i) Samples_absminute{j}(i) fix(Samples_abssecond{j}(i))+Samples_abssecond_drob{j}(i)/1000];
            DVectForsaveString = strcat(num2str(Begin_year), '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)));
            T0 = datenum(DVectForsave(1), DVectForsave(2), DVectForsave(3), DVectForsave(4), DVectForsave(5), DVectForsave(6));
            mkdir(strcat(pathToDir, 'filtered\Channel', num2str(j), '\mseed'), DVectForsaveString);
            folder_name_mseed{j} = strcat(pathToDir, 'filtered\Channel', num2str(j), '\', 'mseed', '\', DVectForsaveString, '\');
            FILENAMEN = strcat(folder_name_mseed{j}, 'SI.',X(1).StationIdentifierCode,'.LC.00N.D');
            FILENAMEZ = strcat(folder_name_mseed{j}, 'SI.',Xp0(1).StationIdentifierCode,'.LC.00Z.D');
            FILENAMEE = strcat(folder_name_mseed{j}, 'SI.',Xp2(1).StationIdentifierCode,'.LC.00E.D');

            FS = SampleRate;
            D1 = AA{1}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate);
            D2 = AA{2}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate);
            D3 = AA{3}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate);


            mkmseed(FILENAMEZ,D1,T0,FS,3)
            mkmseed(FILENAMEN,D2,T0,FS,3)
            mkmseed(FILENAMEE,D3,T0,FS,3)
                        
    
        elseif (Samples{j}(i)  > 90*SampleRate && Samples{j}(i)  > length(AA{j}) - 3*60*SampleRate)
            
            h = figure('visible', 'on');
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:length(AA{j}) - Samples{j}(i)  + 90*SampleRate)/SampleRate)', AA{t}(Samples{j}(i)  - 90*SampleRate +1:length(AA{j})));
            end
            
            grid on
            xlabel('Sec')
            
            Samples_abssecond{j}(i) = Begin_second + (Samples{j}(i) - 90*SampleRate)/SampleRate + Begin_millisecond/1000; 
            Samples_absminute{j}(i) = fix(Begin_minute + Samples_abssecond{j}(i)/60);
            Samples_abshour{j}(i) = fix(Begin_hour + Samples_absminute{j}(i)/60);
            Samples_abs_day{j}(i) = fix(Begin_day + Samples_abshour{j}(i)/24);
            
            Samples_abshour{j}(i) =  Samples_abshour{j}(i) - fix(Samples_abshour{j}(i)/24)*24;
            Samples_absminute{j}(i) = Samples_absminute{j}(i) - fix(Samples_absminute{j}(i)/60)*60;
            Samples_abssecond{j}(i) = vpa(Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)/60)*60, 4);
            
            Samples_abssecond_drob{j}(i) = (Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)))*1000;
            

            
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = AA{t}(Samples{j}(i)  - 90*SampleRate +1:length(AA{j}));
            end
            save(file_name_mat, 's', '-mat');
            clear s;
            
            
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            F = fopen(file_name_adb, 'wb');
            fseek(F, 0, 'bof');
            fwrite(F, head);
            
            fseek(F, 44, 'bof');
            fwrite(F, Begin_year, 'integer*2');
            fseek(F, 46, 'bof');
            fwrite(F, Begin_month, 'integer*2');
            fseek(F, 48, 'bof');
            fwrite(F, Samples_abs_day{j}(i), 'integer*2');
            fseek(F, 50, 'bof');
            fwrite(F, Samples_abshour{j}(i), 'integer*2'); 
            fseek(F, 52, 'bof');
            fwrite(F, Samples_absminute{j}(i), 'integer*2');
            fseek(F, 54, 'bof');
            fwrite(F, fix(Samples_abssecond{j}(i)), 'integer*2');
            fseek(F, 56, 'bof');
            fwrite(F, Samples_abssecond_drob{j}(i), 'integer*2'); 
            lengthOfFragment1 = length(AA{t}(Samples{j}(i)  - 90*SampleRate +1:length(AA{j})))-1;
            fseek(F, 58, 'bof');
            fwrite(F, X(1,1).SampleRate, 'integer*2');
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment1, 'integer*4');
            
            fseek(F, 256, 'bof');
            s = horzcat(AA{1}(Samples{j}(i)  - 90*SampleRate +1:length(AA{j})), AA{2}(Samples{j}(i)  - 90*SampleRate +1:length(AA{j})), AA{3}(Samples{j}(i)  - 90*SampleRate +1:length(AA{j})));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
            
            DVectForsave = [Begin_year Begin_month Samples_abs_day{j}(i) Samples_abshour{j}(i) Samples_absminute{j}(i) fix(Samples_abssecond{j}(i))+Samples_abssecond_drob{j}(i)/1000];
           DVectForsaveString = strcat(num2str(Begin_year), '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)));
            T0 = datenum(DVectForsave(1), DVectForsave(2), DVectForsave(3), DVectForsave(4), DVectForsave(5), DVectForsave(6));
            mkdir(strcat(pathToDir, 'filtered\Channel', num2str(j), '\mseed'), DVectForsaveString);
            folder_name_mseed{j} = strcat(pathToDir, 'filtered\Channel', num2str(j), '\', 'mseed', '\', DVectForsaveString, '\');
            FILENAMEN = strcat(folder_name_mseed{j}, 'SI.',X(1).StationIdentifierCode,'.LC.00N.D');
            FILENAMEZ = strcat(folder_name_mseed{j}, 'SI.',Xp0(1).StationIdentifierCode,'.LC.00Z.D');
            FILENAMEE = strcat(folder_name_mseed{j}, 'SI.',Xp2(1).StationIdentifierCode,'.LC.00E.D');

            FS = SampleRate;
            D1 = AA{1}(Samples{j}(i)  - 90*SampleRate +1:length(AA{1}));
            D2 = AA{2}(Samples{j}(i)  - 90*SampleRate +1:length(AA{2}));
            D3 = AA{3}(Samples{j}(i)  - 90*SampleRate +1:length(AA{3}));


            mkmseed(FILENAMEZ,D1,T0,FS,3)
            mkmseed(FILENAMEN,D2,T0,FS,3)
            mkmseed(FILENAMEE,D3,T0,FS,3)
            
        elseif (Samples{j}(i)   < 90*SampleRate && Samples{j}(i)  < length(AA{j}) - 3*60*SampleRate)
            
            h = figure('visible', 'on');
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:Samples{j}(i)  + 3*60*SampleRate)/SampleRate)', AA{t}(1:Samples{j}(i)  + 3*60*SampleRate));
            end
           
            grid on
            xlabel('Sec')
            
            Samples_abssecond{j}(i) = Begin_second + Begin_millisecond/1000; 
            Samples_absminute{j}(i) = fix(Begin_minute + Samples_abssecond{j}(i)/60);
            Samples_abshour{j}(i) = fix(Begin_hour + Samples_absminute{j}(i)/60);
            Samples_abs_day{j}(i) = fix(Begin_day + Samples_abshour{j}(i)/24);
            
            Samples_abshour{j}(i) =  Samples_abshour{j}(i) - fix(Samples_abshour{j}(i)/24)*24;
            Samples_absminute{j}(i) = Samples_absminute{j}(i) - fix(Samples_absminute{j}(i)/60)*60;
            Samples_abssecond{j}(i) = vpa(Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)/60)*60, 4);
            
            Samples_abssecond_drob{j}(i) = (Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)))*1000;
            

            
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = AA{t}(1:Samples{j}(i)  + 3*60*SampleRate);
            end
            save(file_name_mat, 's', '-mat');
            clear s;
            
            
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            F = fopen(file_name_adb, 'wb');
            fseek(F, 0, 'bof');
            fwrite(F, head);
            
             fseek(F, 44, 'bof');
            fwrite(F, Begin_year, 'integer*2');
            fseek(F, 46, 'bof');
            fwrite(F, Begin_month, 'integer*2');
            fseek(F, 48, 'bof');
            fwrite(F, Samples_abs_day{j}(i), 'integer*2');
            fseek(F, 50, 'bof');
            fwrite(F, Samples_abshour{j}(i), 'integer*2'); 
            fseek(F, 52, 'bof');
            fwrite(F, Samples_absminute{j}(i), 'integer*2');
            fseek(F, 54, 'bof');
            fwrite(F, fix(Samples_abssecond{j}(i)), 'integer*2');
            fseek(F, 56, 'bof');
            fwrite(F, Samples_abssecond_drob{j}(i), 'integer*2'); 
            lengthOfFragment1 = length(AA{t}(1:Samples{j}(i)  + 3*60*SampleRate))-1;
            fseek(F, 58, 'bof');
            fwrite(F, X(1,1).SampleRate, 'integer*2');
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment1, 'integer*4');
            
            fseek(F, 256, 'bof');
            s = horzcat(AA{1}(1:Samples{j}(i)  + 3*60*SampleRate), AA{2}(1:Samples{j}(i)  + 3*60*SampleRate), AA{3}(1:Samples{j}(i)  + 3*60*SampleRate));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
            
            DVectForsave = [Begin_year Begin_month Samples_abs_day{j}(i) Samples_abshour{j}(i) Samples_absminute{j}(i) fix(Samples_abssecond{j}(i))+Samples_abssecond_drob{j}(i)/1000];
            DVectForsaveString = strcat(num2str(Begin_year), '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)));
            T0 = datenum(DVectForsave(1), DVectForsave(2), DVectForsave(3), DVectForsave(4), DVectForsave(5), DVectForsave(6));
            mkdir(strcat(pathToDir, 'filtered\Channel', num2str(j), '\mseed'), DVectForsaveString);
            folder_name_mseed{j} = strcat(pathToDir, 'filtered\Channel', num2str(j), '\', 'mseed', '\', DVectForsaveString, '\');
            FILENAMEN = strcat(folder_name_mseed{j}, 'SI.',X(1).StationIdentifierCode,'.LC.00N.D');
            FILENAMEZ = strcat(folder_name_mseed{j}, 'SI.',Xp0(1).StationIdentifierCode,'.LC.00Z.D');
            FILENAMEE = strcat(folder_name_mseed{j}, 'SI.',Xp2(1).StationIdentifierCode,'.LC.00E.D');

            FS = SampleRate;
            D1 = AA{1}(1:Samples{j}(i)  + 3*60*SampleRate);
            D2 = AA{2}(1:Samples{j}(i)  + 3*60*SampleRate);
            D3 = AA{3}(1:Samples{j}(i)  + 3*60*SampleRate);


            mkmseed(FILENAMEZ,D1,T0,FS,3)
            mkmseed(FILENAMEN,D2,T0,FS,3)
            mkmseed(FILENAMEE,D3,T0,FS,3)
            
        end
    end
end


mkdir(pathToDir, 'unfiltered');
mkdir(strcat(pathToDir, 'unfiltered') ,strcat('Channel', '2'));
mkdir(strcat(pathToDir, 'unfiltered\Channel', '2'), 'adb');
mkdir(strcat(pathToDir, 'unfiltered\Channel', '2'), 'fig');
mkdir(strcat(pathToDir, 'unfiltered\Channel', '2'), 'mat');
mkdir(strcat(pathToDir, 'filtered\Channel', '2'), 'mseed');

for j = 2:1:2
    
    folder_name_adb{j} = strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\', 'adb');%uigetdir;
    folder_name_fig{j} = strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\', 'fig');
    folder_name_mat{j} = strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\', 'mat');
    for i = 1:1:length(Samples{j})
        if (Samples{j}(i)  > 90*SampleRate && Samples{j}(i)  < length(A{j}) - 3*60*SampleRate)
            
            h = figure('visible', 'on');
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:90*SampleRate + 3*60*SampleRate)/SampleRate)', A{t}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate));
            end
            
            grid on
            xlabel('Sec')
            
            Samples_abssecond{j}(i) = Begin_second + (Samples{j}(i) - 90*SampleRate)/SampleRate + Begin_millisecond/1000; 
            Samples_absminute{j}(i) = fix(Begin_minute + Samples_abssecond{j}(i)/60);
            Samples_abshour{j}(i) = fix(Begin_hour + Samples_absminute{j}(i)/60);
            Samples_abs_day{j}(i) = fix(Begin_day + Samples_abshour{j}(i)/24);
            
            Samples_abshour{j}(i) =  Samples_abshour{j}(i) - fix(Samples_abshour{j}(i)/24)*24;
            Samples_absminute{j}(i) = Samples_absminute{j}(i) - fix(Samples_absminute{j}(i)/60)*60;
            Samples_abssecond{j}(i) = vpa(Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)/60)*60, 4);
            
            Samples_abssecond_drob{j}(i) = (Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)))*1000;
            

            
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = A{t}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate);
            end
            save(file_name_mat, 's', '-mat');
            clear s;
            
            
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            F = fopen(file_name_adb, 'wb');
            fseek(F, 0, 'bof');
            fwrite(F, head);
            
            fseek(F, 44, 'bof');
            fwrite(F, Begin_year, 'integer*2');
            fseek(F, 46, 'bof');
            fwrite(F, Begin_month, 'integer*2');
            fseek(F, 48, 'bof');
            fwrite(F, Samples_abs_day{j}(i), 'integer*2');
            fseek(F, 50, 'bof');
            fwrite(F, Samples_abshour{j}(i), 'integer*2'); 
            fseek(F, 52, 'bof');
            fwrite(F, Samples_absminute{j}(i), 'integer*2');
            fseek(F, 54, 'bof');
            fwrite(F, fix(Samples_abssecond{j}(i)), 'integer*2');
            fseek(F, 56, 'bof');
            fwrite(F, Samples_abssecond_drob{j}(i), 'integer*2'); 
            lengthOfFragment1 = length(AA{1}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate))-1;
            fseek(F, 58, 'bof');
            fwrite(F, X(1,1).SampleRate, 'integer*2');
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment1, 'integer*4');
            
            fseek(F, 256, 'bof');
            s = horzcat(A{1}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate), A{2}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate), A{3}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
            
            DVectForsave = [Begin_year Begin_month Samples_abs_day{j}(i) Samples_abshour{j}(i) Samples_absminute{j}(i) fix(Samples_abssecond{j}(i))+Samples_abssecond_drob{j}(i)/1000];
            DVectForsaveString = strcat(num2str(Begin_year), '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)));
            T0 = datenum(DVectForsave(1), DVectForsave(2), DVectForsave(3), DVectForsave(4), DVectForsave(5), DVectForsave(6));
            mkdir(strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\mseed'), DVectForsaveString);
            folder_name_mseed{j} = strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\', 'mseed', '\', DVectForsaveString, '\');
            FILENAMEN = strcat(folder_name_mseed{j}, 'SI.',X(1).StationIdentifierCode,'.LC.00N.D');
            FILENAMEZ = strcat(folder_name_mseed{j}, 'SI.',Xp0(1).StationIdentifierCode,'.LC.00Z.D');
            FILENAMEE = strcat(folder_name_mseed{j}, 'SI.',Xp2(1).StationIdentifierCode,'.LC.00E.D');

            FS = SampleRate;
            D1 = A{1}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate);
            D2 = A{2}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate);
            D3 = A{3}(Samples{j}(i)  - 90*SampleRate +1:Samples{j}(i)  + 3*60*SampleRate);


            mkmseed(FILENAMEZ,D1,T0,FS,3)
            mkmseed(FILENAMEN,D2,T0,FS,3)
            mkmseed(FILENAMEE,D3,T0,FS,3)
                        
    
        elseif (Samples{j}(i)  > 90*SampleRate && Samples{j}(i)  > length(A{j}) - 3*60*SampleRate)
            
            h = figure('visible', 'on');
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:length(A{j}) - Samples{j}(i)  + 90*SampleRate)/SampleRate)', A{t}(Samples{j}(i)  - 90*SampleRate +1:length(A{j})));
            end
            
            grid on
            xlabel('Sec')
            
            Samples_abssecond{j}(i) = Begin_second + (Samples{j}(i) - 90*SampleRate)/SampleRate + Begin_millisecond/1000; 
            Samples_absminute{j}(i) = fix(Begin_minute + Samples_abssecond{j}(i)/60);
            Samples_abshour{j}(i) = fix(Begin_hour + Samples_absminute{j}(i)/60);
            Samples_abs_day{j}(i) = fix(Begin_day + Samples_abshour{j}(i)/24);
            
            Samples_abshour{j}(i) =  Samples_abshour{j}(i) - fix(Samples_abshour{j}(i)/24)*24;
            Samples_absminute{j}(i) = Samples_absminute{j}(i) - fix(Samples_absminute{j}(i)/60)*60;
            Samples_abssecond{j}(i) = vpa(Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)/60)*60, 4);
            
            Samples_abssecond_drob{j}(i) = (Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)))*1000;
            

            
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = A{t}(Samples{j}(i)  - 90*SampleRate +1:length(A{j}));
            end
            save(file_name_mat, 's', '-mat');
            clear s;
            
            
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            F = fopen(file_name_adb, 'wb');
            fseek(F, 0, 'bof');
            fwrite(F, head);
            
            fseek(F, 44, 'bof');
            fwrite(F, Begin_year, 'integer*2');
            fseek(F, 46, 'bof');
            fwrite(F, Begin_month, 'integer*2');
            fseek(F, 48, 'bof');
            fwrite(F, Samples_abs_day{j}(i), 'integer*2');
            fseek(F, 50, 'bof');
            fwrite(F, Samples_abshour{j}(i), 'integer*2'); 
            fseek(F, 52, 'bof');
            fwrite(F, Samples_absminute{j}(i), 'integer*2');
            fseek(F, 54, 'bof');
            fwrite(F, fix(Samples_abssecond{j}(i)), 'integer*2');
            fseek(F, 56, 'bof');
            fwrite(F, Samples_abssecond_drob{j}(i), 'integer*2'); 
            lengthOfFragment1 = length(A{t}(Samples{j}(i)  - 90*SampleRate +1:length(A{j})))-1;
            fseek(F, 58, 'bof');
            fwrite(F, X(1,1).SampleRate, 'integer*2');
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment1, 'integer*4');
            
            fseek(F, 256, 'bof');
            s = horzcat(A{1}(Samples{j}(i)  - 90*SampleRate +1:length(A{j})), A{2}(Samples{j}(i)  - 90*SampleRate +1:length(A{j})), A{3}(Samples{j}(i)  - 90*SampleRate +1:length(A{j})));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
            
            DVectForsave = [Begin_year Begin_month Samples_abs_day{j}(i) Samples_abshour{j}(i) Samples_absminute{j}(i) fix(Samples_abssecond{j}(i))+Samples_abssecond_drob{j}(i)/1000];
           DVectForsaveString = strcat(num2str(Begin_year), '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)));
            T0 = datenum(DVectForsave(1), DVectForsave(2), DVectForsave(3), DVectForsave(4), DVectForsave(5), DVectForsave(6));
            mkdir(strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\mseed'), DVectForsaveString);
            folder_name_mseed{j} = strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\', 'mseed', '\', DVectForsaveString, '\');
            FILENAMEN = strcat(folder_name_mseed{j}, 'SI.',X(1).StationIdentifierCode,'.LC.00N.D');
            FILENAMEZ = strcat(folder_name_mseed{j}, 'SI.',Xp0(1).StationIdentifierCode,'.LC.00Z.D');
            FILENAMEE = strcat(folder_name_mseed{j}, 'SI.',Xp2(1).StationIdentifierCode,'.LC.00E.D');

            FS = SampleRate;
            D1 = A{1}(Samples{j}(i)  - 90*SampleRate +1:length(A{1}));
            D2 = A{2}(Samples{j}(i)  - 90*SampleRate +1:length(A{2}));
            D3 = A{3}(Samples{j}(i)  - 90*SampleRate +1:length(A{3}));


            mkmseed(FILENAMEZ,D1,T0,FS,3)
            mkmseed(FILENAMEN,D2,T0,FS,3)
            mkmseed(FILENAMEE,D3,T0,FS,3)
            
        elseif (Samples{j}(i)   < 90*SampleRate && Samples{j}(i)  < length(A{j}) - 3*60*SampleRate)
            
            h = figure('visible', 'on');
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:Samples{j}(i)  + 3*60*SampleRate)/SampleRate)', A{t}(1:Samples{j}(i)  + 3*60*SampleRate));
            end
           
            grid on
            xlabel('Sec')
            
            Samples_abssecond{j}(i) = Begin_second + Begin_millisecond/1000; 
            Samples_absminute{j}(i) = fix(Begin_minute + Samples_abssecond{j}(i)/60);
            Samples_abshour{j}(i) = fix(Begin_hour + Samples_absminute{j}(i)/60);
            Samples_abs_day{j}(i) = fix(Begin_day + Samples_abshour{j}(i)/24);
            
            Samples_abshour{j}(i) =  Samples_abshour{j}(i) - fix(Samples_abshour{j}(i)/24)*24;
            Samples_absminute{j}(i) = Samples_absminute{j}(i) - fix(Samples_absminute{j}(i)/60)*60;
            Samples_abssecond{j}(i) = vpa(Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)/60)*60, 4);
            
            Samples_abssecond_drob{j}(i) = (Samples_abssecond{j}(i) - fix(Samples_abssecond{j}(i)))*1000;
            

            
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = A{t}(1:Samples{j}(i)  + 3*60*SampleRate);
            end
            save(file_name_mat, 's', '-mat');
            clear s;
            
            
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname_template, '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            F = fopen(file_name_adb, 'wb');
            fseek(F, 0, 'bof');
            fwrite(F, head);
            
             fseek(F, 44, 'bof');
            fwrite(F, Begin_year, 'integer*2');
            fseek(F, 46, 'bof');
            fwrite(F, Begin_month, 'integer*2');
            fseek(F, 48, 'bof');
            fwrite(F, Samples_abs_day{j}(i), 'integer*2');
            fseek(F, 50, 'bof');
            fwrite(F, Samples_abshour{j}(i), 'integer*2'); 
            fseek(F, 52, 'bof');
            fwrite(F, Samples_absminute{j}(i), 'integer*2');
            fseek(F, 54, 'bof');
            fwrite(F, fix(Samples_abssecond{j}(i)), 'integer*2');
            fseek(F, 56, 'bof');
            fwrite(F, Samples_abssecond_drob{j}(i), 'integer*2'); 
            lengthOfFragment1 = length(A{t}(1:Samples{j}(i)  + 3*60*SampleRate))-1;
            fseek(F, 58, 'bof');
            fwrite(F, X(1,1).SampleRate, 'integer*2');
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment1, 'integer*4');
            
            fseek(F, 256, 'bof');
            s = horzcat(A{1}(1:Samples{j}(i)  + 3*60*SampleRate), A{2}(1:Samples{j}(i)  + 3*60*SampleRate), A{3}(1:Samples{j}(i)  + 3*60*SampleRate));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
            
            DVectForsave = [Begin_year Begin_month Samples_abs_day{j}(i) Samples_abshour{j}(i) Samples_absminute{j}(i) fix(Samples_abssecond{j}(i))+Samples_abssecond_drob{j}(i)/1000];
            DVectForsaveString = strcat(num2str(Begin_year), '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)));
            T0 = datenum(DVectForsave(1), DVectForsave(2), DVectForsave(3), DVectForsave(4), DVectForsave(5), DVectForsave(6));
            mkdir(strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\mseed'), DVectForsaveString);
            folder_name_mseed{j} = strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\', 'mseed', '\', DVectForsaveString, '\');
            FILENAMEN = strcat(folder_name_mseed{j}, 'SI.',X(1).StationIdentifierCode,'.LC.00N.D');
            FILENAMEZ = strcat(folder_name_mseed{j}, 'SI.',Xp0(1).StationIdentifierCode,'.LC.00Z.D');
            FILENAMEE = strcat(folder_name_mseed{j}, 'SI.',Xp2(1).StationIdentifierCode,'.LC.00E.D');

            FS = SampleRate;
            D1 = A{1}(1:Samples{j}(i)  + 3*60*SampleRate);
            D2 = A{2}(1:Samples{j}(i)  + 3*60*SampleRate);
            D3 = A{3}(1:Samples{j}(i)  + 3*60*SampleRate);


            mkmseed(FILENAMEZ,D1,T0,FS,3)
            mkmseed(FILENAMEN,D2,T0,FS,3)
            mkmseed(FILENAMEE,D3,T0,FS,3)
            
        end
    end
end






                    end
                end
            end
        end
    end
end
        break
        end
    end
    end

