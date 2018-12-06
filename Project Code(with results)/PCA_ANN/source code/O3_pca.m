% M contain training, validation and test data
M = csvread('C:\Users\ravip\Desktop\Project Code\PCA_ANN\input\pca_inp_O3_ec.csv');

% for O3 concentration
tar = M(2:5386,10)';
in = M(1:5385,1:9)';

% default layers-2, neurons in hidden layer-1, transfer function for
% layer1-tansig, for layer2-purelin and training function is trainlm.
% trainlm is a network training function that updates weight and bias 
% values according to Levenberg-Marquardt optimization ,batch mode training. 
net2 = feedforwardnet(13,'trainlm');
net2.layers{2}.transferFcn = 'tansig';
net2.divideFcn= 'divideind'; % divide the data manually
net2.divideParam.trainInd= 1:3288; % training data indices 
net2.divideParam.valInd= 3289:4383; % validation data indices 
net2.divideParam.testInd= 4384:5386;  % testing data indices 
% configure command automatically initializes the weights and biases.
net2 = configure(net2,in,tar);
view(net2)
% The magnitude of the gradient and the number of validation checks are used to terminate
% the training.
net2.trainParam.min_grad = 1e-5
net2.trainParam.max_fail = 6
[net2,tr2] = train(net2,in,tar)

net2.trainParam.showCommandLine = true
tr2
disp(['Gradient value: ',num2str(net2.trainParam.max_fail)]);
disp(['Validation check: ',num2str(net2.trainParam.min_grad)]);

% final NO2 RMSE

test = csvread('C:\Users\ravip\Desktop\Project Code\PCA_ANN\output\pca_inp_test_O3_ec.csv');
test1 = test(:,1:9)';
pca_ann_out_O3 = net2(test1);
test_y_O3 = test(:,10);
l=size(test_y_O3);
test_error_O3=0;
for i=1:l(1)
    test_error_O3=test_error_O3+(test_y_O3(i)-pca_ann_out_O3(i))^2;
end
test_error_O3=test_error_O3/l(1);
test_error_O3=sqrt(test_error_O3);

% prediction for next 8 hour NO2 concentration given user input for current
% 8 hour.
ben=input('BEN content = ');
std_ben=(ben-29.66167275)/9.92484156e+02;

bp=input('BP content = ');
std_bp=(bp-963.7569708)/3.93984556e+0;
co=input('CO content = ');
std_co=(co-1.15886557)/3.12051188e+00;

mpxy=input('MPXY content = ');
std_mpxy=(mpxy-14.61837287)/1.99947981e+02;

no=input('NO content = ');
std_no=(no-45.29929745)/2.92796198e+03;

no2=input('NO2 content = ');
std_no2=(no2-62.50785584)/1.82236367e+03;

o3=input('O3 content = ');
std_o3=(o3-87.5335371)/2.84270779e+03;

rh=input('RH content = ');
std_rh=(rh-51.4488899)/5.58119508e+02;

so2=input('SO2 content = ');
std_so2=(so2-17.13806569)/2.43777715e+02;

temp=input('TEMP content = ');
std_temp=(temp-26.39465024)/6.34750145e+01;

tol=input('TOL content = ');
std_tol=(tol-100.72950426)/6.12606999e+03;

wd=input('WD content = ');
std_wd=(wd-210.12961983)/6.32410041e+03;
ws=input('WS content = ');
std_ws=(ws-2.20836375)/1.65635669e+00;
k = [std_ben std_bp std_co std_mpxy std_no std_no2 std_o3 std_rh std_so2 std_temp std_tol std_wd std_ws];

E = csvread('C:\Users\ravip\Desktop\Project Code\PCA_ANN\output\eign_vec_ec.csv');
l = size(E);
A = zeros(1,l(2));
for m = 1:l(2)
    A(1,m) = dot(E(:,m),k);
end
B = A';
g = net2(B);
actual_g=g*(2.84270779e+03)+87.5335371;
disp(['predicted value(standardized) for O3: ',num2str(g)]);
disp(['predicted value(actual) for O3: ',num2str(actual_g)]);
if (actual_g>100)
    disp(['warning: O3 concentration for next 8 hour will exceed the normal limit.']);
else
    disp(['O3 concentration for next 8 hour will be in normal range']);
end
