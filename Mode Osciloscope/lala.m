% subplot(3,2,1); plot(PC_SP); title('PetitColim - Sans Polar')
% subplot(3,2,2); plot(PC_P); title('PetitColim - Polar')
% subplot(3,2,3); plot(GC_SP); title('GrosColim - Sans Polar')
% subplot(3,2,4); plot(GC_P); title('GrosColim - Polar')
% subplot(3,2,5); plot(SC); title('Pas de fibre')

figure;
plot(Z,PC_SP,'r')
hold on
plot(Z,PC_P,'b')
plot(Z,GC_SP,'k')
plot(Z,GC_P,'g')
plot(Z,SC,'c')