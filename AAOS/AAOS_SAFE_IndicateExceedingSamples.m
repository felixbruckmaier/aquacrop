function Rows_NormedValidEE_samples = ...
    AAOS_SAFE_IndicateExceedingSamples(r_calc, r_target, M_new)

r_ids = randi(r_calc,1,r_target);
rows_start = (r_ids - 1)*(M_new+1) + 1;
rows_end = rows_start + M_new;
rows = zeros(M_new + 1, r_target);
for i = 1:r_target
    rows(:,i) = rows_start(i) : rows_end(i);
end
Rows_target = reshape(rows, (M_new+1)*r_target, 1);

Rows_Calc = [1: (M_new + 1) * r_calc];
Rows_NormedValidEE_samples = Rows_Calc(Rows_target)';
