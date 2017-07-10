clc;
clear;
close all;

% CSDN���͵�ַ����ӭָ�̣�
% http://blog.csdn.net/wblgers1234/article/details/70921248

%%======================================================================
%% ��һ������ʼ������������ѵ������

% ��������

% MNIST���ݿ�ͼƬ�Ĵ�СΪ28��28
imageDim = 28;

% Ҫ����������
numClasses = 10;

%������������ȡģ���ά��(�˲���ά��)
filterDim = 9; 

% ������ȡ�˲����ĸ���
numFilters = 20;

% �ػ���ά����Ӧ�ñ�imageDim-filterDim+1����
poolDim = 2;

% ����MNIST���ݿ��ѵ������
addpath function/;

images = loadMNISTImages('../MNIST/train-images-idx3-ubyte');
images = reshape(images,imageDim,imageDim,[]);
labels = loadMNISTLabels('../MNIST/train-labels-idx1-ubyte');
% �������ǩ0����ӳ�䵽10
labels(labels==0) = 10;

% ��ʼ������
theta = cnnInitParams(imageDim,filterDim,numFilters,poolDim,numClasses);

%%======================================================================
%% Gradient Check

% ����Ϊfalse��ζ�Ų���gradient check
DEBUG=false;
% DEBUG=true;
if DEBUG
    % To speed up gradient checking, we will use a reduced network and
    % a debugging data set
    db_numFilters = 2;
    db_filterDim = 9;
    db_poolDim = 5;
    db_images = images(:,:,1:10);
    db_labels = labels(1:10);
    db_theta = cnnInitParams(imageDim,db_filterDim,db_numFilters,...
                db_poolDim,numClasses);
    
    [cost grad] = cnnCost(db_theta,db_images,db_labels,numClasses,...
                                db_filterDim,db_numFilters,db_poolDim);
    

    % Check gradients
    numGrad = computeNumericalGradient( @(x) cnnCost(x,db_images,...
                                db_labels,numClasses,db_filterDim,...
                                db_numFilters,db_poolDim), db_theta);
 
    % Use this to visually compare the gradients side by side
    disp([numGrad grad]);
    
    diff = norm(numGrad-grad)/norm(numGrad+grad);
    % Should be small. In our implementation, these values are usually 
    % less than 1e-9.
    disp(diff); 
 
    assert(diff < 1e-9,...
        'Difference too large. Check your gradient computation again');
    
end;

%%======================================================================
%% ѵ��CNN����

options.epochs = 3;
options.minibatch = 256;
options.alpha = 1e-1;
options.momentum = .95;

opttheta = minFuncSGD(@(x,y,z) cnnCost(x,y,z,numClasses,filterDim,...
                      numFilters,poolDim),theta,images,labels,options);

%%======================================================================
%% ����CNN����

% ����MNIST���ݿ�Ĳ��Լ�
testImages = loadMNISTImages('../MNIST/t10k-images-idx3-ubyte');
testImages = reshape(testImages,imageDim,imageDim,[]);
testLabels = loadMNISTLabels('../MNIST/t10k-labels-idx1-ubyte');
testLabels(testLabels==0) = 10;

[~,cost,preds]=cnnCost(opttheta,testImages,testLabels,numClasses,...
                filterDim,numFilters,poolDim,true);

acc = sum(preds==testLabels)/length(preds);

% ��ӡ�����Լ��ķ���׼����
fprintf('Accuracy is %f\n',acc);
