%Starting program
clear
close all

%Read in the table with all binding and MD data
fprintf('Reading data\n');
T=readtable('BACE-2_input.csv','readvariablenames',true,'preservevariablename',true);
T.("IC50 (nM)") = str2double(T.("IC50 (nM)"));
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
indvar1=T(:,5:1148);
indvar2=T(:,1150:end);
indvar=[indvar1 indvar2];

%Create array from indvar
Aindvar=table2array(indvar);

%This sets NaN values in our independent variables to 0
Aindvar(isnan(Aindvar))=0;
%Aindvar(isinf(Aindvar))=0;

%PCA fails due to the multitude of variables and 0s
%fprintf('Running PCA\n');
%[coeff,score,latent,tsquared,explained,mu]=pca(Aindvar);

Indep_vars=indvar.Properties.VariableNames; %grab the names of the independent variables
Xtot=Aindvar; %grab the values of the independent variables
[Obs,Vars]=size(Xtot);%number of observations and variables

Xsave=Xtot;

% num_train=floor(fraction_train*Obs);
% num_test=Obs-num_train;

%input('Data ready. Press enter to continue','s');
fprintf('Data loaded\n');

Binding=Adepvar;
N=size(Binding,1);

%NOT USING
%Since we are going to compare datasets, we should normalize them
% medianB=median(Binding);
% Binding=Binding./repmat(medianB,[N,1]);

X=Aindvar;

% Binding(isnan(Binding))=0.01;
% Binding(Binding==0)=0.01;
Y=Binding;

Y=log10(Binding);

% Y=Y(randperm(size(Y,1)),:);  %randomize for a check
%can add noise
 %Yorig=Y;
 %for i=1:width(depvar)
 %    Y(:,i)=normrnd(Y(:,i),0.1);
 %end
% 

numtargets=1;

train_fraction=0.8; %fraction of dataset used for training

%break into train and test
numObservations = size(Y,1);
numObservationsTrain = floor(train_fraction*numObservations);
numObservationsTest = numObservations - numObservationsTrain;

idx = randperm(numObservations);
idxTrain = idx(1:numObservationsTrain);
idxTest = idx(numObservationsTrain+1:end);

XTrain = X(idxTrain,:);
XTest = X(idxTest,:);
YTrain = Y(idxTrain,:);
YTest = Y(idxTest,:);
%YTrain_orig = Yorig(idxTrain,:);
%YTest_orig = Yorig(idxTest,:);

numFeatures=size(XTrain,2);

layers = [
    featureInputLayer(numFeatures,'Normalization', 'zscore')
    fullyConnectedLayer(600)
    reluLayer
    fullyConnectedLayer(900)
    reluLayer
%    fullyConnectedLayer(500)
%    reluLayer
    fullyConnectedLayer(numtargets)
    regressionLayer];


options = trainingOptions('adam',...
    'MiniBatchSize',100,...
    'Shuffle','every-epoch',...
    'Plots','training-progress',...
    'MaxEpochs',10,...
    'InitialLearnRate',0.003,...
    'LearnRateDropFactor',0.80,...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',2,...
    'Verbose',false);

net = trainNetwork(XTrain,YTrain,layers,options);

figure(1);
YPredTest = predict(net,XTest);%,'MiniBatchSize',miniBatchSize);
scatter(YTest(1:end)',YPredTest(1:end)')
title('Test Data');
xlabel('Log Measured Values');
ylabel('Log Predicted Values');
corr(YTest,YPredTest)
%immse(double(YPredTest),YTest)%calculate the mean squared error

figure(2);
YPredTrain = predict(net,XTrain);%,'MiniBatchSize',miniBatchSize);
scatter(YTrain(1:end)',YPredTrain(1:end)')
title('Training Data');
xlabel('Log Measured Values');
ylabel('Log Predicted Values');
corr(YTrain,YPredTrain)

%Add in BACE-1
input('Press enter to continue','s');

T2=readtable('BACE-1_input.csv','readvariablenames',true,'preservevariablename',true);
T2(any(isnan(T2.("IC50 (nM)")), 2), :) = [];

%Pull out dependent variables (binding data)
fprintf('Cleaning up Data\n');
depvar2=T2(:,3);

%This sets a string to a double
%depvar.('Kd (nM)')=str2double(depvar.('Kd (nM)'));
%depvar.('EC50 (nM)')=str2double(depvar.('EC50 (nM)'));

%Create array from depvar
Adepvar2=table2array(depvar2);

%Pull out independent variables (MD)
indvara=T2(:,7:1150);
indvarb=T2(:,1152:end);
indvar2=[indvara indvarb];

%Create array from indvar
Aindvar2=table2array(indvar2);

%This sets NaN values in our independent variables to 0
Aindvar2(isnan(Aindvar2))=0;
%Aindvar(isinf(Aindvar))=0;

%PCA fails due to the multitude of variables and 0s
%fprintf('Running PCA\n');
%[coeff,score,latent,tsquared,explained,mu]=pca(Aindvar);

Indep_vars2=indvar2.Properties.VariableNames; %grab the names of the independent variables
Xtot2=Aindvar2; %grab the values of the independent variables
[Obs2,Vars2]=size(Xtot2);%number of observations and variables

Xsave2=Xtot2;

% num_train=floor(fraction_train*Obs);
% num_test=Obs-num_train;

%input('Data ready. Press enter to continue','s');
fprintf('Data loaded\n');

Binding2=Adepvar2;
N2=size(Binding2,1);

%NOT USING
%Since we are going to compare datasets, we should normalize them
% medianB=median(Binding);
% Binding=Binding./repmat(medianB,[N,1]);

X2=Aindvar2;

% Binding(isnan(Binding))=0.01;
% Binding(Binding==0)=0.01;
Y2=Binding2;

Y2=log10(Binding2);


figure(3);
YPred2 = predict(net,X2);%,'MiniBatchSize',miniBatchSize);
scatter(Y2(1:end)',YPred2(1:end)')
title('BACE-2 Model Used on BACE-1');
xlabel('Log Measured Values');
ylabel('Log Predicted Values');
text(4,20,['Corr: ',num2str(corr(Y2,YPred2))]);
corr(Y2,YPred2)
