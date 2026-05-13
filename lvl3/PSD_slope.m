function [PSD_slope_volz,PSD_slope_BTH,PSD_slope_header] = PSD_slope(cp_slope,cpg_header)
     % Calculates the slope of the particle size
                            % distribution based on the slope of cp.
                            PSD_slope_volz = cp_slope + 3;
                            PSD_slope_BTH = cp_slope + 3 - (0.5*exp(-6*cp_slope));

                            PSD_slope_header = cpg_header(1:2,1:2);
                            PSD_slope_header{3,1} = '';
                            PSD_slope_header{4,1} = '';
                            PSD_slope_header{3,2} = '';
                            PSD_slope_header{4,2} = '';
end