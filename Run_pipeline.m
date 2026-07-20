diary(fullfile(fileparts(mfilename('fullpath')), 'pipeline_run.log'));

fprintf('Pipeline start %s\n', string(datetime('now')));
fprintf('Data root: %s\n', Get_project_root());

% The complete replication is an immutable final run.  Reduced-draw
% overrides are accepted only by the dedicated smoke-test wrappers; they must
% never leak into Run_pipeline through a caller's shell environment.
setenv('ANNOUNCEMENT_VALIDATION_DRAWS', '999');
setenv('ANNOUNCEMENT_ROTATION_DRAWS', '999');
setenv('ANNOUNCEMENT_RESOLUTION_MODE', 'final');
setenv('ANNOUNCEMENT_RESOLUTION_DRAWS', '999');
fprintf('Locked inference draws: Steps 19--21 = 999; Step 21 mode = final\n');

fprintf('\n[preflight] Time_alignment_self_test\n');
Time_alignment_self_test();

fprintf('\n[ 1/25] Audit_Barchart\n');
Audit_Barchart;

fprintf('\n[ 2/25] Clean_raw_files\n');
Clean_raw_files;

fprintf('\n[ 3/25] Contract_event_day\n');
Contract_event_day;

fprintf('\n[ 4/25] Event_panel_construction\n');
Event_panel_construction;

fprintf('\n[audit] Event_time_alignment_audit\n');
Event_time_alignment_audit;

fprintf('\n[ 5/25] Event_windows\n');
Event_windows;

fprintf('\n[ 6/25] Press_release_panel\n');
Press_release_panel;

fprintf('\n[ 7/25] Regression_fractional\n');
Regression_fractional;

fprintf('\n[ 8/25] PR_signal_model\n');
PR_signal_model;

fprintf('\n[ 9/25] State_vector_panel\n');
State_vector_panel;

fprintf('\n[10/25] State_dependent_models\n');
State_dependent_models;

fprintf('\n[11/25] Shock_purification_models\n');
Shock_purification_models;

fprintf('\n[12/25] Functional_state_models\n');
Functional_state_models;

fprintf('\n[13/25] Volatility_components\n');
Volatility_components;

fprintf('\n[14/25] Hierarchical_shrinkage\n');
Hierarchical_shrinkage;

fprintf('\n[15/25] PR_bar_panel\n');
PR_bar_panel;

fprintf('\n[16/25] BNS_volatility\n');
BNS_volatility;

fprintf('\n[17/25] Quasi_markov_residual_predictability\n');
Quasi_markov_residual_predictability;

fprintf('\n[18/25] Announcement_counterfactual\n');
Announcement_counterfactual;

fprintf('\n[19/25] Announcement_counterfactual_validation\n');
Announcement_counterfactual_validation;

fprintf('\n[20/25] Announcement_risk_rotation\n');
Announcement_risk_rotation;

fprintf('\n[21/25] Announcement_risk_resolution\n');
Announcement_risk_resolution;

setenv('PHASE_EXTENSION_MODE', 'all');
Run_phase_extension;

fprintf('\nPipeline end %s\n', string(datetime('now')));

diary off;
