% Create the struct with all config values
function[Config] = AAOS_LoadConfig()

    Config = {};

    % load general config
    run("config/default.m")

    % load season-dependent config
    season_config_filename = "config/season_" + Config.season + ".m";
    run(season_config_filename);


end
