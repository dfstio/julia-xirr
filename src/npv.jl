using Optim, Dates, DayCounts, Roots, BenchmarkTools
function xnpv(xirr,cf,dates)
    interval = map(d -> DayCounts.yearfrac(dates[1],d,DayCounts.Actual365Fixed()),dates)
    sum(cf./(1+xirr).^interval)
end
function xirr(xnpv,cf,dates)
    f(x) = xnpv(x,cf,dates)
    result = optimize(x -> f(x)^2,0.0,1.0,Brent())
    return result.minimizer
end
function xirr_roots(xnpv,cf,dates)
    f(x) = xnpv(x,cf,dates)
    return fzero(f,[0.0,1.0])
end
dates = Date(2012,12,31):Year(1):Date(2016,12,31)
cf = [-100,10,10,10,110]
@benchmark optimR = xirr(xnpv,cf,dates)
@benchmark Roots = xirr_roots(xnpv,cf,dates)

xirr(cf,dates)


using Optim, Dates, DayCounts
function cf_freq(dates)
    map(d -> DayCounts.yearfrac(dates[1],d,DayCounts.Actual365Fixed()),dates)
end
function xnpv(xirr,cf,interval)
    sum(cf./(1+xirr).^interval)
end
function xirr(cf,dates)
    interval = cf_freq(dates)
    f(x) = xnpv(x,cf,interval)
    result = optimize(x -> f(x)^2,0.0,1.0,Brent())
    return result.minimizer
end

dates = Date(2022,01,01):Month(1):Date(2023,01,01)
cf = [-500,10,10,10,10,10,10,10,10,10,10,10,400]
@benchmark tradle = xirr(cf,dates)