tStart=tic; 


MaxFileSize = 146118028 - 256;
MaxSampleNumber = MaxFileSize/12;

[fname1, pname1] = uigetfile('*.mat');
if fname1 ~=0
    fullname1 = strcat(pname1, fname1);
    sp_per = struct2cell(load(fullname1));
    used_filter = sp_per{1};
end

pathToDir = uigetdir;
pathToDir = strcat(pathToDir, '\');
list = dir(pathToDir);
for k=1:length(list)
    if list(k).isdir() == 0
        %disp(list(k).name);
        F = fopen([pathToDir list(k).name], 'r');  
        d = dir([pathToDir list(k).name]);         
        fname = list(k).name;

% fseek(F, 0, 'bof');
% head_init = fread(F, 256);

fseek(F, 64, 'bof');
Number_of_channels = fread(F, 1, 'uint16');

fseek(F, 66, 'bof');
ChannelSampleNumber = fread(F, 1, 'uint32');

fseek(F, 44, 'bof');
Begin_year = fread(F, 1, 'uint16');

fseek(F, 46, 'bof');
Begin_month = fread(F, 1, 'uint16');

fseek(F, 48, 'bof');
Begin_day = fread(F, 1, 'uint16');

fseek(F, 50, 'bof');
Begin_hour = fread(F, 1, 'uint16');

fseek(F, 52, 'bof');
Begin_minute = fread(F, 1, 'uint16');

fseek(F, 54, 'bof');
Begin_second = fread(F, 1, 'uint16');

fseek(F, 56, 'bof');
Begin_millisecond = fread(F, 1, 'uint16');

fseek(F, 58, 'bof');
SampleRate = fread(F, 1, 'uint16');
fclose(F);



    ost = mod(ChannelSampleNumber, MaxSampleNumber);
    NumOfIter = ceil(ChannelSampleNumber/MaxSampleNumber);
    for m = 1:1:NumOfIter
        if (ost == 0)
            F = fopen([pathToDir list(k).name], 'r');
            fseek(F, 256, 'bof');
            A1 = fread(F, [MaxSampleNumber,Number_of_channels], 'int');
            fclose(F);
        end
        if (ost~=0 && m < NumOfIter)
            F = fopen([pathToDir list(k).name], 'r');
            fseek(F, 256 + (m-1)*MaxSampleNumber*4, 'bof'); 
            A1 = fread(F, [MaxSampleNumber,Number_of_channels], '12176480*int', (ChannelSampleNumber - MaxSampleNumber)*4);
            fclose(F);
        end
        if (ost~=0 && m == NumOfIter)
            F = fopen([pathToDir list(k).name], 'r');
            fseek(F, 256 + (m-1)*MaxSampleNumber*4, 'bof'); 
            charSkip = strcat(num2str(ost), '*int');
            A1 = fread(F, [ost,Number_of_channels], charSkip, (ChannelSampleNumber - ost)*4);
            fclose(F);
        end
        


count = zeros(1,3);
Samples = cell(1,3);
Samples1 = cell(1,3);
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
A{1} = detrend(A1(2:end,1));
A{2} = detrend(A1(2:end,2));
A{3} = detrend(A1(2:end,3));
clear A1;
AA{1} = filter(used_filter, A{1});  % 
AA{2} = filter(used_filter, A{2});  %
AA{3} = filter(used_filter, A{3});  % 


S = 0.2*SampleRate;
L = 30*SampleRate;
STA = zeros(1,length(AA{1}));
LTA = zeros(1,length(AA{1}));
rr = cell(1,3);
rr{1} = zeros(1,length(AA{1}));
rr{2} = zeros(1,length(AA{1}));
rr{3} = zeros(1,length(AA{1}));
r1 = zeros(1,length(AA{1}));
r2 = zeros(1,length(AA{1}));
r3 = zeros(1,length(AA{1}));


% matlabpool('open',7);    % for R2010a
MyPool = parpool('local', 6);   % for R2017a


parfor i = L+1:length(AA{1})
%             STArange = AA{1}(i-S:i);
%             STA(i) = sum(STArange.^2)/S;
% 
%             LTArange = AA{1}(i-L:i);
%             LTA(i) = sum(LTArange.^2)/L;
% 
%             r1(i) = STA(i)/LTA(i);
            
            STArange = AA{2}(i-S:i);
            STA(i) = sum(STArange.^2)/S;

            LTArange = AA{2}(i-L:i);
            LTA(i) = sum(LTArange.^2)/L;

            r2(i) = STA(i)/LTA(i);
            
%             STArange = AA{3}(i-S:i);
%             STA(i) = sum(STArange.^2)/S;
% 
%             LTArange = AA{3}(i-L:i);
%             LTA(i) = sum(LTArange.^2)/L;
% 
%             r3(i) = STA(i)/LTA(i);
end

rr{1} = r1;
rr{2} = r2;
rr{3} = r3;

clear STA LTA r1 r2 r3;

threshold = 10;
parfor i = 1:1:length(AA{1})
    threshold_array(i) = threshold;
end


for j = 2:1:2
    count(j) = 0;
    for i = 10*SampleRate + 1:1:length(AA{j})
        previous_window = rr{j}(i - 10*SampleRate:i-1);
        if (rr{j}(i) > threshold && all(previous_window <= threshold))
            
            C = zeros(1,length(AA{1}));
            
            upperbound = i+3*60*SampleRate;
            if upperbound > length(rr{j})
                upperbound = length(rr{j});
            end
            
            for ii = i:1:upperbound
                C(ii) = C(ii-1) + log(rr{j}(ii));
            end
            for ii = i:1:upperbound
                if (C(ii) < 0)
                    for iii = ii:1:upperbound
                        C(iii) = 0;
                    end
                end
            end
            
            lenCounts = 0;
            for ii = i:1:upperbound
                if C(ii)~=0
                    lenCounts = lenCounts + 1;
                end
            end
            SignalLength = lenCounts/SampleRate;
            
            
            if SignalLength >= 5
                count(j) = count(j) + 1;
                Samples{j}(count(j)) = i + (m-1)*MaxFileSize/12;
            end
        end
    end
end


% matlabpool ('close');   % for R2010a
delete(MyPool);                % for R2017a

clear rr;

mkdir(pathToDir, 'filtered');
for j = 2:1:2
    mkdir(strcat(pathToDir, 'filtered') ,strcat('Channel', num2str(j)));
    mkdir(strcat(pathToDir, 'filtered\Channel', num2str(j)), 'adb');
    mkdir(strcat(pathToDir, 'filtered\Channel', num2str(j)), 'fig');
    mkdir(strcat(pathToDir, 'filtered\Channel', num2str(j)), 'mat');
    folder_name_adb{j} = strcat(pathToDir, 'filtered\Channel', num2str(j), '\', 'adb');%uigetdir;
    folder_name_fig{j} = strcat(pathToDir, 'filtered\Channel', num2str(j), '\', 'fig');
    folder_name_mat{j} = strcat(pathToDir, 'filtered\Channel', num2str(j), '\', 'mat');
    for i = 1:1:length(Samples{j})
        if (Samples{j}(i) - (m-1)*MaxFileSize/12 > 90*SampleRate && Samples{j}(i) - (m-1)*MaxFileSize/12 < length(AA{j}) - 3*60*SampleRate)
            
            h = figure(i);
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:90*SampleRate + 3*60*SampleRate)/SampleRate)', AA{t}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate));
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
            
            
                                
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            aa = findstr(file_name_fig, '.');
            file_name_fig(aa) = ',';
            
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = AA{t}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate);
            end
            aa = findstr(file_name_mat, '.');
            file_name_mat(1:length(aa)-1) = ',';
            
            save(file_name_mat, 's', '-mat');
            clear s;
            
            F = fopen([pathToDir list(k).name], 'rb');
            fseek(F, 0, 'bof');
            head = fread(F, 256);
            fclose(F);
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            aa = findstr(file_name_adb, '.');
            file_name_adb(1:length(aa)-1) = ',';
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
            lengthOfFragment = length(AA{1}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate))-1;
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment, 'integer*4');

            fseek(F, 256, 'bof');
            s = horzcat(AA{1}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate), AA{2}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate), AA{3}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
                        
    
        elseif (Samples{j}(i) - (m-1)*MaxFileSize/12 > 90*SampleRate && Samples{j}(i) - (m-1)*MaxFileSize/12 > length(AA{j}) - 3*60*SampleRate)
            
            h = figure(i);
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:length(AA{j}) - Samples{j}(i) + (m-1)*MaxFileSize/12 + 90*SampleRate)/SampleRate)', AA{t}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(AA{j})));
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
            
