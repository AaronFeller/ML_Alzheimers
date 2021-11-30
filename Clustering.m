clear
close all

%Read in the table with all binding and MD data
fprintf('Reading data\n');
T=readtable('final.csv','readvariablenames',true,'preservevariablename',true);
T(any(isnan(T.("IC50 (nM)")), 2), :) = [];

%Pull out dependent variables (binding data)
fprintf('Cleaning up Data\n');
depvar=T(:,3);

%This sets a string to a double
%depvar.('Kd (nM)')=str2double(depvar.('Kd (nM)'));
%depvar.('EC50 (nM)')=str2double(depvar.('EC50 (nM)'));

%Create array from depvar
Adepvar=table2array(depvar);

%Pull out independent variables (MD)
indvar=T(:,8:50);

%indvar1=T(:,8:1150);
%indvar2=T(:,1152:end);
%indvar=[indvar1 indvar2];

%Create array from indvar
Aindvar=table2array(indvar);


Y=Adepvar; %dependent variable
Y=log10(Y);

xmatrix=Aindvar; %independent variable
num_data_points=length(Y); %we need to know the number of data points

%Normalization
max_xmatrix=max(xmatrix); %this takes the maximum of each indep var 
normx=ones(10152,1)*max_xmatrix; %Create a normalization matrix
norm_xmatrix=xmatrix./normx; %Normalize the xmatrix

x=norm_xmatrix;
x(isnan(x))=0;


%Setting a colormap for graphing
colormap(cool(2))
f = zeros(size(Y));
%f(strcmp(diag,'B')) = 1;
%f(strcmp(diag,'M')) = 2;

f = Y <= 2;


[coeff,score,latent,tsquared,explained,mu]=pca(x);
% score * coefficient + mu = data (mu is the center of the axes)
% latent scores the new axes while explained is percentage-wise

figure(1);
scatter3(score(:,1),score(:,2),score(:,3),[],f,'filled');
input('pause','s');

Y=tsne(xmatrix,'Algorithm','barneshut','NumDimensions',3,'NumPCAComponents',8);
figure(2);
scatter3(Y(:,1),Y(:,2),Y(:,3),[],f,'filled');
