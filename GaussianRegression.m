%reset matlab
clear
close all

%Read in dataset
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

%Create array from indvar
Aindvar=table2array(indvar);


Y=Adepvar; %dependent variable
Y=log10(Y);
num_data_points=length(Y); %we need to know the number of data points


%Creating tables for each column
x=Aindvar;
F=Adepvar;

%Creating gaussian non-linear models
gauss1 = @(a,x) a(1)*exp(-(x-a(2)).^2/(2*a(3)^2));
gauss2 = @(a,x) a(1)*exp(-(x-a(2)).^2/(2*a(3)^2))+a(4)*exp(-(x-a(5)).^2/(2*a(6)^2));
gauss3 = @(a,x) a(1)*exp(-(x-a(2)).^2/(2*a(3)^2))+a(4)*exp(-(x-a(5)).^2/(2*a(6)^2))+a(7)*exp(-(x-a(8)).^2/(2*a(9)^2));
gauss4 = @(a,x) a(1)*exp(-(x-a(2)).^2/(2*a(3)^2))+a(4)*exp(-(x-a(5)).^2/(2*a(6)^2))+a(7)*exp(-(x-a(8)).^2/(2*a(9)^2))+a(10)*exp(-(x-a(11)).^2/(2*a(12)^2));
gauss5 = @(a,x) a(1)*exp(-(x-a(2)).^2/(2*a(3)^2))+a(4)*exp(-(x-a(5)).^2/(2*a(6)^2))+a(7)*exp(-(x-a(8)).^2/(2*a(9)^2))+a(10)*exp(-(x-a(11)).^2/(2*a(12)^2))+a(13)*exp(-(x-a(14)).^2/(2*a(15)^2));

%Creating guesses for non-linear models
beta1 = [1,600,40];
beta2 = [1,600,40,1,600,40];
beta3 = [1,600,40,1,600,40,1,600,40];
beta4 = [1,600,40,1,600,40,1,600,40,1,600,40];
beta5 = [1,600,40,1,600,40,1,600,40,1,600,40,1,600,40];

%Fitting Model
mdl = fitnlm(x,F,gauss5,beta5);
mdl;

%Predicting F values from model
F_calc=predict(mdl,x);

%Figure of F vs Fcalc
figure(1);
scatter(F,F_calc)
title('Measured vs. Predicted Values (Quintuple Gaussian)');
xlabel('Measured Fluorescence Values (F)');
ylabel('Predicted Fluorescence Values (F_c_a_l_c)');

%Correlation of F to Fcalc
corr(F,F_calc)

%Figure of Fit curve and dataset
figure(2)
plot(x,F,'o');
hold on
plot(x,F_calc,'-');
title('Spectrum Analysis (Quintuple Gaussian)');
xlabel('Wavelength (nM)');
ylabel('Fluorescence (mAu)');
hold off

%Figure of Residuals
figure(3)
plot(x,F_calc-F)
title('Residuals of Fit (Quintuple Gaussian)');
xlabel('Wavelength (mAu)');
ylabel('Difference from Fitted Model');
