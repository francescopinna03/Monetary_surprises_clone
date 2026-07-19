function summary = Audit_timezone_provenance(archiveCentral, explicitCentral, explicitUtc, tolerance)
%AUDIT_TIMEZONE_PROVENANCE Compare archived, Central and UTC Barchart exports.
%
% Inputs are standardized tables returned by Read_certification_bars. The
% archived export is interpreted as America/Chicago only for this diagnostic.

    if nargin < 4 || isempty(tolerance)
        tolerance = 1e-10;
    end

    centralUtc = compare_exports(explicitCentral, explicitUtc, ...
        "explicit_central_vs_explicit_utc", tolerance);
    archiveCentralMatch = compare_exports(archiveCentral, explicitCentral, ...
        "archive_vs_explicit_central", tolerance);

    summary = [centralUtc; archiveCentralMatch];
    minimumRows = 100;
    pass = all(summary.n_common >= minimumRows) && ...
        all(summary.common_share_smaller_file >= 0.95) && ...
        all(summary.ohlcv_exact_share >= 0.999);
    summary.overall_pass = repmat(pass, height(summary), 1);
end

function row = compare_exports(A, B, label, tolerance)
    [common, ia, ib] = intersect(A.time_utc, B.time_utc);
    XA = [A.Open(ia), A.High(ia), A.Low(ia), A.Latest(ia), A.Volume(ia)];
    XB = [B.Open(ib), B.High(ib), B.Low(ib), B.Latest(ib), B.Volume(ib)];

    scale = max(1, max(abs(XA), abs(XB)));
    fieldMatch = abs(XA - XB) <= tolerance .* scale;
    if isempty(fieldMatch)
        exactShare = NaN;
        maxRelativeError = NaN;
    else
        exactShare = mean(all(fieldMatch, 2));
        maxRelativeError = max(abs(XA - XB) ./ scale, [], 'all');
    end

    row = table();
    row.comparison = string(label);
    row.n_left = height(A);
    row.n_right = height(B);
    row.n_common = numel(common);
    row.common_share_left = numel(common) / max(height(A), 1);
    row.common_share_right = numel(common) / max(height(B), 1);
    row.common_share_smaller_file = numel(common) / ...
        max(min(height(A), height(B)), 1);
    row.ohlcv_exact_share = exactShare;
    row.max_relative_error = maxRelativeError;
end
