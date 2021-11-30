clear
close all

fprintf('Reading data\n');
T=readtable('BACE-1_all_depvar_removed1322_3664_3685_3686_5073.csv','readvariablenames',true,'preservevariablename',true);
T(any(isnan(T.("IC50 (nM)")), 2), :) = [];

%Selecting IC50 Data
IC50=T(1:end,3); 
IC50=table2array(IC50);
IC50=log10(IC50);

%calculating mean and standard deviation
mu=mean(IC50);
sigma=std(IC50);

%setting number of bins to 50
Nbins=50;

%setting bins for  std with 50 bins
[X, IC50]=BCH_data_distributions (IC50,Nbins);

%bins as the x-axis and the counts as the y-axis
figure(1); plot(X,IC50,'-o')

%make the plot pretty
xlabel('IC50 (nM)'); %X-axis label
ylabel('Discrete Probability'); %Y-axis label
title('Distribution of Binding Data'); %Title of graph
legend({'IC50 (nM)'}); %Creates a legend


%Normalization of figure 1
figure(2); plot(X,IC50/sum(IC50),'-o')

%Creating a normalized distribution using the mean and std dev from the dataset 
normal_dist=1/(2*pi*sigma*sigma)*exp(-((X-mu).^2)/(2*sigma*sigma));

%adding the normalized distribution to figure 2, normalized to an integral of 1
hold on
plot(X,normal_dist/sum(normal_dist))


%make the plot pretty
xlabel('Log10(IC50)'); %X-axis label
ylabel('Discrete Probability'); %Y-axis label
title('Base 10 Logarithmic Transformation of Binding Data'); %Title of graph
legend({'Log10(IC50)','Normal Distribution'}); %Creates a legend

