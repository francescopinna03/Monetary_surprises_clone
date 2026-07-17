diary(fullfile(fileparts(mfilename('fullpath')), 'pipeline_run.log'));

fprintf('Pipeline start %s\n', string(datetime('now')));
fprintf('Data root: %s\n', Get_project_root());

fprintf('\n[ 1/20] Audit_Barchart\n');
Audit_Barchart;

fprintf('\n[ 2/20] Clean_raw_files\n');
Clean_raw_files;

fprintf('\n[ 3/20] Contract_event_day\n');
Contract_event_day;

fprintf('\n[ 4/20] Event_panel_construction\n');
Event_panel_construction;

fprintf('\n[ 5/20] Event_windows\n');
Event_windows;

fprintf('\n[ 6/20] Press_release_panel\n');
Press_release_panel;

fprintf('\n[ 7/20] Regression_fractional\n');
Regression_fractional;

fprintf('\n[ 8/20] PR_signal_model\n');
PR_signal_model;

fprintf('\n[ 9/20] State_vector_panel\n');
State_vector_panel;

fprintf('\n[10/20] State_dependent_models\n');
State_dependent_models;

fprintf('\n[11/20] Shock_purification_models\n');
Shock_purification_models;

fprintf('\n[12/20] Functional_state_models\n');
Functional_state_models;

fprintf('\n[13/20] Volatility_components\n');
Volatility_components;

fprintf('\n[14/20] Hierarchical_shrinkage\n');
Hierarchical_shrinkage;

fprintf('\n[15/20] PR_bar_panel\n');
PR_bar_panel;

fprintf('\n[16/20] BNS_volatility\n');
BNS_volatility;

fprintf('\n[17/20] Quasi_markov_residual_predictability\n');
Quasi_markov_residual_predictability;

fprintf('\n[18/20] Announcement_counterfactual\n');
Announcement_counterfactual;

fprintf('\n[19/20] Announcement_counterfactual_validation\n');
Announcement_counterfactual_validation;

fprintf('\n[20/20] Announcement_risk_rotation\n');
Announcement_risk_rotation;

fprintf('\nPipeline end %s\n', string(datetime('now')));

diary off;
