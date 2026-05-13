% sw_scat.m

function [betasw,bsw,Uv,Uh,file] = sw_scat(lambda,theta,Tc,S)

% lambda: row vector of wavelengths for each data column
% theta: row vector of angles for each data column
% Tc: scalar temperature (deg C)
% S: scalar salinity (PSU)

%%% Input error checking

narginchk(4,5);
if nargin == 4
    delta = 0.039; % Farinato and Roswell (1976)
end

if size(lambda,1) > size(lambda,2)
    error('Lambda must be a row vector')
end

if size(theta,1) > size(theta,2)
    error('Theta must be a row vector')
end

if ~isscalar(Tc)
    error('Tc must be a scalar')
end

if ~isscalar(S)
    error('S must be a scalar')
end

%%% Physical constants
Na = 6.0221417930e23;   % Avogadro's number
Kbz = 1.3806503e-23;    % Boltzmann constant
Tk = Tc+273.15;         % Absolute tempearture
M0 = 18e-3;             % Molecular weight of water (kg/mol)

%%% Calculations

if isequal(lambda,repmat(lambda(1),1,length(lambda)))
    lambda = lambda(1);
end

if isequal(theta,repmat(theta(1),1,length(theta)))
    theta = theta(1);
end

rad = theta(:) * pi/180; % angle(s) in radian as a column vector

% Refractive index
% nsw: absolute refractive index of seawater
% dnds: partial derivative of seawater refractive index wrt salinity
[nsw, dnds] = RInw(lambda,Tc,S);

% Isothermal compressibility
% Source: Lepple and Millero (1971, Deep-sea Research, pp 10-11)
% Error: +/-0.004e-6 bar^-1
IsoComp = BetaT(Tc,S);

% Density of water and seawater
density_sw = rhou_sw(Tc,S);

% Water activity of seawater
dlnawds = dlnasw_ds(Tc, S);

% Density derivative of refractive index
DFRI = PMH(nsw);

% Volume scattering at 90 deg due to density fluctuation
beta_df = pi*pi/2*((lambda*1e-9).^(-4))*Kbz*Tk*IsoComp.*DFRI.^2*(6+6*delta)/(6-7*delta);
% Volume scattering at 90 deg due to concentration fluctuation
flu_con = S*M0*dnds.^2/density_sw/(-dlnawds)/Na;
beta_cf = 2*pi*pi*((lambda*1e-9).^(-4)).*nsw.^2.*(flu_con)*(6+6*delta)/(6-7*delta);
% Total volume scattering at 90 deg
beta90sw = beta_df+beta_cf;
bsw = 8*pi/3*beta90sw*(2+delta)/(1+delta);
for x = 1:length(lambda)
    betasw(:,x) = beta90sw(x)*(1+((cos(rad)).^2).*(1-delta)/(1+delta));
end

% Polarized scattering functions
Uv90 = beta90sw/(1+delta);
Uv = repmat(Uv90,length(rad),1);
Uh = Uv.*(delta+(1-delta).*(cos(repmat(rad,1,size(Uv,2)))).^2);  

%%%%% NESTED FUNCTIONS %%%%%

function [nsw, dnswds] = RInw(lambda,Tc,S)
    
    % Refractive index of air
    % Source: Ciddor (1996, Applied Optics)
    n_air = 1.0+(5792105.0./(238.0185-1./(lambda/1e3).^2)+167917.0./(57.362-1./(lambda/1e3).^2))/1e8;
    
    % Refractive index of seawater
    % Source: Quan and Fry (1994, Applied Optics)
    n0 = 1.31405;
    n1 = 1.779e-4;
    n2 = -1.05e-6;
    n3 = 1.6e-8;
    n4 = -2.02e-6;
    n5 = 15.868;
    n6 = 0.01155;
    n7 = -0.00423;
    n8 = -4382;
    n9 = 1.1455e6;
    
    nsw = n0+(n1+n2*Tc+n3*Tc^2)*S+n4*Tc^2+(n5+n6*S+n7*Tc)./lambda+n8./lambda.^2+n9./lambda.^3; % pure seawater
    nsw = nsw.*n_air;
    dnswds = (n1+n2*Tc+n3*Tc^2+n6./lambda).*n_air;

