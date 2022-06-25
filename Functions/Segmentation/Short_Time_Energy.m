function ste=Short_Time_Energy(y)

ste = sum(buffer(y.^2, length(y)));

end