%             Samples_seconds{j}(i) = fix((Samples{j}(i) - 90*SampleRate)/SampleRate);
%             Samples_hours{j}(i) = fix(Samples_seconds{j}(i)/3600);
%             Samples_minutes{j}(i) = fix((Samples_seconds{j}(i) - Samples_hours{j}(i)*3600)/60);
%             Samples_seconds{j}(i) = fix(Samples_seconds{j}(i) - Samples_hours{j}(i)*3600 - Samples_minutes{j}(i)*60);
%             Samples_abshour{j}(i) = Begin_hour + Samples_hours{j}(i);
%             Samples_absminute{j}(i) = Begin_minute + Samples_minutes{j}(i);
%             Samples_abssecond{j}(i) = Begin_second + Samples_seconds{j}(i);
%             
%             Samples_abs_day{j}(i) = Begin_day;
%             
%             while (Samples_abssecond{j}(i) >= 60)
%                 Samples_abssecond{j}(i) = Samples_abssecond{j}(i) - 60;
%                 Samples_absminute{j}(i) = Samples_absminute{j}(i) + 1;
%             end
%             while (Samples_absminute{j}(i) >= 60)
%                 Samples_absminute{j}(i) = Samples_absminute{j}(i) - 60;
%                 Samples_abshour{j}(i) = Samples_abshour{j}(i) + 1;
%             end
%             while (Samples_abshour{j}(i) >= 24)
%                 Samples_abshour{j}(i) = Samples_abshour{j}(i) - 24;
%                 Samples_abs_day{j}(i) = Samples_abs_day{j}(i) + 1;
%             end
            
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            aa = findstr(file_name_fig, '.');
            file_name_fig(aa) = ',';
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = AA{t}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(AA{j}));
            end
            aa = findstr(file_name_mat, '.');
            file_name_mat(1:length(aa)-1) = ',';
            save(file_name_mat, 's', '-mat');
            clear s;
            
            F = fopen([pathToDir list(k).name], 'rb');
            fseek(F, 0, 'bof');
            head = fread(F, 256);
            fclose(F);
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            aa = findstr(file_name_adb, '.');
            file_name_adb(1:length(aa)-1) = ',';
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
            lengthOfFragment = length(AA{1}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(AA{j})))-1;
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment, 'integer*4');
            
            fseek(F, 256, 'bof');
            s = horzcat(AA{1}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(AA{j})), AA{2}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(AA{j})), AA{3}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(AA{j})));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
            
        elseif (Samples{j}(i) - (m-1)*MaxFileSize/12  < 90*SampleRate && Samples{j}(i) - (m-1)*MaxFileSize/12 < length(AA{j}) - 3*60*SampleRate)
            
            h = figure(i);
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate)/SampleRate)', AA{t}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate));
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
            
