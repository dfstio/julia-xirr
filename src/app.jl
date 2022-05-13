using Genie
using Genie.Router, Genie.Renderer.Html, Genie.Requests, Genie.Renderer.Json
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


form = """
<h1> Please enter lease parameters </h1>
<form action="/" method="POST" enctype="multipart/form-data">
  <input type="number" name="price" value=500 placeholder="What's the price?" />
  <input type="number" name="deposit" value=100 placeholder="What's the deposit?" />
  <input type="submit" value="Calculate XIRR" />
</form>
"""

route("/") do
  html(form)
end

route("/xirr", method = POST) do
  params = jsonpayload()
  price = parse(Int64, params["price"])
  deposit = parse(Int64, params["deposit"])
  firstcf = deposit - price
  cf = [firstcf,10,10,10,10,10,10,10,10,10,10,10,400]	
  result = xirr(cf,dates)	

  (:xirr => result) |> json
end

route("/", method = POST) do
  price = parse(Int64, postpayload(:price))
  deposit = parse(Int64, postpayload(:deposit))
  firstcf = deposit - price
  cf = [firstcf,10,10,10,10,10,10,10,10,10,10,10,400]	
  result = xirr(cf,dates)	
  msg = "XIRR for price $(price) and deposit $(deposit) is $(result)"
  
 newform = """
<h2>$(msg)</h2>
<form action="/" method="POST" enctype="multipart/form-data">
  <input type="number" name="price" value=$(price) placeholder="What's the price?" />
  <input type="number" name="deposit" value=$(deposit) placeholder="What's the deposit?" />
  <input type="submit" value="Calculate new XIRR" />
</form>
""" 

  html(newform)
end

    Genie.AppServer.startup()
end

launchServer(parse(Int, ARGS[1]))

