function logResults(table, name)

    mkdir(['results/' date() '/']);
    writetable(table, ['results/' date() '/' name '.csv']);

end