%             Samples_seconds{j}(i) = fix((Samples{j}(i) - 90*SampleRate)/SampleRate);
%             Samples_hours{j}(i) = fix(Samples_seconds{j}(i)/3600);
%             Samples_minutes{j}(i) = fix((Samples_seconds{j}(i) - Samples_hours{j}(i)*3600)/60);
%             Samples_seconds{j}(i) = fix(Samples_seconds{j}(i) - Samples_hours{j}(i)*3600 - Samples_minutes{j}(i)*60);
%             Samples_abshour{j}(i) = Begin_hour + Samples_hours{j}(i);
%             Samples_absminute{j}(i) = Begin_minute + Samples_minutes{j}(i);
%             Samples_abssecond{j}(i) = Begin_second + Samples_seconds{j}(i);
%            
%             Samples_abs_day{j}(i) = Begin_day;
%             
%             while (Samples_abssecond{j}(i) >= 60)
%                 Samples_abssecond{j}(i) = Samples_abssecond{j}(i) - 60;
%                 Samples_absminute{j}(i) = Samples_absminute{j}(i) + 1;
%             end
%             while (Samples_absminute{j}(i) >= 60)
%                 Samples_absminute{j}(i) = Samples_absminute{j}(i) - 60;
%                 Samples_abshour{j}(i) = Samples_abshour{j}(i) + 1;
%             end
%             while (Samples_abshour{j}(i) >= 24)
%                 Samples_abshour{j}(i) = Samples_abshour{j}(i) - 24;
%                 Samples_abs_day{j}(i) = Samples_abs_day{j}(i) + 1;
%             end
            
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            aa = findstr(file_name_fig, '.');
            file_name_fig(aa) = ',';
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = AA{t}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate);
            end
            aa = findstr(file_name_mat, '.');
            file_name_mat(1:length(aa)-1) = ',';
            save(file_name_mat, 's', '-mat');
            clear s;
            
            F = fopen([pathToDir list(k).name], 'rb');
            fseek(F, 0, 'bof');
            head = fread(F, 256);
            fclose(F);
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            aa = findstr(file_name_adb, '.');
            file_name_adb(1:length(aa)-1) = ',';
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
            lengthOfFragment = length(AA{1}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate))-1;
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment, 'integer*4');
            
            fseek(F, 256, 'bof');
            s = horzcat(AA{1}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate), AA{2}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate), AA{3}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
        end
    end
