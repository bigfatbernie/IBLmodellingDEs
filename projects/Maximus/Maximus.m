% Maximums' search for Vengeance begins here
%
% function [Mx]=Maximus(Ms,Mhr,Mh,Mrr,Mhv,Mtf,Pr,Ps,Phr,Phv)
%
% Ms - Maximus' walking speed (integer)
% Mhr - Maximus' hit rate (integer)
% Mh - Maximus' initial health (integer)
% Mrr - Maximus' health recovery rate (integer)
% Mhv - Maximus' hit value (damage done with each hit) (integer)
% Mtf - Maximus' training factor (>=1) (integer) - see below
% Pr - Praetorian's arrival rate (integer)
% Ps - Praetorian's walking speed (integer)
% Phr - Praetorian's hit rate (integer)
% Phv - Praetorian's hit value (integer)
%
% Sample call:
% Maximus(7,5,100,1,10,2,100,3,7,5);
%
% Praetorians will have the same initial health as Maximus...
%
% Returns 'Mx' - the distance Maximus walked
%  before dying (or getting to the end and
%  getting his Vengeance!)
%
% (C) May 2020, by F. Estrada
%  - Forum background from a photogaph by some dude named Paco
%    (he doesn't seem to mind)
%  - Sprites from OpenGameArt.org - distributed free for use
%    under OGA 3.0 license (included).
%    http://opengameart.org/


function [Mx]=Maximus(Ms,Mhr,Mh,Mrr,Mhv,Mtf,Pr,Ps,Phr,Phv)

fprintf(2,'********************************\n');
fprintf(2,'Input parameters:\n');
fprintf(2,'Maximus walking speed: %d\n',Ms);
fprintf(2,'Maximus hit rate: %d\n',Mhr);
fprintf(2,'Maximus initial health: %d\n',Mh);
fprintf(2,'Maximus health recovery rate: %d\n',Mrr);
fprintf(2,'Maximus hit value: %d\n',Mhv);
fprintf(2,'Praetorian arrival rate: %d\n',Pr);
fprintf(2,'Praetorian walking speed: %d\n',Ps);
fprintf(2,'Praetorian hit rate: %d\n',Phr);
fprintf(2,'Praetorian hit value: %d\n',Phv);
fprintf(2,'********************************\n\n');
    
load sprites.mat;
SpriteDist=64;
SpriteY=290;
SpriteS=size(max_walk,1);
SpriteHS=SpriteS/2;

Mx=SpriteHS+5;      % Initial position for Maximus
Mst=1;              % Initial state - walking
Mfr=0;              % Maximus' frame index (action dependent)
MaxHealth=Mh;       % Can't exceed initial health value

Prx=zeros(100,1);   % Positions of Praetorians, entry at Prx(1) is the leftmost one
Ph=zeros(100,1);    % Praetorian health
Pst=ones(100,1);    % State for each praetorian
Pfr=zeros(100,1);   % Frame id for each Praetorian
nPr=0;              % Number of Praetorians

% Agent update loop
MaxIsDone=0;
time_idx=0;          % Simulation time starts now...
time_nextPr=-1;      % Arrival of next Praetorian - we wait until one
                     % arrives to figure out when the next one will...

% Time increments in units by '1' each frame.
                     
while (~MaxIsDone)
    
    % Decide whether (and when) a Praetorian arrives
    if (time_nextPr==time_idx)
        % New praetorian!
        tPrx=size(back,2)-SpriteS-5;
        if (nPr>0)
          if (abs(Prx(nPr)-tPrx)<SpriteDist||abs(Mx-tPrx)<SpriteDist)
            fprintf(2,'Not looking good for Maximus... Praetorians fill the Forum!\n');
          else
            fprintf(2,'A new Praetorian arrives...\n');
            Prx(nPr+1)=tPrx;
            Pst(nPr+1)=1;
            Pfr(nPr+1)=1;
            Ph(nPr+1)=MaxHealth;
            nPr=nPr+1;
          end;          
        else
          fprintf(2,'A new Praetorian arrives...\n');
          Prx(nPr+1)=tPrx;
          Pst(nPr+1)=1;
          Pfr(nPr+1)=1;
          Ph(nPr+1)=MaxHealth;
          nPr=nPr+1;
        end;
    end;
    
    if (time_nextPr<time_idx)
        % The last Praetorian arrived a moment ago, find out when
        % the next one will arrive from a Poisson distribution
        % with the specified rate 'Pr'
        time_nextPr=time_idx+poissrnd(Pr);
        fprintf(2,'Praetorian arriving at %d\n',time_nextPr);
    end;
    
    % Decide what happens at this point
    % First, check whether Maximus can walk
    if (nPr==0)
        % Easy - nothing in sight but an empty forum
        if (Mst~=1)
            Mst=1;       % State change, reset frame index
            Mfr=0;
            fprintf(2,'Just having a nice walk down the Roman Forum... looking for Vengeance...\n');
        end;
        Mx=Mx+Ms;       % Maximus walks at the specified rate
        Mh=Mh+Mrr;      % Maximus' health recovers a bit
        Mfr=Mfr+1;      
        if (Mfr>size(max_walk,4)) Mfr=1; end;
        if (Mh>MaxHealth) Mh=MaxHealth; end;
        
        if (Mx>size(back,2)-SpriteS-Ms-5)
            Mst=5;
            Mfr=5;
            MaxIsDone=1;
        end;
    else
        % Find out if Maximus is close enough to a Praetorian to fight
        if (abs(Mx-Prx(1))<SpriteDist)
            % Fisticuffs!
            if (Mst==1)
                % State change from walking (for both Maximus and Praetorian)
                % Change state to 2 (waiting) and figure out when the blows
                % start landing...
                Mst=2;
                Pst(1)=2;
                Mfr=1;
                Pfr(1)=1;
                t_hitM=time_idx+poissrnd(Mhr);
                t_hitP=time_idx+poissrnd(Phr);
                fprintf(2,'Now we take turns hacking at each other!\n');
            end;
        
            if (Mst==2)
                % Waiting for the hits to land
                if (time_idx>=t_hitM)   
                    Mst=3;
                    Mfr=0;
                    fprintf(2,'Take that you filthy Praetorian!\n');
                end;
            end;
            if (Pst(1)==2)
                if (time_idx>=t_hitP)
                    Pst(1)=3;
                    Pfr(1)=0;
                    fprintf(2,'You cannot PASS!\n');
                end;
            end;
        
            if (Mst==3)
                % Attacking
                Mfr=Mfr+1;
                if (Mfr>size(max_atk,4)) 
                    % Attack completed - deduct health from Praetorian,
                    % figure out if the praetorian is dead, and also
                    % when the next hit would happen
                    Ph(1)=Ph(1)-(Mhv*(Mh/MaxHealth));
                    if (Ph(1)<=0)
                        % It's dead, Jim. (but got to wait for it to die!)
                        Pst(1)=4;
                        Pfr(1)=1;
                    end;
                    Mst=2;
                    Mfr=1;
                    t_hitM=time_idx+poissrnd(Mhr);
                    fprintf(2,'I feel Vengeance getting closer! Ph=%f, Mh=%f\n',Ph(1),Mh(1));
                end;
            end;
            
            if (Pst(1)==3)
                % Attacking
                Pfr(1)=Pfr(1)+1;
                if (Pfr(1)>size(praet_atk,4))
                    % Attack completed - see if it lands based on Maximus'
                    % training factor (He's Maximus After All!)
                    if (rand<1.0/Mtf)
                        Mh=Mh-(Phv*(Ph(1)/MaxHealth));
                        if (Mh<=0)
                            Mst=4;
                            Mfr=1;
                            fprintf(2,'I shall have my Vengeance! in the next life!\n');
                        end;
                    end;
                    Pst(1)=2;
                    Pfr(1)=1;
                    t_hitP=time_idx+poissrnd(Phr);
                end;
            end;
            
            if (Pst(1)==4)
                % Poor, poor praetorian
                Pfr(1)=Pfr(1)+1;
                if (Pfr(1)>size(praet_hurt,4))
                    % It's done for
                    Prx(1:99)=Prx(2:100);
                    Ph(1:99)=Ph(2:100);
                    Pst(1:99)=Pst(2:100);
                    Pfr(1:99)=Pfr(2:100);
                    nPr=nPr-1;
                end;
            end;
            
            if (Mst==4)
                Mfr=Mfr+1;
                if (Mfr>size(max_hurt,4))
                    MaxIsDone=1;
                    Mfr=size(max_hurt,4);
                end;
            end;
            
        else
            % We can walk
            if (Mst~=1)
                Mst=1;
                Mfr=0;
                fprintf(2,'Still having a nice walk down the Roman Forum... I see a victim...\n');
            end;
            Mx=Mx+Ms;
            Mh=Mh+Mrr;
            Mfr=Mfr+1;
            if (Mfr>size(max_walk,4)) Mfr=1; end;
            if (Mh>MaxHealth) Mh=MaxHealth; end;

            % And so can the Preatorian at the front
            Prx(1)=Prx(1)-Ps;
            Pfr(1)=Pfr(1)+1;
            if (Pfr(1)==size(praet_walk,4)) Pfr(1)=1; end;
        end;
        
        % Regardless of what is happening with Maximus and the leftmost
        % Praetorian, the remaining ones will try to walk
        for i=2:nPr
            if (abs(Prx(i)-Prx(i-1))>SpriteDist)
                Prx(i)=Prx(i)-Ps;
                Pfr(i)=Pfr(i)+1;
                if (Pfr(i)==size(praet_walk,4)) Pfr(i)=1; end;
            end;
        end;

    end;
    
    %% Composite frame and display!
    if (Pst(1)~=4) frame=back; else frame=backB; end;
    if (Mst==5) frame=backC; end;
    
    %% Maximus...
    chunk=frame(SpriteY:SpriteY+SpriteS-1,Mx:Mx+SpriteS-1,:);
    if (Mst==1||Mst==2)
        sprt=max_walk(:,:,:,Mfr);
        sprtM=max_wlk_msk(:,:,:,Mfr);
    end;
    if (Mst==3||Mst==5)
        sprt=max_atk(:,:,:,Mfr);
        sprtM=max_atk_msk(:,:,:,Mfr);
    end;
    if (Mst==4)
        sprt=max_hurt(:,:,:,Mfr);
        sprtM=max_hrt_msk(:,:,:,Mfr);
    end;
    chunk(find(sprtM))=sprt(find(sprtM));
    frame(SpriteY:SpriteY+SpriteS-1,Mx:Mx+SpriteS-1,:)=chunk;

    % Praetorians
    for i=1:nPr
        chunk=frame(SpriteY:SpriteY+SpriteS-1,Prx(i):Prx(i)+SpriteS-1,:);
        if (Pst(i)==1||Pst(i)==2)
            sprt=praet_walk(:,:,:,Pfr(i));
            sprtM=praet_wlk_msk(:,:,:,Pfr(i));
        end;
        if (Pst(i)==3)
            sprt=praet_atk(:,:,:,Pfr(i));
            sprtM=praet_atk_msk(:,:,:,Pfr(i));
        end;
        if (Pst(i)==4)
            sprt=praet_hurt(:,:,:,Pfr(i));
            sprtM=praet_hrt_msk(:,:,:,Pfr(i));
        end;
        chunk(find(sprtM))=sprt(find(sprtM));
        frame(SpriteY:SpriteY+SpriteS-1,Prx(i):Prx(i)+SpriteS-1,:)=chunk;
    end;
    
    figure(1);image(frame);axis image;axis off;
    time_idx=time_idx+1;
    drawnow;
    % Phew... who knew game engines were so messy...
end;
