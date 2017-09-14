  %% definition of initial indexes
  
  n1    = 1 ;
  n2    = 1.4537 ;    % water : 1.33
  theta = 0:0.2:90 ;
  % generation of formulas
  
  Rp = Rp_eval(n1,n2,theta*(pi/180));
  Rs = Rs_eval(n1,n2,theta*(pi/180));
  
  %% critical angle :
  
  thetar = (180/pi)*asin((n1/n2)*sin(theta*pi/180))
  theta_c = (180/pi)*asin(n2/n1)
  
  %% plot results
    Hf = figure;
    set(Hf,'WindowStyle','docked');
    plot(theta,Rp*100)
    hold on
    plot(theta,Rs*100)
    grid on
    xlabel('\theta (°)')
    ylabel('reflexion[%]')
    set(gca,'Yscale','log')
    title('Averaged raw datas')
    legend('R_p','R_s')
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
    
    Hf = figure;
    set(Hf,'WindowStyle','docked');
    plot(theta,thetar)
    grid on
    xlabel('\theta_i (°)')
    ylabel('\theta_r (°)')
    title('refraction angle')
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 