end


mkdir(pathToDir, 'unfiltered');
for j = 2:1:2
    mkdir(strcat(pathToDir, 'unfiltered') ,strcat('Channel', num2str(j)));
    mkdir(strcat(pathToDir, 'unfiltered\Channel', num2str(j)), 'adb');
    mkdir(strcat(pathToDir, 'unfiltered\Channel', num2str(j)), 'fig');
    mkdir(strcat(pathToDir, 'unfiltered\Channel', num2str(j)), 'mat');
    folder_name_adb{j} = strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\', 'adb');%uigetdir;
    folder_name_fig{j} = strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\', 'fig');
    folder_name_mat{j} = strcat(pathToDir, 'unfiltered\Channel', num2str(j), '\', 'mat');
    for i = 1:1:length(Samples{j})
        if (Samples{j}(i) - (m-1)*MaxFileSize/12 > 90*SampleRate && Samples{j}(i) - (m-1)*MaxFileSize/12 < length(A{j}) - 3*60*SampleRate)
            
            h = figure(i);
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:90*SampleRate + 3*60*SampleRate)/SampleRate)', A{t}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate));
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
            
%             Samples_seconds{j}(i) = fix((Samples{j}(i) - 90*SampleRate)/SampleRate);
%             Samples_hours{j}(i) = fix(Samples_seconds{j}(i)/3600);
%             Samples_minutes{j}(i) = fix((Samples_seconds{j}(i) - Samples_hours{j}(i)*3600)/60);
%             Samples_seconds{j}(i) = fix(Samples_seconds{j}(i) - Samples_hours{j}(i)*3600 - Samples_minutes{j}(i)*60);
%             Samples_abshour{j}(i) = Begin_hour + Samples_hours{j}(i);
%             Samples_absminute{j}(i) = Begin_minute + Samples_minutes{j}(i);
%             Samples_abssecond{j}(i) = Begin_second + Samples_seconds{j}(i);
%             
%             Samples_abs_day{j}(i) = Begin_day;
%             
%             while (Samples_abssecond{j}(i) >= 60)
%                 Samples_abssecond{j}(i) = Samples_abssecond{j}(i) - 60;
%                 Samples_absminute{j}(i) = Samples_absminute{j}(i) + 1;
%             end
%             while (Samples_absminute{j}(i) >= 60)
%                 Samples_absminute{j}(i) = Samples_absminute{j}(i) - 60;
%                 Samples_abshour{j}(i) = Samples_abshour{j}(i) + 1;
%             end
%             while (Samples_abshour{j}(i) >= 24)
%                 Samples_abshour{j}(i) = Samples_abshour{j}(i) - 24;
%                 Samples_abs_day{j}(i) = Samples_abs_day{j}(i) + 1;
%             end
            
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            aa = findstr(file_name_fig, '.');
            file_name_fig(aa) = ',';
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = A{t}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate);
            end
            aa = findstr(file_name_mat, '.');
            file_name_mat(1:length(aa)-1) = ',';
            save(file_name_mat, 's', '-mat');
            clear s;
            
            F = fopen([pathToDir list(k).name], 'rb');
            head = fread(F, 256);
            fclose(F);
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            aa = findstr(file_name_adb, '.');
            file_name_adb(1:length(aa)-1) = ',';
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
            lengthOfFragment = length(A{1}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate))-1;
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment, 'integer*4');
            
            fseek(F, 256, 'bof');
            s = horzcat(A{1}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate), A{2}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate), A{3}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
                        
    
        elseif (Samples{j}(i) - (m-1)*MaxFileSize/12 > 90*SampleRate && Samples{j}(i) - (m-1)*MaxFileSize/12 > length(A{j}) - 3*60*SampleRate)
            
            h = figure(i);
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:length(A{j}) - Samples{j}(i) + (m-1)*MaxFileSize/12 + 90*SampleRate)/SampleRate)', A{t}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(A{j})));
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
            
