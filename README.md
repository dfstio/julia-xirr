# Julia XIRR
Calculating XIRR with Julia on web and with POST API on heroku server

## Deployment

web https://ancient-sea-xirr2.herokuapp.com


api https://ancient-sea-xirr2.herokuapp.com/xirr   
api JSON format: {"price": "500", "deposit": "104"}



## Links

https://discourse.julialang.org/t/optimization-using-optim-and-roots/39301
https://docs.julialang.org/
https://www.genieframework.com/docs/genie/guides/Simple-API-backend.html
https://www.genieframework.com/docs/genie/tutorials/Deploying-With-Heroku-Buildpacks.html
https://devcenter2.assets.heroku.com/articles/heroku-local


## Julia from scratch

	$ mkdir genie_test
	$ cd genie_test
	$ julia ]
	pkg> activate .
	pkg> add Genie
