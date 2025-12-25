function labels = spectralClustering(Y, k)
N = size(Y, 1);
[F,~,~] = mySVD(Y, k);
for i = 1:N
	F(i,:) = F(i,:) ./ norm(F(i,:)+eps);
end
rand('twister',5189);

labels=litekmeans(F, k, 'MaxIter', 100,'Replicates',10);
end