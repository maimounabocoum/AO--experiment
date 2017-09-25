%% read trace from saved datas %%%


% open file to read :
clearvars;
[filename,foldername] = uigetfile('D:\Data\mai\','MultiSelect', 'on');

for Nselection = 1:length(filename)
    
        S{Nselection} = load([foldername,filename{Nselection}]);
        if isequal(filename,0)
           disp('User selected Cancel')
        else
           disp(['User selected ', fullfile(foldername, filename{Nselection})])
        end
end

%% create trace :
for Nselection = 1:length(filename)
    
        SData{Nselection} = oscilloTrace(size(S{Nselection}.S.Lines,1),S{Nselection}.S.Nlines,S{Nselection}.S.SampleRate,1540) ;
        SData{Nselection}.Lines = S{Nselection}.S.Lines;
        SData{Nselection}.z = S{Nselection}.S.z;
        SData{Nselection}.t = S{Nselection}.S.t;

        LineAverage{Nselection} = sum(SData{Nselection}.Lines(:,1:SData{Nselection}.Nlines),2)/SData{Nselection}.Nlines ;
        xdft{Nselection}    = SData{Nselection}.fourier(SData{Nselection}.Lines(:));
        psdx{Nselection}    = abs(xdft{Nselection}).^2 ;
end

%% plot all inidividual averages
for Nselection = 1:length(filename)
figure;
hold on
plot(SData{Nselection}.z(1:length(LineAverage{Nselection}))*1e3,LineAverage{Nselection})
legend(filename)
end

%% plot average
average = 0*LineAverage{1} ;
for Nselection = 1:length(filename)
average = average + LineAverage{Nselection}/length(filename) ;
hold on
plot(SData{Nselection}.z(1:length(LineAverage{Nselection}))*1e3,LineAverage{Nselection})
legend(filename)
end
plot(SData{Nselection}.z(1:length(LineAverage{Nselection}))*1e3,average,'--','linewidth', 2)


%% plot all indivualual ffts
for Nselection = 1:length(filename)
figure(2)
hold on
semilogy(SData{Nselection}.f*1e-6,psdx{Nselection}*1e6)
end