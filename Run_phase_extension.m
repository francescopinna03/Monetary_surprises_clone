%% DRIVER FOR CERTIFICATION, PHASE WINDOWS, MP-CBI SHOCKS AND COUNTERFACTUALS.

clear; clc;

mode = lower(strtrim(string(getenv('PHASE_EXTENSION_MODE'))));
if strlength(mode) == 0
    mode = "all";
end
if ~ismember(mode, ["certify", "build", "all"])
    error('PHASE_EXTENSION_MODE must be certify, build or all.');
end

fprintf('Phase extension start %s | mode=%s\n', string(datetime('now')), mode);

if ismember(mode, ["certify", "all"])
    Window_semantics_self_test();
    Window_semantics_certification;
end

if ismember(mode, ["build", "all"])
    Phase_window_self_test();
    Shock_component_self_test();
    Phase_window_construction;
    Shock_component_construction;

    previousPhase = string(getenv('ANNOUNCEMENT_PHASE'));
    for phase = ["PR", "PC", "ME"]
        setenv('ANNOUNCEMENT_PHASE', phase);
        Announcement_phase_counterfactual();
    end
    setenv('ANNOUNCEMENT_PHASE', previousPhase);

    Component_sufficiency_self_test();
    Component_sufficiency_analysis();

    Phase_component_contrast_self_test();
    Phase_component_contrasts();
end

fprintf('Phase extension end %s | mode=%s\n', string(datetime('now')), mode);
