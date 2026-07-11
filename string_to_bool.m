function y = string_to_bool(x)

    x = lower(strtrim(string(x)));
    y = x == "true" | x == "1";
end
