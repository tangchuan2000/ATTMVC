

clear all;
close all;
warning off;
addpath(genpath('./'));
DBDIR = 'D:/data/';
%DBDIR = './dataset/'; 2
i = 1;


%DataName{i} = 'YouTubeFace10_4Views'; i = i + 1;
%   DataName{i} = 'COIL20'; i = i + 1;
% DataName{i} = 'BBC'; i = i + 1;
% DataName{i} = 'BBCSport'; i = i + 1;

% %
%  DataName{i} = 'LGG'; i = i + 1;
% DataName{i} = 'Wiki'; i = i + 1;
%  DataName{i} = 'Caltech101-20'; i = i + 1;
%   DataName{i} = 'Caltech101-7'; i = i + 1;
%   DataName{i} = 'WikipediaArticles'; i = i + 1;
%   DataName{i} = 'scene-15'; i = i + 1;
% DataName{i} = 'UCI_Digits'; i = i + 1;
%  DataName{i} = 'ALOI_100'; i = i + 1;
%    DataName{i} = 'Cifar10_4views'; i = i + 1;
% % DataName{i} = 'NUSWIDEOBJ'; i = i + 1;
% DataName{i} = 'AwA'; i = i + 1; %Caltech101-6view

% DataName{i} = 'YouTubeFace10_4Views'; i = i + 1; %38654


DataName{i} = 'NGs'; i = i + 1;
DataName{i} = 'HW'; i = i + 1;

DataName{i} = 'CiteSeer'; i = i + 1;

DataName{i} = 'Reuters'; i = i + 1;
DataName{i} = 'Animal'; i = i + 1;

DataName{i} = 'MNIST_fea'; i = i + 1;
DataName{i} = 'YouTubeFace20_4Views'; i = i + 1;%63896
DataName{i} = 'Caltech256'; i = i + 1;
DataName{i} = 'YouTubeFace50_4Views'; i = i + 1;%126054
dbNum = length(DataName);
allfilename = './result/all.txt';
addlog(allfilename, '', 1);

anchorallfilename = './result/all-anchor.txt';
addlog(anchorallfilename, '', 1);
for dsi = 1:dbNum

    clear X gt Y;
    dataName = DataName{dsi};
    filename = sprintf('./result/%s.txt',dataName);
    filenamPara = sprintf('./result/%s_para.txt',dataName);
    addlog(filename, '--------------------------------------------------------------------------------', 1);
    dbfilename = sprintf('%s%s.mat',DBDIR,dataName);
    load(dbfilename);

    Y = gt;
    k = length(unique(Y));
    V = length(X);
    n = length(Y);
    for v = 1:V
        X{v} = X{v}';
        X{v}=mapstd (X{v},0 ,1);
        %         X{v} = X{v}';
    end

    %     for v=1:V
    %         [X{v}]=NormalizeData(X{v});
    %         X{v} = X{v}';
    %     end
    beta_list = [0.1 1 10 100 1000, 10000];

    lambda_list = [0.0001, 0.001 0.01 0.1];

    m_list = [1 2 4 5] * k;
    m_list = [1 2 5] * k;
    %     mu0_list = [0.0001, 0.001 0.01 0.1 1 10 100 1000];
    %     delta_list = [0.0001, 0.001 0.01 0.1 1];
    %     rng(2025,'twister');

    mu0_list = [0.0001, 0.001 0.01 1];
    delta_list = [0.0001, 0.001 0.01 0.1 1];


    mu0_list = [1, 10,100,1000,10000];
    delta_list = [0.1, 1, 10];
    delta_list = [0.1, 0.3, 0.8 1];
    lambda_list = [0.01, 0.1, 1, 10];



    %%%%%%%%%for paramer sensetive
