function Lctt=p2108_terrestrial_clutter_loss_vector(app, FreqMHz, dist_km, p)
%P2108_Terrestrial_Clutter_Loss  ITU-R P.2108-1, Annex 1, §3.2 (single-ended)
%
%   Lctt = P2108_Terrestrial_Clutter_Loss(app, FreqMHz, d_km, p)
%
%   Vectorization:
%     - dist_km can be any size (N-D array).
%     - p can be a vector/array of percentiles.
%     - Output size is [size(d_km)  numel(p)].
%
%   Notes:
%     - Valid frequency range: 0.5–67 GHz => 500–67000 MHz
%     - Clamp d to 2 km (maximum clutter loss)
%     - For d < 0.25 km, return 0 dB

arguments
    app
    FreqMHz (1,1) double {mustBeInRange(FreqMHz,500,67000)}
    dist_km (:,:) double {mustBeNonnegative}
    p (:,:) double {mustBeGreaterThan(p,0), mustBeLessThan(p,100)} = 50
end

% app is kept for App Designer signature compatibility
f_GHz = FreqMHz/1000;

% Clamp distance at 2 km
dist_km = min(dist_km, 2);

% Short paths: model not applicable
isTooShort = dist_km < 0.25;

% Use a safe effective distance (avoid log10(0))
d_eff = max(dist_km, 0.25);

% ---- Eq (4a) folded into Tl = 10^(-0.2*Ll_dB) ----
X  = 10.^(-5*log10(f_GHz) - 12.5) + 10^(-16.5);
T_l = X.^0.4;

% ---- Eq (5a) folded into Ts = 10^(-0.2*Ls_dB) ----
Ls_dB = 32.98 + 23.9*log10(d_eff) + 3*log10(f_GHz);
T_s   = 10.^(-0.2 * Ls_dB);

% ---- Eq (3b) ----
sigma_l = 4;
sigma_s = 6;
sigma_cb = sqrt((sigma_l^2*T_l + sigma_s^2*T_s) ./ (T_l + T_s));

% ---- Eq (3a) ----
u  = p(:).'/100;                   % force row: 1×M
iQ = sqrt(2) * erfcinv(2*u);       % 1×M, elementwise; erfcinv supports arrays :contentReference[oaicite:1]{index=1}

base = -5*log10(T_l + T_s);        % same size as d_km

% Expand to [size(d_km) M] by adding a trailing singleton dim
base     = reshape(base,     [size(base) 1]);
sigma_cb = reshape(sigma_cb, [size(sigma_cb) 1]);

Lctt = base - sigma_cb .* iQ;      % implicit expansion rules :contentReference[oaicite:2]{index=2}

% Apply short-path rule explicitly (don’t mask other Inf/NaN causes)
if any(isTooShort(:))
    mask = reshape(isTooShort, [size(isTooShort) 1]);  % expand mask
    Lctt(mask) = 0;
end
end