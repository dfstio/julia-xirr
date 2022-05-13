using Genie
using Genie.Router, Genie.Renderer.Html, Genie.Requests
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



function launchServer(port)

    Genie.config.run_as_server = true
    Genie.config.server_host = "0.0.0.0"
    Genie.config.server_port = port

    println("port set to $(port)")

message = "Please enter lease parameters"

form = """
<form action="/" method="POST" enctype="multipart/form-data">
  <label $(message)/>
  <input type="number" name="price" value="" placeholder="What's the price?" />
  <input type="number" name="deposit" value="" placeholder="What's the deposit?" />
  <input type="submit" value="Calculate XIRR" />
</form>
"""

route("/") do
  html(form)
end

route("/xirr", method = POST) do
  params = jsonpayload()
  (:xirr => params["price"]) |> json
end

route("/", method = POST) do
  price = parse(Int64, postpayload(:price))
  deposit = parse(Int64, postpayload(:deposit))
  firstcf = deposit - price
  cf = [firstcf,10,10,10,10,10,10,10,10,10,10,10,400]	
  result = xirr(cf,dates)	
  message = "XIRR for price $(price) and deposit $(deposit) is $(result)"
  html(form)
end

    Genie.AppServer.startup()
end

launchServer(parse(Int, ARGS[1]))

