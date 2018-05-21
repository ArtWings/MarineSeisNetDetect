pathToDir = uigetdir;
pathToDir = [pathToDir '\'];
pathToDirFig = strcat(pathToDir, '\fig\');
pathToDirAdb = strcat(pathToDir, '\adb\');
pathToDirMat = strcat(pathToDir, '\mat\');
list = dir(pathToDirFig);

Second1M = zeros(1,length(list));
Second2M = zeros(1,length(list));
HourM = zeros(1,length(list));
DayM = zeros(1,length(list));
MonthM = zeros(1,length(list));
MinuteM = zeros(1,length(list));
for k=1:length(list)
    if list(k).isdir() == 0
        
        fname = list(k).name;
        
        if findstr(fname,'DB') == 5
            DateTimeBlockBegin1 = findstr(fname, '_time_') + 6; % for DB
            DateTimeBlockBegin = DateTimeBlockBegin1(2);        %
        else
            DateTimeBlockBegin = findstr(fname, '_time_') + 6; %for EIZ
        end
        
                        
        MonthBeginEnd = findstr(fname(DateTimeBlockBegin:end), '-');
        Month = fname(DateTimeBlockBegin + MonthBeginEnd(1): DateTimeBlockBegin + MonthBeginEnd(2) - 2);
        
        if findstr(fname,'DB') == 5
            DayBegin = DateTimeBlockBegin + 6 + findstr(fname(DateTimeBlockBegin + 6:end), '-'); % for DB
        else
            DayBegin = DateTimeBlockBegin + 4 + findstr(fname(DateTimeBlockBegin + 4:end), '-'); % for EIZ
        end
        
        DayEnd = DateTimeBlockBegin + findstr(fname(DateTimeBlockBegin:end), '_') - 2;
        Day = fname(DayBegin:DayEnd);
        
        HourBegin = DateTimeBlockBegin + findstr(fname(DateTimeBlockBegin:end), '_');
        HourEnd = DateTimeBlockBegin + findstr(fname(DateTimeBlockBegin:end), 'h') - 2;
        Hour = fname(HourBegin:HourEnd);
        
        MinuteBegin = DateTimeBlockBegin + findstr(fname(DateTimeBlockBegin:end), 'h');
        MinuteEnd = DateTimeBlockBegin + findstr(fname(DateTimeBlockBegin:end), 'm') - 2;
        Minute = fname(MinuteBegin:MinuteEnd);
        
        SecondBegin = DateTimeBlockBegin + findstr(fname(DateTimeBlockBegin:end), 'm');
        SecondEnd = DateTimeBlockBegin + findstr(fname(DateTimeBlockBegin:end), ',') - 2;
        Second = fname(SecondBegin:SecondEnd);
        
        Second1M(k) = str2num(Second);
        Second2M(k) = str2num(Minute)*60 + str2num(Second);
        HourM(k) = str2num(Hour);
        DayM(k) = str2num(Day);  
        MonthM(k) = str2num(Month);
        MinuteM(k) = str2num(Minute); 
        
        
    end
end

counter1 = 1;
for k=3:length(list)
    if (list(k).isdir() == 0 && list(k).bytes~=0)
        for m = k+1:1:length(list)
            if (DayM(m) == DayM(k) && HourM(m) == HourM(k) && abs(Second2M(m) - Second2M(k)) < 65 && list(m).bytes~=0)
                counter1 = counter1 + 1;
                NewDirName = strcat(num2str(16), '-', num2str(MonthM(k)), '-', num2str(DayM(k)), '_', ...
                    num2str(HourM(k)), '-', num2str(MinuteM(k)), '-', num2str(Second1M(k)));
                mkdir(pathToDir, NewDirName);
                copyfile([pathToDirFig list(m).name], strcat(pathToDir, NewDirName, '\'));
                delete([pathToDirFig list(m).name]);
                list(m).bytes = 0;
                
                
                mkdir(strcat(pathToDir, NewDirName, '\'), 'adb');
                copyfile([pathToDirAdb 'adb' list(m).name(4:length(list(m).name)-4) '.adb'], strcat(pathToDir, NewDirName, '\adb\'));
                delete([pathToDirAdb 'adb' list(m).name(4:length(list(m).name)-4) '.adb']);
                
                
                               
                mkdir(strcat(pathToDir, NewDirName, '\'), 'mat');
                copyfile([pathToDirMat 'mat' list(m).name(4:length(list(m).name)-4) '.mat'], strcat(pathToDir, NewDirName, '\mat\'));
                delete([pathToDirMat 'mat' list(m).name(4:length(list(m).name)-4) '.mat']);
                
            end
        end
        if counter1 ~= 1
            copyfile([pathToDirFig list(k).name], strcat(pathToDir, NewDirName, '\'));
            delete([pathToDirFig list(k).name]);
            list(k).bytes = 0;
           
            
            copyfile([pathToDirAdb 'adb' list(k).name(4:length(list(k).name)-4) '.adb'], strcat(pathToDir, NewDirName, '\adb\'));
            delete([pathToDirAdb 'adb' list(k).name(4:length(list(k).name)-4) '.adb']);
            
                           
            copyfile([pathToDirMat 'mat' list(k).name(4:length(list(k).name)-4) '.mat'], strcat(pathToDir, NewDirName, '\mat\'));
            delete([pathToDirMat 'mat' list(k).name(4:length(list(k).name)-4) '.mat']);
        end

        counter1 = 1;
    end
end
