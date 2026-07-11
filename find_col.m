function col = find_col(allNames, candidates)

    col = "";
    lowerAll = lower(string(allNames));

    for c = lower(string(candidates))
        idx = find(lowerAll == c, 1);

        if ~isempty(idx)
            col = allNames(idx);
            return;
        end
    end
end
