function Lctt = P2108_Terrestrial_Clutter_Loss(app, FreqMHz, d_km, p)
%P2108_Terrestrial_Clutter_Loss  Rec. ITU-R P.2108-1, Annex 1, §3.2
%   Vectorized over distance and p. If d_km is N×1 and p is M×1 -> Lctt is N×M.

arguments
    app
    FreqMHz (1,1) double {mustBeInRange(FreqMHz,500,67000)}
    d_km (:,:) double {mustBeNonnegative}
    p (:,:) double {mustBeGreaterThan(p,0), mustBeLessThan(p,100)}
end
%tic;
f_GHz = FreqMHz/1000;

% Eq. (6): cap at 2 km
d_km = min(d_km, 2);

% Not applicable for d < 0.25 km -> 0 dB
isTooShort = d_km < 0.25;
d_eff = d_km;
d_eff(isTooShort) = 0;

% Eq. (4a) -> Tl = 10^(-0.2*Ll_dB)
X  = 10.^(-5*log10(f_GHz) - 12.5) + 10^(-16.5);
T_l = X.^0.4;

% Eq. (5a) -> Ts = 10^(-0.2*Ls_dB)
Ls_dB = 32.98 + 23.9*log10(d_eff) + 3*log10(f_GHz);
T_s   = 10.^(-0.2 * Ls_dB);

% Eq. (3b)
sigma_l = 4;
sigma_s = 6;
sigma_cb = sqrt((sigma_l^2*T_l + sigma_s^2*T_s) ./ (T_l + T_s));

% Eq. (3a): inverse Q (toolbox-free)
u  = p/100;
iQ = sqrt(2) * erfcinv(2*u);

% --- Key fix: make p dimension explicit for implicit expansion ---
iQ = reshape(iQ, 1, []);          % 1×M (row)
base = -5*log10(T_l + T_s);       % same size as d_km (e.g., N×1)

Lctt = base - sigma_cb .* iQ;     % (N×1) .* (1×M) -> N×M

% Fix short paths
Lctt(~isfinite(Lctt)) = 0;
%toc;%%%%Elapsed time is 0.001749 seconds.
end


% function Lctt = P2108_Terrestrial_Clutter_Loss(app, FreqMHz, d_km, p)
% %P2108_Terrestrial_Clutter_Loss  Rec. ITU-R P.2108-1, Annex 1, §3.2
% %
% %   Lctt = P2108_Terrestrial_Clutter_Loss(app, FreqMHz, d_km, p)
% %
% %   Inputs
% %     app      : App Designer handle (unused internally)
% %     FreqMHz  : frequency in MHz (500–67000 MHz per Rec.)
% %     d_km     : path length in km
% %     p        : percentage of locations (0<p<100)
% %
% %   Output
% %     Lctt     : clutter loss not exceeded for p% of locations [dB]
% %
% %   Notes:
% %     - Model valid for 0.5–67 GHz
% %     - Maximum clutter loss occurs at d = 2 km
% %     - Not applicable for d < 0.25 km (returned as 0 dB)
% 
% arguments
%     app
%     FreqMHz (1,1) double {mustBeInRange(FreqMHz,500,67000)}
%     d_km (:,:) double {mustBeNonnegative}
%     p (1,1) double {mustBeGreaterThan(p,0), mustBeLessThan(p,100)} = 50
% end
% 
% % Convert to GHz (model defined in GHz)
% f_GHz = FreqMHz/1000;
% 
% % Enforce Eq. (6): cap at 2 km
% d_km = min(d_km, 2);
% 
% % Identify paths shorter than 0.25 km
% isTooShort = d_km < 0.25;
% d_eff = d_km;
% d_eff(isTooShort) = 0;   % log10(0) → -Inf, fixed later
% 
% % ---- Equation (4a) expressed as 10^(-0.2*Ll_dB) ----
% X  = 10.^(-5*log10(f_GHz) - 12.5) + 10^(-16.5);
% T_l = X.^0.4;
% 
% % ---- Equation (5a) ----
% Ls_dB = 32.98 + 23.9*log10(d_eff) + 3*log10(f_GHz);
% T_s   = 10.^(-0.2 * Ls_dB);
% 
% % ---- Equation (3b) ----
% sigma_l = 4;
% sigma_s = 6;
% sigma_cb = sqrt((sigma_l^2*T_l + sigma_s^2*T_s) ./ (T_l + T_s));
% 
% % ---- Equation (3a) ----
% u  = p/100;
% iQ = sqrt(2) * erfcinv(2*u);   % toolbox-free inverse Q-function
% 
% Lctt = -5*log10(T_l + T_s) - sigma_cb .* iQ;
% 
% % Paths < 0.25 km → 0 dB
% Lctt(~isfinite(Lctt)) = 0;
% 
% end









% function Lcct = P2108_Terrestrial_Clutter_Loss(app, FreqMHz, dist_km, p)
% % clutter loss (single ended) via section 3.2 of ITU-R P.2108-1
% Frequency_GHz=FreqMHz/1000;
% 
% 
% % arguments
% %     Frequency_GHz double {mustBeInRange(Frequency_GHz, 0.5, 67)}
% %     Distance double {mustBePositive}
% %     p double {mustBeInRange(p, 0, 100, "exclusive")} = 50;
% % end
% % validateScalarExpandable(Frequency_GHz, Distance, p);
% 
% % clutter loss at maximum value when Distance = 2km. To limit calculation
% % to this maximum, Distance can be limited to 2km, as clutter loss
% % monotonically increases with distance
% dist_km(dist_km > 2) = 2;
% 
% % clutter loss calculations inapplicable for paths less than 0.25km. Such
% % paths can be identified at the output by setting distance to 0km and
% % letting -Inf value propagate through calculation and correcting loss at
% % output
% dist_km(dist_km < 0.25) = 0;
% 
% % 4a and 4b are only referenced in later equations as 10^(-0.2*x), so that
% % is included in the definitions of Ll/Ls here
% 
% % 4a
% Ll = 10.^(0.4*log10(10.^(-5*log10(Frequency_GHz) -12.5) + 10^-16.5));
% % 5a
% Ls = 10.^(-0.2 * ...
%     (32.98 + 23.9 * log10(dist_km) + 3*log10(Frequency_GHz)));
% % 3b
% sigma_cb = sqrt((16 * Ll + 36 * Ls)./(Ll + Ls));
% % 3a
% try
%     iQ = -norminv(p*1e-2);
% catch
%     iQ = sqrt(2)*erfcinv(2*p*1e-2);
% end
% 
% Lcct = -5*log10(Ll + Ls) - sigma_cb .* iQ;
% 
% % corrects Lcct for Distance < 0.25 to 0 dB
% % Lcct(~(isfinite(Lcct) & isreal(Lcct))) = 0;
% Lcct(~isfinite(Lcct)) = 0;
% end