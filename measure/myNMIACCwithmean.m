function [resmean, resmax resstd]= myNMIACCwithmean(U,Y,numclass)

stream = RandStream.getGlobalStream;
reset(stream);
U_normalized = U ./ repmat(sqrt(sum(U.^2, 2)), 1,size(U,2));
maxIter = 20;

for iter = 1:maxIter
    indx = litekmeans(U_normalized,numclass,'MaxIter',100, 'Replicates',5);
    indx = indx(:);
    result(iter,:) = Clustering8Measure(Y,indx);
end
resmean = mean(result,1);
resmax = max(result,[],1);
resstd = std(result,1);
% 
% maxIter = 20;
% for iter = 1:maxIter
%     indx = litekmeans(U_normalized,numclass,'MaxIter',100, 'Replicates',10);
%     indx = indx(:);
%     result(iter,:) = Clustering8Measure(Y,indx);
% end
% resmean2 = mean(result,1);
% resmax2 = max(result,[],1);
% resstd3 = std(result,1);
% tc = 1;