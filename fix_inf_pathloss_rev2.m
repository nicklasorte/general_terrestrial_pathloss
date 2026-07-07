function X = fix_inf_pathloss_rev2(app, X, opts)
%fixInfValues  Replace +Inf and -Inf in a numeric array.
%
%   X = fixInfValues(app, X) replaces:
%       -Inf -> 1
%       +Inf -> 999
%
%   Name-value options:
%     "NegInfValue" - value to use for -Inf (default 1)
%     "PosInfValue" - value to use for +Inf (default 999)
%
%   Notes:
%   - app is accepted for drop-in compatibility with your app style,
%     but not used here (keep it in case you want app-based logging later).

arguments
    app %#ok<INUSA>
    X {mustBeNumeric}
    opts.NegInfValue (1,1) double = 1
    opts.PosInfValue (1,1) double = 999
end

negMask = isinf(X) & (X < 0);
posMask = isinf(X) & (X > 0);

if any(negMask(:))
    X(negMask) = opts.NegInfValue;
end
if any(posMask(:))
    X(posMask) = opts.PosInfValue;
end
end