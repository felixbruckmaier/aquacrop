N = 10;
M = 2;

xmin = [  0 0 0 0   0.1 ];                                                     
xmax = [400 2 1 0.1 1   ];                                                     
% Parameter distributions:                                                                                                           
DistrPar = cell(M,1);                                                          
for i=1:M; DistrPar{i} = [ xmin(i) xmax(i) ] ; end     

X = lhcube(N,M);

for i=1:M
    pars = DistrPar{i};
X(:,i) = feval(['Uniform'],X(:,i),pars);
end