function [cpg_slope,cpg_slope_header] = func_cpg_slope(cpg,cpg_header,wl)
% Calculates the slope of cpg using a powerfit.
error = ones(1,size(cpg,2)-2);

% midwl = abs(round(1-length(wl)./2));
% midc = abs(round(1-length(cpg)./2));
% error = ones(1,size(wl,1));
% amp = cpg(midc,midwl);
% counter = 1;
% while isnan(amp)
%     amp= cpg(midc+counter,midwl+counter);
%     counter = counter+1;
% end
amp = 1;
slope = 1;
options  =  optimset('Display','off','MaxFunEvals',1e4,'MaxIter',1e4,'TolX',1e-6,'TolFun',1e-6);
cpg_slope = zeros(size(cpg,1),2);
for xx = 1:size(cpg,1)
    if ~isnan(cpg(xx,1))
        cpg_slope(xx,:) = -fminsearch(@powerfit,[amp,slope], options, error, cpg(xx,3:end), wl./532);
    elseif isnan(cpg(xx,1))
        cpg_slope(xx,:) = NaN;
    end
end
cpg_slope_header = cpg_header(1:2,1:2);
cpg_slope_header{3,1} = 'cpg_slope_a';
cpg_slope_header{4,1} = 'cpg_slope_b';
cpg_slope_header{3,2} = '';
cpg_slope_header{4,2} = '';
end