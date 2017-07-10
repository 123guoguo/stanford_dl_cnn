function [opttheta] = minFuncSGD(funObj,theta,data,labels,...
                        options)
% ����ݶ��½����������������ÿһ�ε�����theta
% 
%
% Parameters:
%  funObj     -  function handle which accepts as input theta,
%                data, labels and returns cost and gradient w.r.t
%                to theta.
%  theta      -  unrolled parameter vector
%  data       -  stores data in m x n x numExamples tensor
%  labels     -  corresponding labels in numExamples x 1 vector
%  options    -  struct to store specific options for optimization
%
% Returns:
%  opttheta   -  optimized parameter vector
%
% Options (* required)
%  epochs*     - number of epochs through data
%  alpha*      - initial learning rate
%  minibatch*  - size of minibatch
%  momentum    - momentum constant, defualts to 0.9


%%======================================================================
%% Setup
assert(all(isfield(options,{'epochs','alpha','minibatch'})),...
        'Some options not defined');
if ~isfield(options,'momentum')
    options.momentum = 0.9;
end;
epochs = options.epochs;
alpha = options.alpha;
minibatch = options.minibatch;
m = length(labels);
% ����
mom = 0.5;
momIncrease = 20;
velocity = zeros(size(theta));

%%======================================================================
%% ����ݶ��½�
it = 0;
for e = 1:epochs
    
    % �������ѵ��������˳��
    rp = randperm(m);
    
    for s=1:minibatch:(m-minibatch+1)
        it = it + 1;

        % ��ÿһ��it�ﵽmomIncreaseʱ�����³���
        if it == momIncrease
            mom = options.momentum;
        end;

        % ����minibatch��ȡѵ������
        mb_data = data(:,:,rp(s:s+minibatch-1));
        mb_labels = labels(rp(s:s+minibatch-1));

        % ����Ŀ�꺯��ֵ
        [cost grad] = funObj(theta,mb_data,mb_labels);
        
        
        % ����theta��ufldl�̳�Optimization: Stochastic Gradient Descent
        velocity = mom*velocity+alpha*grad;
        theta = theta-velocity;
        fprintf('Epoch %d: Cost on iteration %d is %f\n',e,it,cost);
    end;

    % ÿ�ε�����˥��learning rate
    alpha = alpha/2.0;

end;

opttheta = theta;

end
