%% CERTIFICATION: BARCHART TIME ZONE AND BAR-LABEL SEMANTICS.
%
% This diagnostic is deliberately outcome-free. It compares an archived raw
% export with explicit America/Chicago and UTC re-exports, then reconstructs
% five-minute OHLCV bars from one-minute data under interval-start and
% interval-end timestamp conventions. No ECB coefficient is estimated.
%
% Required input manifest:
%   Raw/Certification/window_semantics_inputs.csv
%
% Copy config/window_semantics_inputs_template.csv into that location and
% replace every placeholder path before running this script.

projectRoot = Get_project_root();
Require_time_alignment_manifest(projectRoot);

inputManifestFile = fullfile(projectRoot, 'Raw', 'Certification', ...
    'window_semantics_inputs.csv');
diagnosticsDir = fullfile(projectRoot, 'Output', 'diagnostics');
manifestDir = fullfile(projectRoot, 'Output', 'manifests');
if exist(diagnosticsDir, 'dir') ~= 7; mkdir(diagnosticsDir); end
if exist(manifestDir, 'dir') ~= 7; mkdir(manifestDir); end

if exist(inputManifestFile, 'file') ~= 2
    error(['WINDOW_SEMANTICS_INPUTS_MISSING: copy ' ...
        'config/window_semantics_inputs_template.csv to ' ...
        'Raw/Certification/window_semantics_inputs.csv and replace the paths.']);
end

I = readtable(inputManifestFile, 'TextType', 'string', ...
    'VariableNamingRule', 'preserve');
requiredColumns = ["role", "relative_path", "declared_time_zone", "bar_minutes"];
missing = requiredColumns(~ismember(requiredColumns, string(I.Properties.VariableNames)));
if ~isempty(missing)
    error('WINDOW_SEMANTICS_INPUT_MANIFEST_INVALID: missing %s.', strjoin(missing, ', '));
end

I.role = lower(strtrim(string(I.role)));
I.relative_path = strtrim(string(I.relative_path));
I.declared_time_zone = strtrim(string(I.declared_time_zone));
if ~isnumeric(I.bar_minutes)
    I.bar_minutes = str2double(I.bar_minutes);
end

requiredRoles = ["archive_5m", "central_reexport_5m", "utc_reexport_5m", ...
    "one_minute", "five_minute"];
for role = requiredRoles
    if sum(I.role == role) ~= 1
        error('WINDOW_SEMANTICS_ROLE_INVALID: role %s must appear exactly once.', role);
    end
end

expectedZones = ["America/Chicago", "America/Chicago", "UTC", ...
    "America/Chicago", "America/Chicago"];
expectedMinutes = [5, 5, 5, 1, 5];
for r = 1:numel(requiredRoles)
    row = I.role == requiredRoles(r);
    if I.declared_time_zone(row) ~= expectedZones(r) || ...
            I.bar_minutes(row) ~= expectedMinutes(r)
        error(['WINDOW_SEMANTICS_ROLE_METADATA: role %s must use zone %s ' ...
            'and %d-minute bars.'], requiredRoles(r), expectedZones(r), ...
            expectedMinutes(r));
    end
end

resolvedPaths = strings(height(I), 1);
inputHashes = strings(height(I), 1);
inputRows = nan(height(I), 1);
bars = cell(height(I), 1);

for i = 1:height(I)
    resolvedPaths(i) = resolve_path(projectRoot, I.relative_path(i));
    bars{i} = Read_certification_bars(resolvedPaths(i), I.declared_time_zone(i));
    inputHashes(i) = File_sha256(resolvedPaths(i));
    inputRows(i) = height(bars{i});
end

archive = bars{find(I.role == "archive_5m", 1)};
central = bars{find(I.role == "central_reexport_5m", 1)};
utc = bars{find(I.role == "utc_reexport_5m", 1)};
oneMinute = bars{find(I.role == "one_minute", 1)};
fiveMinute = bars{find(I.role == "five_minute", 1)};

timeAudit = Audit_timezone_provenance(archive, central, utc, 1e-10);
[barRows, barSummary] = Audit_bar_label_convention(oneMinute, fiveMinute, 1e-10);

timezonePass = all(timeAudit.overall_pass);
barPass = all(barSummary.overall_pass);
if barPass
    barSemantics = barSummary.decision(1);
else
    barSemantics = "UNRESOLVED";
end

status = "failed";
if timezonePass && barPass
    status = "certified";
end

inputAudit = I;
inputAudit.resolved_path = resolvedPaths;
inputAudit.sha256 = inputHashes;
inputAudit.n_valid_rows = inputRows;

writetable(timeAudit, fullfile(diagnosticsDir, ...
    'window_semantics_timezone_audit.csv'));
writetable(format_dates(barRows), fullfile(diagnosticsDir, ...
    'window_semantics_bar_label_rows.csv'));
writetable(barSummary, fullfile(diagnosticsDir, ...
    'window_semantics_bar_label_summary.csv'));
writetable(inputAudit, fullfile(diagnosticsDir, ...
    'window_semantics_input_audit.csv'));

manifest = table();
manifest.schema_version = "window_semantics_v1";
manifest.status = status;
manifest.timezone_status = conditional_label(timezonePass, "certified", "failed");
manifest.raw_time_zone = "America/Chicago";
manifest.analysis_time_zone = "UTC";
manifest.bar_label_status = conditional_label(barPass, "certified", "failed");
manifest.bar_label_semantics = barSemantics;
manifest.canonical_bar_time = "interval_end_utc";
manifest.minimum_timezone_match_share = min(timeAudit.ohlcv_exact_share);
manifest.bar_label_score_margin = barSummary.score_margin(1);
manifest.input_manifest_sha256 = File_sha256(inputManifestFile);
manifest.generated_at_utc = string(datetime('now', 'TimeZone', 'UTC'), ...
    'yyyy-MM-dd HH:mm:ss');
manifest.matlab_version = string(version());
writetable(manifest, fullfile(manifestDir, 'window_semantics_manifest.csv'));

fprintf('\n================ WINDOW SEMANTICS CERTIFICATION ================\n');
fprintf('Timezone provenance : %s\n', manifest.timezone_status);
fprintf('Bar label semantics : %s\n', manifest.bar_label_semantics);
fprintf('Overall status      : %s\n', manifest.status);
fprintf('Manifest            : %s\n', ...
    fullfile(manifestDir, 'window_semantics_manifest.csv'));
fprintf('================================================================\n');

if status ~= "certified"
    error(['WINDOW_SEMANTICS_NOT_CERTIFIED: inspect the timezone and bar-label ' ...
        'diagnostics before constructing phase-specific windows.']);
end

function filePath = resolve_path(projectRoot, candidate)
    candidate = char(candidate);
    if exist(candidate, 'file') == 2
        filePath = string(candidate);
        return;
    end
    combined = fullfile(projectRoot, candidate);
    if exist(combined, 'file') ~= 2
        error('WINDOW_SEMANTICS_FILE_MISSING: %s', combined);
    end
    filePath = string(combined);
end

function label = conditional_label(flag, yes, no)
    if flag
        label = string(yes);
    else
        label = string(no);
    end
end

function T = format_dates(T)
    if ismember("five_minute_time_utc", string(T.Properties.VariableNames)) && ...
            isdatetime(T.five_minute_time_utc)
        T.five_minute_time_utc = string(T.five_minute_time_utc, ...
            'yyyy-MM-dd HH:mm:ss');
    end
end
