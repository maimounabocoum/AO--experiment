%% Introduction
% Fenetre graphique de controle d'un moteur PI-Micos relie a l'ordinateur
% par une liaison serie RS232.
% Historique des MAJ : 
%   - 05/01/2014 : Creation du script (Baptiste Jayet)
%   - 13/01/2014 : Gestion de 2 moteurs (Baptiste Jayet)
clear all

%% Parametres d'affichage
pos_boutons_rapide1=[0.065 0.6]; %Positions x0 et y0 du bloc de bouton de deplacement rapide
pos_boutons_rapide2=[0.565 0.6];
dx_boutons_rapide=0.1; %Largeur d'un bouton
dy_boutons_rapide=0.05; %Hauteur d'un bouton

%% Parametres du moteur
COM_Port=3; %Port COM du moteur
Controller=PolluxOpenAndInitialize(COM_Port);
numero=[];
for k=1:3
    fprintf(Controller,[num2str(k) ' getaxis']);
    a=fscanf(Controller);
    if(~isempty(a))
        numero=[numero k];
    end
end
Nmoteur=length(numero);
disp([num2str(Nmoteur) ' moteur(s) trouve(s)'])
position=zeros(1,Nmoteur);
for k=1:Nmoteur
    position(k)=PolluxPosition(Controller,numero(k));
end
%% Initialisation des variables
d_rel1=0; %Variable pour le deplacement relatif
d_rel1str=num2str(d_rel1,'%0.2f');
d_abs1=0; %Variable pour le deplacement absolue
d_abs1str=num2str(d_abs1,'%0.2f');
if(Nmoteur==2)
    d_rel2=0; %Variable pour le deplacement relatif
    d_rel2str=num2str(d_rel2,'%0.2f');
    d_abs2=0; %Variable pour le deplacement absolue
    d_abs2str=num2str(d_abs2,'%0.2f');
end

STOP=1; %Variable d'arret
scrsz=get(0,'ScreenSize'); %Taille de l'ecran

%% Creation de la fenetre de controle
fenetre=figure('Position',[0.1*scrsz(3) 0.1*scrsz(4) 0.5*scrsz(3) 0.8*scrsz(4)]);
titre=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.9,'String','Fenetre de controle de moteur Pollux','Position',[0.1 0.95 0.8 0.04]);
ind_nmoteur=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Left','FontSize',0.9,'String',['Nombre de moteur : ' num2str(Nmoteur)],'Position',[0.05 0.9 0.5 0.03]);
if(Nmoteur==1)
        % Bouton d'arret et indicateur de position
    bouton_stop=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Exit','Position',[0.9 0 .1 .05],'Callback','STOP=0;');
    ind_position1=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Left','FontSize',0.9,'String',['Current position : ' num2str(position)],'Position',[0.05 0.8 0.6 0.03]);
        % Bloc de bouton de deplacement rapide
    titre_bouton_rapide1=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String','Fast travel (mm)','Position',[0.05 0.7 0.25 0.03]);
    bouton1_m01=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-0.1','Position',[pos_boutons_rapide1(1) pos_boutons_rapide1(2) dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero,-0.1);');
    bouton1_p01=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+0.1','Position',[pos_boutons_rapide1(1)+dx_boutons_rapide+0.01 pos_boutons_rapide1(2) dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero,0.1);');
    bouton1_m05=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-0.5','Position',[pos_boutons_rapide1(1) pos_boutons_rapide1(2)-dy_boutons_rapide-0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero,-0.5);');
    bouton1_p05=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+0.5','Position',[pos_boutons_rapide1(1)+dx_boutons_rapide+0.01 pos_boutons_rapide1(2)-dy_boutons_rapide-0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero,0.5);');
    bouton1_m1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-1','Position',[pos_boutons_rapide1(1) pos_boutons_rapide1(2)-2*dy_boutons_rapide-2*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero,-1);');
    bouton1_p1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+1','Position',[pos_boutons_rapide1(1)+dx_boutons_rapide+0.01 pos_boutons_rapide1(2)-2*dy_boutons_rapide-2*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero,1);');
    bouton1_m5=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-5','Position',[pos_boutons_rapide1(1) pos_boutons_rapide1(2)-3*dy_boutons_rapide-3*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero,-5);');
    bouton1_p5=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+5','Position',[pos_boutons_rapide1(1)+dx_boutons_rapide+0.01 pos_boutons_rapide1(2)-3*dy_boutons_rapide-3*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero,5);');
    bouton1_m10=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-10','Position',[pos_boutons_rapide1(1) pos_boutons_rapide1(2)-4*dy_boutons_rapide-4*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero,-10);');
    bouton1_p10=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+10','Position',[pos_boutons_rapide1(1)+dx_boutons_rapide+0.01 pos_boutons_rapide1(2)-4*dy_boutons_rapide-4*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero,10);');
        %Bloc de deplacement relatif
    titre_deplacement_rel1=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String','Relative travel (mm)','Position',[0.4 0.7 0.25 0.03]);
    val_deplacement_rel1=uicontrol(fenetre,'Style','edit','Units','normalized','Position',[0.4 0.65 0.05 0.04],'String',d_rel1str,'Callback','CB_pollux_deprel1');
    bouton_deplacement_rel1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Move','Position',[0.46 0.65 0.1 0.04],'Callback','PolluxDepRel(Controller,numero(1),d_rel1)');
        %Bloc de deplacement absolu
    titre_deplacement_abs1=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String','Absolute travel (mm)','Position',[0.4 0.5 0.25 0.03]);
    val_deplacement_abs1=uicontrol(fenetre,'Style','edit','Units','normalized','Position',[0.4 0.45 0.05 0.04],'String',d_abs1str,'Callback','CB_pollux_depabs1');
    bouton_deplacement_abs1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Go to','Position',[0.46 0.45 0.1 0.04],'Callback','PolluxDepAbs(Controller,numero(1),d_abs1);');
        %Bouton de reinitialisation de la position
    bouton_reinit1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Set Current position to 0','Position',[0.7 0.8 0.25 0.04],'Callback',['fprintf(Controller,''0.0 ' num2str(numero(1)) ' setnpos'');']);
