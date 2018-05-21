
[fname1, pname1] = uigetfile('*.mat');
if fname1 ~=0
    fullname1 = strcat(pname1, fname1);
    sp_per = struct2cell(load(fullname1));
    seismogramm_cell = sp_per{1};
end

% seism(:,1) = seismogramm_cell{1,1};
% seism(:,2) = seismogramm_cell{1,2};
% seism(:,3) = seismogramm_cell{1,3};

SampleRate = 125;
S = 0.2*SampleRate;
L = 30*SampleRate;


for i = L+1:length(seismogramm_cell{1,2})
                      
            STArange = seismogramm_cell{1,2}(i-S:i);
            STA(i) = sum(STArange.^2)/S;

            LTArange = seismogramm_cell{1,2}(i-L:i);
            LTA(i) = sum(LTArange.^2)/L;

            r2(i) = STA(i)/LTA(i);
            
            
end

threshold = 10;
for i = 1:1:length(seismogramm_cell{1,2})
    threshold_array(i) = threshold;
end

Sample = 90*SampleRate;
C = zeros(1,length(seismogramm_cell{1,2}));
for i = 1:1:length(seismogramm_cell{1,2})
    if (i >= Sample)
        C(i) = C(i-1) + log(STA(i)/LTA(i));
    end
    
    
end
for i = 1:1:length(seismogramm_cell{1,2})
    if (C(i) < 0)
        C(i) = 0;
    end
end

% Sample = 149*SampleRate;
% for i = 1:1:length(seismogramm_cell{1,2})
%     if (i >= Sample)
%         C(i) = C(i-1) + log(STA(i)/LTA(i));
%     end
%     
%     
% end
% for i = 1:1:length(seismogramm_cell{1,2})
%     if (C(i) < 0)
%         C(i) = 0;
%     end
% end
% 
% Sample = 258*SampleRate;
% for i = 1:1:length(seismogramm_cell{1,2})
%     if (i >= Sample)
%         C(i) = C(i-1) + log(STA(i)/LTA(i));
%     end
%     
%     
% end
% 
% for i = 1:1:length(seismogramm_cell{1,2})
%     if (C(i) < 0)
%         C(i) = 0;
%     end
% end

C = C';

figure(1);
plot((1:1:length(seismogramm_cell{1,2}))/SampleRate,seismogramm_cell{1,2})
figure(2);
plot((1:1:length(seismogramm_cell{1,2}))/SampleRate, r2, (1:1:length(seismogramm_cell{1,2}))/SampleRate, threshold_array)
figure(3);
plot((1:1:length(seismogramm_cell{1,2}))/SampleRate, C)
