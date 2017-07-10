function [cost, grad, preds] = cnnCost(theta,images,labels,numClasses,...
                                filterDim,numFilters,poolDim,pred)
% Calcualte cost and gradient for a single layer convolutional
% neural network followed by a softmax layer with cross entropy
% objective.
%                            
% Parameters:
%  theta      -  unrolled parameter vector
%  images     -  stores images in imageDim x imageDim x numImges
%                array
%  numClasses -  number of classes to predict
%  filterDim  -  dimension of convolutional filter                            
%  numFilters -  number of convolutional filters
%  poolDim    -  dimension of pooling area
%  pred       -  boolean only forward propagate and return
%                predictions
%
%
% Returns:
%  cost       -  cross entropy cost
%  grad       -  gradient with respect to theta (if pred==False)
%  preds      -  list of predictions for each example (if pred==True)


if ~exist('pred','var')
    pred = false;
end;


imageDim = size(images,1);
numImages = size(images,3);

%% Reshape parameters and setup gradient matrices

% ��unrolled�Ĳ�������Ϊ������ȫ���Ӳ��Ȩ�ؾ����bias
[Wc, Wd, bc, bd] = cnnParamsToStack(theta,imageDim,filterDim,numFilters,...
                        poolDim,numClasses);

Wc_grad = zeros(size(Wc));
Wd_grad = zeros(size(Wd));
bc_grad = zeros(size(bc));
bd_grad = zeros(size(bd));

%%======================================================================
%% STEP 1a: ǰ�򴫲�

%% ��������
% ��������������ά��
convDim = imageDim-filterDim+1; 
% ��ֵ�ػ����������ά��
outputDim = (convDim)/poolDim; 

% ��ʼ�����������ȡ����������
activations = zeros(convDim,convDim,numFilters,numImages);

% ��ʼ���ػ�����������
activationsPooled = zeros(outputDim,outputDim,numFilters,numImages);

% ���������ȡ����
activations = cnnConvolve(filterDim, numFilters, images, Wc, bc); 
% ��ֵ�ػ�����
activationsPooled = cnnPool(poolDim, activations);

% ��4-D��������ת��Ϊ2-D�ģ���Ϊsoftmax������룬��ͼ����numImagesΪ�н���ת��
activationsPooled = reshape(activationsPooled,[],numImages);

%% Softmax Layer
% ���ػ��������ת��Ϊ��ά���󣬼�����������hiddenSize��ѵ��ͼ�����numImages���������softmax���ʼ���

% ��ʼ��numClasses*numImages�ľ��������洢ÿһ��ͼ���Ӧ��ÿһ����ǩ�ĸ���
probs = zeros(numClasses,numImages);

% ����hypothesis-h(x)
M = Wd*activationsPooled+repmat(bd,[1,numImages]); 
M = exp(M);
probs = bsxfun(@rdivide, M, sum(M));
%%======================================================================
%% Softmax�����cost
% ����ѵ����������ȷ���ֵ����һ���õ��ĸ�����Ϊ���룬���㽻���ض��󣬲��ұ�����cost��
% cost��ʼ��
cost = 0;

% ������Ҫ��labelsŪ��one-hot���룬��2-D����numClasses��numImages
groundTruth = full(sparse(labels, 1:numImages, 1));

%���չ�ʽ���㣬��������������
cost = -1./numImages*groundTruth(:)'*log(probs(:));

% �����ǰֻ����Ԥ�⣬��ôֻ����Ԥ��ı�ǩ�����ٽ��м��㣬����testʱ������

if pred
    [~,preds] = max(probs,[],1);
    preds = preds';
    grad = 0;
    return
end
%======================================================================
%% ���򴫲�
% ������㽫���򴫲���softmax��;��&�ػ��㣬��ÿһ�㱣���Ӧ����������
% �����ݶ�ֵ������ݶ��½����ĵ�����

% ����ṹ: images--> convolvedFeatures--> activationsPooled--> probs

% ���򴫲���softmax��������
delta_d = -(groundTruth-probs); 

% ���򴫲����ػ���������
delta_s = Wd'*delta_d;
delta_s = reshape(delta_s,outputDim,outputDim,numFilters,numImages);

% ���򴫲��������������
delta_c = zeros(convDim,convDim,numFilters,numImages);
for i=1:numImages
    for j=1:numFilters
        delta_c(:,:,j,i) = (1./poolDim^2)*kron(delta_s(:,:,j,i), ones(poolDim));
    end
end

delta_c = activations.*(1-activations).*delta_c;

%% �ݶȼ���
% ��delta_d����softmax��Ȩ��ϵ�����ݶ�ֵ
Wd_grad = (1./numImages)*delta_d*activationsPooled';
% ��delta_d����softmax��bias����ݶ�ֵ��ע��������Ҫ���
bd_grad = (1./numImages)*sum(delta_d,2);

% ��delta_c��������Ȩ��ϵ����bias��ĵ��ݶ�ֵ
for i=1:numFilters
    Wc_i = zeros(filterDim,filterDim);
    for j=1:numImages  
        Wc_i = Wc_i+conv2(squeeze(images(:,:,j)),rot90(squeeze(delta_c(:,:,i,j)),2),'valid');
    end

    Wc_grad(:,:,i) = (1./numImages)*Wc_i;
    
    bc_i = delta_c(:,:,i,:);
    bc_i = bc_i(:);
    bc_grad(i) = sum(bc_i)/numImages;
end

%% ���ݶ�����չ��������������ΪminFunc������
grad = [Wc_grad(:) ; Wd_grad(:) ; bc_grad(:) ; bd_grad(:)];

end