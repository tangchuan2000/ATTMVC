clear;
close all;
warning off;
addpath(genpath('./'));

%DBDIR = 'D:/data/';
DBDIR = './dataset/';  % every sample is  d * n
i = 1;

 DataName{i} = 'NGs'; i = i + 1;
% DataName{i} = 'HW'; i = i + 1;%
% DataName{i} = 'CiteSeer'; i = i + 1;%
% DataName{i} = 'Reuters'; i = i + 1;
% DataName{i} = 'Animal'; i = i + 1;%
% DataName{i} = 'MNIST_fea'; i = i + 1;
% DataName{i} = 'YouTubeFace20_4Views'; i = i + 1;%63896
% DataName{i} = 'Caltech256'; i = i + 1;
% DataName{i} = 'YouTubeFace50_4Views'; i = i + 1;%126054
dbNum = length(DataName);
for dsi = 1:dbNum
    clear X gt Y;
    dataName = DataName{dsi};
    dbfilename = sprintf('%s%s.mat',DBDIR,dataName);
    load(dbfilename);
    
    Y = gt;
    k = length(unique(Y));
    V = length(X);
    n = length(Y);
    for v = 1:V
        X{v} = X{v}';
        X{v}=mapstd (X{v},0 ,1);
    end
    delta_list = [0.1, 0.3];% setting it to 0.1 or 0.3 can obtain good performance
    %%%%%%%%%for paramers searching
    m_list = [1 2 4 5] * k;
    lambda_list = [0.001,0.01, 0.1, 1, 10];
    mu0_list = [1, 10,100,1000,10000];
    %%%%%%%%
    if contains(dataName, 'NGs')
        m_list = [2] * k;
        mu0_list = [100];
        delta_list = [0.3];
        lambda_list = [1];
    end
    
    for i_m = 1:length(m_list)
        m = m_list(i_m);
        for i_lambda = 1:length(lambda_list)
            for i_mu0 = 1:length(mu0_list)
                for i_delta = 1:length(delta_list)
                    lambda = lambda_list(i_lambda);
                    mu0 = mu0_list(i_mu0);
                    delta = delta_list(i_delta);
                    tic;
                    params.mu0 = mu0;
                    params.lambda = lambda;
                    params.beta = 1;
                    params.delta = delta;
                    params.maxIter = 30;
                    params.tol = 1e-4;
                    params.k = k;
                    params.db = dataName;
                    params.saveObj = false;
                    
                    params.mu = 1e-5;
                    params.rho = 1e-4;
                    params.m = m;
                    params.verbose = false;
                    params.max_mu = 10e10;
                    params.max_rho = 10e10;
                    params.cont_factor = 2;
                    params.hard_permutation = false;
                    params.bTTR = true;
                    
                    [ind, iter] = ATTMVC(X, m, params);
                    
                    y_pred = spectralClustering(ind, k);
                    res = Clustering8Measure(gt, y_pred);
                    
                    str = sprintf('db:%s n:%d iter:%d  V=%d,k=%d, m=%dk,  lambda=%.4f,mu0=%.5f, delta:%.5f| ACC:%.4f nmi:%.4f AR:%.4f Fscore:%.4f Purity:%.4f Precision:%.4f Recall:%.4f | run:%.2f \n',...
                        dataName, n, iter,  V, k, m/k, lambda, mu0, delta, res(1), res(2), res(3), res(4), res(5), res(6), res(7), toc);
                    fprintf('%s', str);
                    clear ind;
                end
            end
        end
    end
    clear X Y k;
end