%             Samples_seconds{j}(i) = fix((Samples{j}(i) - 90*SampleRate)/SampleRate);
%             Samples_hours{j}(i) = fix(Samples_seconds{j}(i)/3600);
%             Samples_minutes{j}(i) = fix((Samples_seconds{j}(i) - Samples_hours{j}(i)*3600)/60);
%             Samples_seconds{j}(i) = fix(Samples_seconds{j}(i) - Samples_hours{j}(i)*3600 - Samples_minutes{j}(i)*60);
%             Samples_abshour{j}(i) = Begin_hour + Samples_hours{j}(i);
%             Samples_absminute{j}(i) = Begin_minute + Samples_minutes{j}(i);
%             Samples_abssecond{j}(i) = Begin_second + Samples_seconds{j}(i);
%             
%             Samples_abs_day{j}(i) = Begin_day;
%             
%             while (Samples_abssecond{j}(i) >= 60)
%                 Samples_abssecond{j}(i) = Samples_abssecond{j}(i) - 60;
%                 Samples_absminute{j}(i) = Samples_absminute{j}(i) + 1;
%             end
%             while (Samples_absminute{j}(i) >= 60)
%                 Samples_absminute{j}(i) = Samples_absminute{j}(i) - 60;
%                 Samples_abshour{j}(i) = Samples_abshour{j}(i) + 1;
%             end
%             while (Samples_abshour{j}(i) >= 24)
%                 Samples_abshour{j}(i) = Samples_abshour{j}(i) - 24;
%                 Samples_abs_day{j}(i) = Samples_abs_day{j}(i) + 1;
%             end
            
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            aa = findstr(file_name_fig, '.');
            file_name_fig(aa) = ',';
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = A{t}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(A{j}));
            end
            aa = findstr(file_name_mat, '.');
            file_name_mat(1:length(aa)-1) = ',';
            save(file_name_mat, 's', '-mat');
            clear s;
            
            F = fopen([pathToDir list(k).name], 'rb');
            head = fread(F, 256);
            fclose(F);
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            aa = findstr(file_name_adb, '.');
            file_name_adb(1:length(aa)-1) = ',';
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
            lengthOfFragment = length(A{1}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(A{j})))-1;
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment, 'integer*4');
            
            fseek(F, 256, 'bof');
            s = horzcat(A{1}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(A{j})), A{2}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(A{j})), A{3}(Samples{j}(i) - (m-1)*MaxFileSize/12 - 90*SampleRate +1:length(A{j})));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
            
        elseif (Samples{j}(i) - (m-1)*MaxFileSize/12  < 90*SampleRate && Samples{j}(i) - (m-1)*MaxFileSize/12 < length(A{j}) - 3*60*SampleRate)
            
            h = figure(i);
            for t = 1:1:Number_of_channels
                subplot(Number_of_channels,1,t), plot(((1:1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate)/SampleRate)', A{t}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate));
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
            
%             Samples_seconds{j}(i) = fix((Samples{j}(i) - 90*SampleRate)/SampleRate);
%             Samples_hours{j}(i) = fix(Samples_seconds{j}(i)/3600);
%             Samples_minutes{j}(i) = fix((Samples_seconds{j}(i) - Samples_hours{j}(i)*3600)/60);
%             Samples_seconds{j}(i) = fix(Samples_seconds{j}(i) - Samples_hours{j}(i)*3600 - Samples_minutes{j}(i)*60);
%             Samples_abshour{j}(i) = Begin_hour + Samples_hours{j}(i);
%             Samples_absminute{j}(i) = Begin_minute + Samples_minutes{j}(i);
%             Samples_abssecond{j}(i) = Begin_second + Samples_seconds{j}(i);
%            
%             Samples_abs_day{j}(i) = Begin_day;
%             
%             while (Samples_abssecond{j}(i) >= 60)
%                 Samples_abssecond{j}(i) = Samples_abssecond{j}(i) - 60;
%                 Samples_absminute{j}(i) = Samples_absminute{j}(i) + 1;
%             end
%             while (Samples_absminute{j}(i) >= 60)
%                 Samples_absminute{j}(i) = Samples_absminute{j}(i) - 60;
%                 Samples_abshour{j}(i) = Samples_abshour{j}(i) + 1;
%             end
%             while (Samples_abshour{j}(i) >= 24)
%                 Samples_abshour{j}(i) = Samples_abshour{j}(i) - 24;
%                 Samples_abs_day{j}(i) = Samples_abs_day{j}(i) + 1;
%             end
            
            file_name_fig = strcat(folder_name_fig{j}, '\', 'fig_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's');  
            aa = findstr(file_name_fig, '.');
            file_name_fig(aa) = ',';
            saveas(h, file_name_fig, 'fig'); 
            close(h);
            
            file_name_mat = strcat(folder_name_mat{j}, '\', 'mat_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.mat'); 
            s = cell(1,3);
            for t = 1:1:Number_of_channels
                s{t} = A{t}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate);
            end
            aa = findstr(file_name_mat, '.');
            file_name_mat(1:length(aa)-1) = ',';
            save(file_name_mat, 's', '-mat');
            clear s;
            
            F = fopen([pathToDir list(k).name], 'rb');
            head = fread(F, 256);
            fclose(F);
            file_name_adb = strcat(folder_name_adb{j}, '\', 'adb_', fname(1:length(fname)-4), '_sample_', num2str(Samples{j}(i)), '_time_', num2str(Begin_year),...
                '-', num2str(Begin_month), '-', num2str(Samples_abs_day{j}(i)), '_', num2str(Samples_abshour{j}(i)), 'h', num2str(Samples_absminute{j}(i)),...
                'm', num2str(fix(Samples_abssecond{j}(i))), ',', num2str(Samples_abssecond_drob{j}(i)), 's', '.adb'); 
            aa = findstr(file_name_adb, '.');
            file_name_adb(1:length(aa)-1) = ',';
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
            lengthOfFragment = length(A{1}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate))-1;
            fseek(F, 66, 'bof');
            fwrite(F, lengthOfFragment, 'integer*4');
            
            fseek(F, 256, 'bof');
            s = horzcat(A{1}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate), A{2}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate), A{3}(1:Samples{j}(i) - (m-1)*MaxFileSize/12 + 3*60*SampleRate));
            fwrite(F, s, 'int');
            fclose(F);
            clear s;
        end
    end
end





end


end
end


tElapsed=toc(tStart)