%     m_list = [1 2 4 5 10] * k;
%     lambda_list = [0.001,0.01, 0.1, 1, 10];
%     mu0_list = [1, 10,100,1000,10000];
%     delta_list = [0.1, 0.3, 0.5, 0.8 1];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % db:NGs n:2000 iter:27 t:113(240) V=6,k=10, m=2k, hard:0 lambda=0.1000,mu0=100.00000, delta:1.00000 | 0.9960	 0.9861	 0.9900	 0.9920	 0.9960	 0.9919	 0.9920		 |  run:1.34 | 025-12-09 12:47:55
    % db:NGs n:500 iter:22 t:175(252) V=3,k=5, m=5k, hard:0  lambda=0.1000,mu0=0.10000, delta:0.80000|  1.0000	 1.0000	 1.0000	 1.0000	 1.0000	 1.0000	 1.0000	 |  run:1.41  2025-11-13 16:24:02
    if contains(dataName, 'NGs')
        m_list = [5] * k;
        mu0_list = [0.1];
        delta_list = [0.8];
        lambda_list = [0.1];
        % db:Reuters n:1200 iter:30 t:98(180) V=5,k=6, m=2k, hard:0 bCetr:1 lambda=0.1000,mu0=10000.00000, delta:0.30000 | 0.9875	 0.9609	 0.9702	 0.9752	 0.9875	 0.9751	 0.9752	 |  run:4.36  |  2025-12-05 17:07:18
    elseif contains(dataName, 'Reuters')
        m_list = [2] * k;
        mu0_list = [10000];
        delta_list = [0.3];
        lambda_list = [0.1];
        %db:UCI_Digits n:2000 iter:27 t:110(252) V=6,k=10, m=2k, hard:0  lambda=0.1000,mu0=10000.00000, delta:0.30000|  0.9990	 0.9973	 0.9978	 0.9980	 0.9990	 0.9980	 0.9980	 |  run:2.15  2025-11-13 17:36:48
        %db:HW n:2000 iter:30 t:466(625) V=6,k=10, m=5k,  lambda=1.0000,mu0=1000.00000, delta:0.10000 -- 1.0000	 1.0000	 1.0000	 1.0000	 1.0000	 1.0000	 1.0000	 | run:1.99 | 2025-12-10 23:28:10  rnd: 5189 
    elseif contains(dataName, 'UCI_Digits') || contains(dataName, 'HW')
        m_list = [5] * k;
        mu0_list = [1000];
        delta_list = [0.1];
        lambda_list = [1];
        % db:CiteSeer n:3312 iter:31 t:178(180) V=2,k=6, m=5k, hard:0 lambda=10.0000,mu0=10000.00000, delta:0.30000 | 0.5857	 0.3201	 0.3122	 0.4324	 0.6048	 0.4418	 0.4234	 |  run:9.00 |  2025-12-05 14:59:49
    elseif contains(dataName, 'CiteSeer')
        m_list = [5] * k;
        mu0_list = [10000];
        delta_list = [0.3];
        lambda_list = [10];
        %db:Animal n:11673 iter:24 t:122(180) V=4,k=20, m=5k, hard:0  lambda=0.0100,mu0=1.00000, delta:0.30000| 0.9495	 0.9559	 0.9412	 0.9446	 0.9686	 0.9661	 0.9240	 |  run:33.77  |  2025-12-05 18:24:57
    elseif contains(dataName, 'Animal')
        m_list = [5] * k;
        mu0_list = [1];
        delta_list = [0.3];
        lambda_list = [0.01];
        %db:Caltech256 n:30607 iter:27 t:74(180) V=4,k=257, m=2k, hard:0 lambda=0.0100,mu0=1000.00000, delta:0.30000 | 0.7469	 0.9297	 0.6603	 0.6620	 0.8370	 0.7728	 0.5790	 |  run:183.07 |  2025-12-05 21:56:22
    elseif contains(dataName, 'Caltech256')
        m_list = [2] * k;
        mu0_list = [1000];
        delta_list = [0.3];
        lambda_list = [0.01];
        %db:MNIST_fea n:60000 iter:33 t:117(180) V=3,k=10, m=2k, hard:0  lambda=10.0000,mu0=10000.00000, delta:0.10000| 0.9917	 0.9736	 0.9817	 0.9835	 0.9917	 0.9834	 0.9836	 |  run:54.99 |  2025-11-13 23:55:31
    elseif contains(dataName, 'MNIST_fea')
        m_list = [2] * k;
        mu0_list = [10000];
        delta_list = [0.1];
        lambda_list = [10];
        %db:YouTubeFace20_4Views n:63896 iter:22 t:61(180) V=4,k=20, m=2k, hard:0  lambda=0.0100,mu0=1.00000, delta:0.10000| 0.8526	 0.8813	 0.7702	 0.7830	 0.8560	 0.7818	 0.7842	 |  run:75.01 2025-11-14 15:10:11
    elseif contains(dataName, 'YouTubeFace20_4Views')
        m_list = [2] * k;
        mu0_list = [1];
        delta_list = [0.1];
        lambda_list = [0.01];
        % db:YouTubeFace50_4Views n:126054 iter:25 t:129(180) V=4,k=50, m=5k,  lambda=0.0100,mu0=100.00000, delta:0.10000| 0.8394	 0.9402	 0.8284	 0.8323	 0.8938	 0.8289	 0.8357	 |  run:418.79  |  2025-11-15 02:54:48
    elseif contains(dataName, 'YouTubeFace50_4Views')
        m_list = [5] * k;
        mu0_list = [100];
        delta_list = [0.1];
        lambda_list = [0.01];
    end
    alltimes = length(m_list) * length(lambda_list) * length(mu0_list) * length(delta_list);
    times = 0;
    start = 1;
    maxAcc = 0;
    maxStr = '';
