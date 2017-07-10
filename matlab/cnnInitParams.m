function theta = cnnInitParams(imageDim,filterDim,numFilters,...
                                poolDim,numClasses)
% Initialize parameters for a single layer convolutional neural
% network followed by a softmax layer.
%                            
% Parameters:
%  imageDim   -  height/width of image
%  filterDim  -  dimension of convolutional filter                            
%  numFilters -  number of convolutional filters
%  poolDim    -  dimension of pooling area
%  numClasses -  number of classes to predict
%
%
% Returns:
%  theta      -  unrolled parameter vector with initialized weights

%% �����ʼ������
assert(filterDim < imageDim,'filterDim must be less that imageDim');

% Wc = 1e-1*randn(filterDim,filterDim,numFilters);

% ��ά������ͼ��ά��
outDim = imageDim - filterDim + 1;

% outDimӦ���ܱ��ػ�ά������
assert(mod(outDim,poolDim)==0,...
       'poolDim must divide imageDim - filterDim + 1');

% �ػ��������ά��
outDim = outDim/poolDim;
% �����ػ��������ά��
hiddenSize = outDim^2*numFilters;

% ���Ǻ����r��ȡֵ
r  = sqrt(6) / sqrt(numClasses+hiddenSize+1);

% ������ȫ���Ӳ��Ȩ�ؾ���
Wc = 1e-1*randn(filterDim,filterDim,numFilters);
Wd = rand(numClasses, hiddenSize) * 2 * r - r;

% ������ȫ���Ӳ��bias��
bc = zeros(numFilters, 1);
bd = zeros(numClasses, 1);

% �����еĲ���չ������һ��������
theta = [Wc(:) ; Wd(:) ; bc(:) ; bd(:)];

end

