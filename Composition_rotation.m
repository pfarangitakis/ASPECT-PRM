%%% This is an example script of how rotation is applied to an orthogonal model in the submitted manuscript to EPSL titled 
%%% "The impact of oblique inheritance and changes in relative plate motion on continent-ocean transform margins"
%%% By Farangitakis et al. 

clear all
close all
% RESHAPE PARAVIEW EXPORT IN THE SAME MANNER AS A .PRM FILE
m=csvread('fullriftbox.csv',1,0); % Read paraview output and remove header
n=m(1:end,[7 8 9 2 3 4 5 6]); % Get X Y Z Eii Upper Lower Mantle Seed
uniqueb=unique(n,'rows'); % Get unique values
sorted=sortrows(uniqueb,[3 2 1]); % Sort on Z,Y,X
Xun=unique(uniqueb(:,1),'rows'); % Get unique X values
Yun=unique(uniqueb(:,2),'rows'); % Get unique Y values
Zun=unique(uniqueb(:,3),'rows'); % Get unique Z values
eiiun=unique(uniqueb(:,4),'rows'); % Get unique eii values
upperun=unique(uniqueb(:,5),'rows'); % Get unique upper values
lowerun=unique(uniqueb(:,6),'rows'); % Get unique lower values
mantleun=unique(uniqueb(:,7),'rows'); % Get unique mantle values
seedun=unique(uniqueb(:,8),'rows'); % Get unique seed values
%------------------------------------------------------------------------
%Start loop
k=size(Zun,1); %Get number of layers

for j=1:k

% Get one layer of the unique matrix.
% Height of same z layer. In this case this is calculated by dividing the
% total size of the unique value matrix by the number of z layers that are
% in the model. This requires the model to be a regular x,y,z box.
hgt=size(sorted,1)/k; 
layer=sorted(((j-1)*hgt)+1:j*hgt,[1 2 4 5 6 7 8]);
% Reshape inputs in a specific array to make the meshgrid afterwards
dim=sqrt(hgt);
x=unique(layer(:,1));
x=x';
y=unique(layer(:,2));
y=y';
eii=layer(:,3);
eii=eii';
Eii=reshape(eii,[dim,dim]);
upper=layer(:,4);
upper=upper';
Upper=reshape(upper,[dim,dim]);
lower=layer(:,5);
lower=lower';
Lower=reshape(lower,[dim,dim]);
mantle=layer(:,6);
mantle=mantle';
Mantle=reshape(mantle,[dim,dim]);
seed=layer(:,7);
seed=seed';
Seed=reshape(seed,[dim,dim]);
Zi=Zun(j,1);
xfake=0:3125:1200000;
yfake=0:3125:1200000;
[Xfq,Yfq]=meshgrid(xfake,yfake);
% Make a meshgrid from the layer
[X,Y] = meshgrid(x,y);
bigEii=interp2(Xfq,Yfq,Eii,X,Y,'spline');
bigUpper=interp2(Xfq,Yfq,Upper,X,Y,'spline');
bigLower=interp2(Xfq,Yfq,Lower,X,Y,'spline');
bigMantle=interp2(Xfq,Yfq,Mantle,X,Y,'spline');
bigSeed=interp2(Xfq,Yfq,Seed,X,Y,'spline');
%------------------------------------------
% Create query grid

% Create meshgrid
Xinit = 0:3125:800000;
Yinit = 0:3125:800000;
[Xq,Yq] = meshgrid(Xinit,Yinit);
% Add a Z to show a surface
% Vis = sin(Xq/40000) .* cos(Yq/40000);  
% % Plot the original grid
% figure
% mesh(Xq,Yq,Vis)                                           
% grid on
% Create vector matrix
XY = [Xq(:) Yq(:)];                                     
theta=5; % Rotate counter clockwise by theta (deg)
R=[cosd(theta) -sind(theta); sind(theta) cosd(theta)]; % Rotation Matrix
rotXY=XY*R'; % Multiply vector by Rotation Matrix
Xqr = reshape(rotXY(:,1), size(Xq,1), []);
Yqr = reshape(rotXY(:,2), size(Yq,1), []);
% Plot Rotated Grid
% figure
% mesh(Xqr,Yqr,Vis)                                          
% grid on
% Apply Matrix Shift
Xqrs = Xqr+236384.417;
Yqrs = Yqr+166659.823;
% % Plot rotated and shifted matrix
% figure
% mesh(Xqrs, Yqrs, Vis)                                     
% grid on

%---------------------------------------------------
% Interpolation
finalEii=interp2(X,Y,bigEii,Xqrs,Yqrs,'spline');
finalUpper=interp2(X,Y,bigUpper,Xqrs,Yqrs,'spline');
finalLower=interp2(X,Y,bigLower,Xqrs,Yqrs,'spline');
finalMantle=interp2(X,Y,bigMantle,Xqrs,Yqrs,'spline');
finalSeed=interp2(X,Y,bigSeed,Xqrs,Yqrs,'spline');
% % Plot original grid
% figure
% mesh(X,Y,bigSeed)                                          
% grid on
% % Plot sampled grid
% figure
% mesh(Xqrs, Yqrs, finalSeed)                                     
% grid on
%----------------------------------------------------
% Put Xfin,Yfin,Zfin,Tfin into columns
Xfin=reshape(Xq',[],1);
Yfin=reshape(Yq',[],1);
Eiifin=reshape(finalEii,[],1); 
Upperfin=reshape(finalUpper,[],1); 
Lowerfin=reshape(finalLower,[],1); 
Mantlefin=reshape(finalMantle,[],1); 
Seedfin=reshape(finalSeed,[],1); 
Zfin=Zi*ones(size(Eiifin));
% % Plot final grid
% figure
% mesh(Xq, Yq, finalSeed)                                     
% grid on
% Put Xfin,Yfin,Zfin,Tfin in one matrix
Layerout{j}=[Xfin Yfin Zfin Eiifin Upperfin Lowerfin Mantlefin Seedfin];
end 
out = cat(1,Layerout{:});

%-----------------------------------------------------
% Export into ASPECT Readable format
% INSERT HEADERS 
header1='x';
header2='y';
header3='z';
header4='total_strain';
header5='upper';
header6='lower';
header7='mantle';
header8='seed';
% EXPORT AS READABLE ASCII FILE FROM ASPECT
fid2=fopen('test2comp.txt','w'); %w is write
fprintf(fid2,'# POINTS: %d %d %d \n', [257 257 33]);
fprintf(fid2, ['# Columns: ' header1 ' ' header2 ' ' header3 ' ' header4 ' ' header5 ' ' header6 ' ' header7 ' ' header8 '\n']);
fprintf(fid2, '%f %f %f %f %f %f %f %f \n', [out]');
fclose(fid2);
