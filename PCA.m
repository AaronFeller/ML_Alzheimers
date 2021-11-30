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
indvar=T(:,7:250);

%Create array from indvar
Aindvar=table2array(indvar);


Y=Adepvar; %dependent variable
Y=log10(Y);
num_data_points=length(Y); %we need to know the number of data points

xmatrix=Aindvar; %independent variable

%Normalization
max_xmatrix=max(xmatrix); %this takes the maximum of each indep var 
normx=ones(10152,1)*max_xmatrix; %Create a normalization matrix
norm_xmatrix=xmatrix./normx; %Normalize the xmatrix


x=norm_xmatrix;
[coeff,score,latent,tsquared,explained,mu]=pca(x)
% score * coefficient + mu = data (mu is the center of the axes)
% latent scores the new axes while explained is percentage-wise


num_comp=10;
red_x=score(:,1:num_comp)*coeff(:,1:num_comp)' + repmat(mu,10152,1);


%y=a1x + a2x + ... +a20x  linear regression
X=xmatrix'*xmatrix; %remember we can create the coefficients of the Jacobian this way for a linear regression
XY=xmatrix'*Y; %This gives us the values on the right side of the equation in the Jacobian
A=X\XY; %calculate the values of the best fit parameters as inverse of X times XY
Ycalc=xmatrix*A; %Now recalculate the values of Y based on the fit
figure(1)
scatter(Y,Ycalc) %make a scatter plot comparing the fit values vs. the actual values
title('Measured vs. linear fit using all original parameters')
xlabel('Original Values'); %label the x axis
ylabel('Fit Values'); %label the y axis
text(mean(Y),0.9*max(Ycalc),['Corr = ',num2str(corr(Ycalc,Y))]) %calculate the correlation between fit and observed and print

%Scatter plot
figure(2)
scatter(norm_xmatrix(1:end),red_x(1:end));
title('Original parameter values vs. PCA approximated values');
xlabel('Original Values');
ylabel('PCA approximation');
text(min(red_x(1:end)),0.9*max(norm_xmatrix(1:end)),['Corr = ',num2str(corr(norm_xmatrix(1:end)',red_x(1:end)'))])


%y=a1x + a2x + ... +a20x  linear regression
xmatrix=score(:,1:num_comp);%The next few lines redo the linear fit using the PCA values instead of norm_x
X=xmatrix'*xmatrix;
XY=xmatrix'*Y;
A=X\XY;
Ycalc=xmatrix*A;

%Figure of measured vs linear fit using PCA set
figure(3)
scatter(Y,Ycalc)
title('Measured vs Linear Fit using PCA reduced parameter set')
xlabel('Original Values');
ylabel('Fit Values');
text(min(Y),0.9*max(Ycalc),['Corr = ',num2str(corr(Ycalc,Y))])

corr(Ycalc,Y);

%In order to evaluate the fit, we are going train the system on some of the
%data and then set if we can predict data we never trained on
%y=a1x + a2x + ... +a20x  linear regression
Bin_index=false(num_data_points,1); %this just initializes a binary index

%the next line uses a function called datasample that randomly picks values
%from a group of values.  It also uses floor which rounds a number down to
%the closest integer.  So we are sampling 90% of the observations and will
%use that to train the system... to calculate the linear coefficients.
%Then we will use those coefficients to calculate the dependent variable
%values for the other 10% and plot those.
Index=datasample(1:num_data_points,floor(0.9*num_data_points),'Replace',false);
Bin_index(Index)=true(1);%set the sampled values to true in the index
xmatrix=score(Bin_index,1:num_comp);%create an xmatrix with just the sampled observations
X=xmatrix'*xmatrix; %the next few lines do the linear fit
XY=xmatrix'*Y(Bin_index);
A=X\XY;
Ycalc=score(~Bin_index,1:num_comp)*A; %here we recalculate the original dependent variable values with the observations not used in the training
figure(4)
scatter(Y(~Bin_index),Ycalc)%plot just the values not used in the training
title('Measured vs. linear fit using PCA values for samples not in training set');
xlabel('Original Values');
ylabel('Fit Values');
text(min(Y(~Bin_index)),0.9*max(Ycalc),['Corr = ',num2str(corr(Ycalc,Y(~Bin_index)))])

% 
% %This fits a gaussian (maybe?)
% modelfun= @(a,x) a(1).*exp(-(x-a(2)).^2/(2.*a(3)^2));
% 
% beta0 = [1,600,40];
% 
% 
% %Fit the model
% mdl = fitnlm(x,Y,modelfun,beta0);

