using Genie
using Genie.Router

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
result = xirr(cf,dates)

function launchServer(port)

    Genie.config.run_as_server = true
    Genie.config.server_host = "0.0.0.0"
    Genie.config.server_port = port

    println("port set to $(port)")

    route("/") do
        result
    end

    Genie.AppServer.startup()
end

launchServer(parse(Int, ARGS[1]))

