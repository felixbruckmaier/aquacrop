%% Removes all sample points that cannot be used for the EE/ Morris method
% The SAFE EE calculation requires consecutive samples to change only 1
% parameter value within 1 sample point (1 sample set/ "block" in which every
% parameter is adjusted exactly once); every sample discarded by the AAOS
% phenology check will create a "hole" in the respective block: i.e., the
% sample after the discarded one will then have adjusted 2 parameters to the
% new precursor; the Morris method therefore cannot calculate individual EE
% for this block anymore - which is why the entire block must be removed.
function [Rows_ValidEEsamples,N_ValidEEsamples] = AAOS_SAFE_IndicateInvalidSamples(M_new,Rows_rmvPheno)

Rows_ValidEEsamples = nan;
N_ValidEEsamples = 0;

% Create vector with indices for every sample:
idcs_AllSamples(:,1) = 1:size(Rows_rmvPheno,1);
% Derive number of samples:
n_AllSamples = numel(Rows_rmvPheno);
% Derive size of 1 sample point/ block - see SAFE help for EE/ Morris method: 
size_Blocks = M_new + 1;
% Derive number of blocks:
n_AllBlocks = n_AllSamples / size_Blocks;

%% Create 2 cell array, each with 1 block per field:
% a) PhenoCheck blocks contain phenology check results for every sample
% (vectors with 0 or 1 values):
AllBlocks_PhenoCheck = mat2cell(Rows_rmvPheno,diff([0 : size_Blocks : n_AllSamples-1, n_AllSamples]));
% a) Sample blocks contain vectors with the index of every sample within
% sample matrix:
AllBlocks = mat2cell(idcs_AllSamples,diff([0 : size_Blocks : n_AllSamples-1, n_AllSamples]));

%% Evaluate every block for containing (phenologically) invalid samples:
% Set up output array:
vec_PhenoCheckSum = zeros(n_AllBlocks,1);
% For every block, sum up phenology check results of all samples:
for idx1 = 1:n_AllBlocks
    vec_PhenoCheckSum(idx1,1) = sum(AllBlocks_PhenoCheck{idx1,:});
end

%% Derive (phenologically) valid blocks:
% Create vector with indices for every block:
Idcs_Blocks = 1:size(vec_PhenoCheckSum,1);
% Create vector that separates valid from invalid blocks:
Idcs_ValidBlocks = Idcs_Blocks(vec_PhenoCheckSum == 0);
% Derive valid blocks (that contain sample indices, see above):
ValidBlocks = AllBlocks(Idcs_ValidBlocks);
% Derive number of valid blocks:
n_ValidBlocks = size(ValidBlocks,1);

%% Convert block cells to output vector:
% Set up matrix with 1 column per block:
% ValidBlocks_mat = zeros(size_Blocks,n_ValidBlocks);
% Convert cell array to matrix:
if n_ValidBlocks > 0
    for idx2 = 1:n_ValidBlocks
        ValidBlocks_mat(:,idx2) = ValidBlocks{idx2,:};
    end
    % Derive number of valid samples:
    N_ValidEEsamples = size(Idcs_ValidBlocks,2) * size_Blocks;
    % Convert matrix to output vector with equal rows as sample matrix:
    Rows_ValidEEsamples = reshape(ValidBlocks_mat,N_ValidEEsamples,1);
end