elseif(Nmoteur==2)
        % Bouton d'arret et indicateur de position
    bouton_stop=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Exit','Position',[0.9 0 .1 .05],'Callback','STOP=0;');
    ind_position1=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Left','FontSize',0.9,'String',['Current position ' num2str(numero(1)) ' : ' num2str(position(1))],'Position',[0.05 0.8 0.6 0.03]);
    ind_position2=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Left','FontSize',0.9,'String',['Current position ' num2str(numero(2)) ' : ' num2str(position(2))],'Position',[0.05 0.76 0.6 0.03]);
        % Indicateur moteur
    titre_moteur1=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String',['Moteur ' num2str(numero(1))],'Position',[0.05 pos_boutons_rapide1(2)+0.1 0.15 0.03]);
    titre_moteur2=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String',['Moteur ' num2str(numero(2))],'Position',[0.55 pos_boutons_rapide1(2)+0.1 0.15 0.03]);
        % Bloc de bouton de deplacement rapide du moteur 1
    titre_bouton_rapide1=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String','Fast travel (mm)','Position',[0.05 pos_boutons_rapide1(2)+0.06 0.25 0.03]);
    bouton1_m01=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-0.1','Position',[pos_boutons_rapide1(1) pos_boutons_rapide1(2) dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(1),-0.1);');
    bouton1_p01=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+0.1','Position',[pos_boutons_rapide1(1)+dx_boutons_rapide+0.01 pos_boutons_rapide1(2) dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(1),0.1);');
    bouton1_m05=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-0.5','Position',[pos_boutons_rapide1(1) pos_boutons_rapide1(2)-dy_boutons_rapide-0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(1),-0.5);');
    bouton1_p05=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+0.5','Position',[pos_boutons_rapide1(1)+dx_boutons_rapide+0.01 pos_boutons_rapide1(2)-dy_boutons_rapide-0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(1),0.5);');
    bouton1_m1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-1','Position',[pos_boutons_rapide1(1) pos_boutons_rapide1(2)-2*dy_boutons_rapide-2*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(1),-1);');
    bouton1_p1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+1','Position',[pos_boutons_rapide1(1)+dx_boutons_rapide+0.01 pos_boutons_rapide1(2)-2*dy_boutons_rapide-2*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(1),1);');
    bouton1_m5=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-5','Position',[pos_boutons_rapide1(1) pos_boutons_rapide1(2)-3*dy_boutons_rapide-3*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(1),-5);');
    bouton1_p5=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+5','Position',[pos_boutons_rapide1(1)+dx_boutons_rapide+0.01 pos_boutons_rapide1(2)-3*dy_boutons_rapide-3*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(1),5);');
    bouton1_m10=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-10','Position',[pos_boutons_rapide1(1) pos_boutons_rapide1(2)-4*dy_boutons_rapide-4*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(1),-10);');
    bouton1_p10=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+10','Position',[pos_boutons_rapide1(1)+dx_boutons_rapide+0.01 pos_boutons_rapide1(2)-4*dy_boutons_rapide-4*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(1),10);');
        % Bloc de bouton de deplacement rapide du moteur 2
    titre_bouton_rapide2=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String','Fast travel (mm)','Position',[0.55 pos_boutons_rapide2(2)+0.06 0.25 0.03]);
    bouton2_m01=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-0.1','Position',[pos_boutons_rapide2(1) pos_boutons_rapide2(2) dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(2),-0.1);');
    bouton2_p01=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+0.1','Position',[pos_boutons_rapide2(1)+dx_boutons_rapide+0.01 pos_boutons_rapide2(2) dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(2),0.1);');
    bouton2_m05=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-0.5','Position',[pos_boutons_rapide2(1) pos_boutons_rapide2(2)-dy_boutons_rapide-0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(2),-0.5);');
    bouton2_p05=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+0.5','Position',[pos_boutons_rapide2(1)+dx_boutons_rapide+0.01 pos_boutons_rapide2(2)-dy_boutons_rapide-0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(2),0.5);');
    bouton2_m1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-1','Position',[pos_boutons_rapide2(1) pos_boutons_rapide2(2)-2*dy_boutons_rapide-2*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(2),-1);');
    bouton2_p1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+1','Position',[pos_boutons_rapide2(1)+dx_boutons_rapide+0.01 pos_boutons_rapide2(2)-2*dy_boutons_rapide-2*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(2),1);');
    bouton2_m5=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-5','Position',[pos_boutons_rapide2(1) pos_boutons_rapide2(2)-3*dy_boutons_rapide-3*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(2),-5);');
    bouton2_p5=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+5','Position',[pos_boutons_rapide2(1)+dx_boutons_rapide+0.01 pos_boutons_rapide2(2)-3*dy_boutons_rapide-3*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(2),5);');
    bouton2_m10=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','-10','Position',[pos_boutons_rapide2(1) pos_boutons_rapide2(2)-4*dy_boutons_rapide-4*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(2),-10);');
    bouton2_p10=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','+10','Position',[pos_boutons_rapide2(1)+dx_boutons_rapide+0.01 pos_boutons_rapide2(2)-4*dy_boutons_rapide-4*0.01 dx_boutons_rapide dy_boutons_rapide],'Callback','PolluxDepRel(Controller,numero(2),10);');
        %Bloc de deplacement relatif du moteur 1
    titre_deplacement_rel1=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String','Relative travel (mm)','Position',[0.05 0.3 0.25 0.03]);
    val_deplacement_rel1=uicontrol(fenetre,'Style','edit','Units','normalized','Position',[0.05 0.25 0.05 0.04],'String',d_rel1str,'Callback','CB_pollux_deprel1');
    bouton_deplacement_rel1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Move','Position',[0.11 0.25 0.1 0.04],'Callback','PolluxDepRel(Controller,numero(1),d_rel1)');
        %Bloc de deplacement relatif du moteur 2
    titre_deplacement_rel2=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String','Relative travel (mm)','Position',[0.55 0.3 0.25 0.03]);
    val_deplacement_rel2=uicontrol(fenetre,'Style','edit','Units','normalized','Position',[0.55 0.25 0.05 0.04],'String',d_rel2str,'Callback','CB_pollux_deprel2');
    bouton_deplacement_rel2=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Move','Position',[0.61 0.25 0.1 0.04],'Callback','PolluxDepRel(Controller,numero(2),d_rel2)');
        %Bloc de deplacement absolu du moteur 1
    titre_deplacement_abs1=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String','Absolute travel (mm)','Position',[0.05 0.20 0.25 0.03]);
    val_deplacement_abs1=uicontrol(fenetre,'Style','edit','Units','normalized','Position',[0.05 0.15 0.05 0.04],'String',d_abs1str,'Callback','CB_pollux_depabs1');
    bouton_deplacement_abs1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Go to','Position',[0.11 0.15 0.1 0.04],'Callback','PolluxDepAbs(Controller,numero(1),d_abs1);');
    %Bloc de deplacement absolu du moteur 1
    titre_deplacement_abs2=uicontrol(fenetre,'Style','text','Units','normalized','FontUnits','normalized','HorizontalAlignment','Center','FontSize',0.8,'String','Absolute travel (mm)','Position',[0.55 0.20 0.25 0.03]);
    val_deplacement_abs2=uicontrol(fenetre,'Style','edit','Units','normalized','Position',[0.55 0.15 0.05 0.04],'String',d_abs2str,'Callback','CB_pollux_depabs2');
    bouton_deplacement_abs2=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Go to','Position',[0.61 0.15 0.1 0.04],'Callback','PolluxDepAbs(Controller,numero(2),d_abs2);');
        %Bouton de reinitialisation de la position du moteur 1
    bouton_reinit1=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Set Current position to 0','Position',[0.7 0.8 0.25 0.04],'Callback',['fprintf(Controller,''0.0 ' num2str(numero(1)) ' setnpos'');']);
        %Bouton de reinitialisation de la position du moteur 2
    bouton_reinit2=uicontrol(fenetre,'Style','PushButton','Units','normalized','String','Set Current position to 0','Position',[0.7 0.76 0.25 0.04],'Callback',['fprintf(Controller,''0.0 ' num2str(numero(2)) ' setnpos'');']);
end

%% Boucle infini
while(STOP)
    drawnow
    if(Nmoteur==1)
        position=PolluxPosition(Controller,numero(1));
        set(ind_position1,'String',['Current position ' num2str(numero(1)) ' : ' num2str(position(1))]);
    elseif(Nmoteur==2)
        position(1)=PolluxPosition(Controller,numero(1));
        position(2)=PolluxPosition(Controller,numero(2));
        set(ind_position1,'String',['Current position ' num2str(numero(1)) ' : ' num2str(position(1))]);
        set(ind_position2,'String',['Current position ' num2str(numero(2)) ' : ' num2str(position(2))]);
    end
end

%% Fermeture et nettoyage de la memoire
PolluxClose(Controller,COM_Port);
close all
clear all