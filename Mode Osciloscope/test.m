%% test sheet %%
clearvars;
Nloop = 1000 ;
MyMeasurement = oscilloTrace(100,200,10e6,1540) ;
%mygui = oscilloGUI();

%MyMeasurement = MyMeasurement.Addline(actual.ActualStart,actual.ActualLength,datatmp,LineNumber);
for i = 1:Nloop
MyMeasurement.Lines = repmat(exp(-(MyMeasurement.t(1:100)'-3e-6).^2/(1e-6)^2),1,200) + 0*rand(100,200);
MyMeasurement.ScreenAquisition();

%  [U,S,V] = svd(cov(MyMeasurement.Lines));
%  Lines = 0*cov(MyMeasurement.Lines) ;
%   Lines = Lines + S(k,k)*U(:,k)*conj(V(:,k)') ;
% %  for k = 1:10
% %      Lines = Lines + S(k,k)*U(:,k)*conj(V(:,k)') ;
% %  end
% 
% subplot(121)
% imagesc(Lines);
% subplot(122)
% plot(sum(Lines,2))

if MyMeasurement.IsRunning == 0
    break;
end
drawnow
pause(1)

end
