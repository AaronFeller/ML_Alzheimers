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
% indvar1=T(:,7:1150);
% indvar2=T(:,1152:end);
% indvar=[indvar1 indvar2];
indvar=T(:,1882:end);


%Create array from indvar
Aindvar=table2array(indvar);


Y=Adepvar; %dependent variable
Y=log10(Y);
num_data_points=length(Y); %we need to know the number of data points

xmatrix=Aindvar; %independent variable


%Multiplying arrays (non-normalized)
X=xmatrix'*xmatrix;%this generates all the coefficients in the Jacobian (the partial differential equations set to zero)
XY=xmatrix'*Y;%This generates the term on the left side of the Jacobian differential equations
Z=X\XY; %this takes the inverse of X and multiplies it by XY to get A
Ycalc=xmatrix*Z; %This calculates the fit values for Y

%Correlation coefficient to printout
Corr_coef=corr(Y,Ycalc);

%Plot figure 1
figure(1)
scatter(Y,Ycalc)
xlabel('Original Values');
ylabel('Fit Values');
title('Ytrue vs Ycalc');
text(mean(Y),0.9*max(Ycalc),['Corr = ',num2str(corr(Y,Ycalc))])








% 
% %Normalization
% max_xmatrix=max(xmatrix); %this takes the maximum of each indep var 
% normx=ones(height(xmatrix),1)*max_xmatrix; %Create a normalization matrix
% norm_xmatrix=xmatrix./normx; %Normalize the xmatrix
% 
% %Multiplying arrays (normalized)
% X=norm_xmatrix'*norm_xmatrix;
% XY=norm_xmatrix'*Y;
% Znorm=X\XY;
% Ycalc=norm_xmatrix*Znorm;
% 
% %Plot figure 2
% figure(2)
% scatter(Y,Ycalc)
% xlabel('Measured Time until Death, Transplantation, or End of Study');
% ylabel('Predicted Time Until Death or Transplantation');
% title('Predicted Survival Time of Patients with Primary Biliary Cirrhosis');
% text(mean(Y),0.9*max(Ycalc),['Corr = ',num2str(corr(Y,Ycalc))])
% 
% %Table of correlation by independent variable
% Names= indvar.Properties.VariableNames; %Get the names of the indep vars
% Indep_var_names=Names; %Just want the independent ones
% TA=array2table(Znorm','VariableNames',Indep_var_names) %create the table