end

function IsoComp = BetaT(Tc, S)
    
    % Pure water secant bulk
    % Source; Millero (1980, Deep-sea Research)
    kw = 19652.21+148.4206*Tc-2.327105*Tc.^2+1.360477e-2*Tc.^3-5.155288e-5*Tc.^4;
    Btw_cal = 1./kw;
    
    % Isothermal compressibility
    % Source: Kell sound measurement in pure water
    % isothermal compressibility from Kell sound measurement in pure water
    % Btw = (50.88630+0.717582*Tc+0.7819867e-3*Tc.^2+31.62214e-6*Tc.^3-0.1323594e-6*Tc.^4+0.634575e-9*Tc.^5)./(1+21.65928e-3*Tc)*1e-6;

    % Seawater secant bulk
    a0 = 54.6746-0.603459*Tc+1.09987e-2*Tc.^2-6.167e-5*Tc.^3;
    b0 = 7.944e-2+1.6483e-2*Tc-5.3009e-4*Tc.^2;

    Ks =kw + a0*S + b0*S.^1.5;

    % Calculate seawater isothermal compressibility from secant bulk
    IsoComp = 1./Ks*1e-5; % unit is pa

end

function density_sw = rhou_sw(Tc, S)

    % Density of water and Seawater
    % Source: UNESCO,38,1981
    % Units: kg/m^3
    
    a0 = 8.24493e-1;        b0 = 999.842594;
    a1 = -4.0899e-3;        b1 = 6.793952e-2;
    a2 = 7.6438e-5;         b2 = -9.09529e-3;
    a3 = -8.2467e-7;        b3 = 1.001685e-4;
    a4 = 5.3875e-9;         b4 = -1.120083e-6;
    a5 = -5.72466e-3;       b5 = 6.536332e-9;
    a6 = 1.0227e-4;
    a7 = -1.6546e-6;
    a8 = 4.8314e-4;
    
    % Density of pure water
    density_w = b0+b1*Tc+b2*Tc^2+b3*Tc^3+b4*Tc^4+b5*Tc^5;
    
    % Density of pure seawater
    density_sw = density_w +((a0+a1*Tc+a2*Tc^2+a3*Tc^3+a4*Tc^4)*S+(a5+a6*Tc+a7*Tc^2)*S.^1.5+a8*S.^2);
    
end

function [dlnawds] = dlnasw_ds(Tc,S)
        
        % Water activity of seawater data
        % Source: Millero and Leung (1976, American Journal of Science,276,1035-1077)
        % Method: Table 19 was reproduced using Eqs. 14,22,23,88,107, then
        % fitted to polynomial equation
        % dlnawds: partial derivative of ln of water activity wrt salinity

        % lnaw = (-1.64555e-6-1.34779e-7*Tc+1.85392e-9*Tc.^2-1.40702e-11*Tc.^3)+...
        %     (-5.58651e-4+2.40452e-7*Tc-3.12165e-9*Tc.^2+2.40808e-11*Tc.^3).*S+...
        %     (1.79613e-5-9.9422e-8*Tc+2.08919e-9*Tc.^2-1.39872e-11*Tc.^3).*S.^1.5+...
        %     (-2.31065e-6-1.37674e-9*Tc-1.93316e-11*Tc.^2).*S.^2;
        
        dlnawds = (-5.58651e-4+2.40452e-7*Tc-3.12165e-9*Tc.^2+2.40808e-11*Tc.^3)+...
            1.5*(1.79613e-5-9.9422e-8*Tc+2.08919e-9*Tc.^2-1.39872e-11*Tc.^3).*S.^0.5+...
            2*(-2.31065e-6-1.37674e-9*Tc-1.93316e-11*Tc.^2).*S;
        
    end

function [n_density_derivative] = PMH(n_wat)
        
        % Density derivative of refractive index
        % Source: PMH model
        n_wat2 = n_wat.^2;
        n_density_derivative=(n_wat2-1).*(1+2/3*(n_wat2+2).*(n_wat/3-1/3./n_wat).^2);
        
end

file = mfilename('fullpath');

end