%     str2 = sprintf('m\t lambda\t mu0\t delta\t ACC\t nmi\t AR\t Fscore\t Purity\t Precision\t Recall\t toc\t time\n');        
%     addlog(filenamPara, str2, 1);

    for i_m = 1:length(m_list)
        AnchormaxAcc = 0;
        AnchormaxStr = '';
        m = m_list(i_m);
        %         tic;
        %         anchors = cell(V, 1);
        %         for v = 1:V
        %             anchors{v} = kmeans_centers(X{v}, m, 0);
        %         end
        %         str1 = sprintf('construct anchors cost: %.4f sec\n', toc);
        %fprintf('%s %s', dataName, str1);
        for i_lambda = 1:length(lambda_list)
            for i_mu0 = 1:length(mu0_list)
                for i_delta = 1:length(delta_list)
                    times = times+1;
                    if (times < start)
                        continue;
                    end
                    
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
                    params.bCetr = true;

%                     if contains(dataName, 'MNIST_fea') && params.hard_permutation && lambda == 1 && mu0 == 100 && delta == 1
%                         continue; %spectralClustering 对于此运算，数组的大小不兼容。
%                     end

                    if params.hard_permutation
                        allfilename = './result/all-hard.txt';
                        filename = sprintf('./result/%s-hard.txt',dataName);
                    end
                    % (X ,cls_num ,anchor ,alpha ,gamma ,delta, mu0 )
                    %[ind, currentFunctionName, iter] = aa_etr_c_noasr_row(X, m, params);
                    [ind, currentFunctionName, iter, rho] = aa_etr_c_noasr_row(X, m, params);
                    %                     [y_pred, currentFunctionName, iter] = aa_etr_T(X, m, params);

                    %                    [ind, currentFunctionName, iter] = by_ASR_TER(X, k, m, lambda, 0, delta, mu0 );
                    tocs = toc;
                    rndlist = [5189, 1587, 1232]; %158, 
                    rndlist = [5189];
                    for rn = 1:length(rndlist)
                        krnd = rndlist(rn);
                        %                     krnd = 158;
                        %                     krnd = 1587;
                        y_pred = spectralClustering(ind, k, krnd);
                        res = Clustering8Measure(gt, y_pred);
                        thr = params.beta / ((rho+2*mu0) * delta);
                        str = sprintf('db:%s n:%d iter:%d t:%d(%d) V=%d,k=%d, m=%dk, hard:%d bCetr:%d thr->delta+0.5*thr(%.5f-%.5f) lambda=%.4f,mu0=%.5f, delta:%.5f| ACC:%.4f nmi:%.4f AR:%.4f Fscore:%.4f Purity:%.4f Precision:%.4f Recall:%.4f --- %.4f\t %.4f\t %.4f\t %.4f\t %.4f\t %.4f\t %.4f\t | run:%.2f | %s | %s| rnd: %d \n',...
                            dataName, n, iter, times, alltimes, V, k, m/k, params.hard_permutation,params.bCetr, thr, delta + 0.5 * thr, lambda, mu0, delta, res(1), res(2), res(3), res(4), res(5), res(6), res(7), res(1), res(2), res(3), res(4), res(5), res(6), res(7),...
                            tocs,  GetTimeStrForLog(), currentFunctionName,krnd );


                        fprintf('%s', str);

                        addlog(filename, str, 1);

%                         str2 = sprintf('m=%d\t %.4f\t %.5f\t %.5f\t %.4f\t %.4f\t %.4f\t %.4f\t %.4f\t %.4f\t %.4f\t %.2f\t  %s\n',...
%                             m, lambda, mu0, delta, res(1), res(2), res(3), res(4), res(5), res(6), res(7), tocs,  GetTimeStrForLog());
%                         addlog(filenamPara, str2, 1);
                        if (maxAcc < res(1))
                            maxAcc = res(1);
                            maxStr = str;
                        end
                        if (AnchormaxAcc < res(1))
                            AnchormaxAcc = res(1);
                            AnchormaxStr = str;
                        end
                    end
                    clear ind;
                end
            end
        end
        addlog(anchorallfilename, AnchormaxStr, 1);
    end
    clear X Y k;
    addlog(allfilename, '', 1);
    addlog(allfilename, maxStr, 1);
end

