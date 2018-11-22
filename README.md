# restxq2swagger
A existdb XQuery library to create swagger documentation from RestXQ modules.

## Install 

Pull a fresh copy of this repository, cd into the cloned directory and call `ant`. A xar package will be generated into the `build` directory which can be installed into an eXist-db installation

## Usage

1. Create a XQuery module with RestXQ annotations, as usual.
2. Add some additional annotations to your module functions:      

TODO describe

3. Call with the path to the XQuery module + parameters as a XQuery map

~~~
let $params := let $params := map {
        "info.title" := "API's name",
        "info.version" := "version-number",
        "info.description" := "API's description",
        "info.maintainer" := "contact",
        "info.license.name" := "License name",
        "info.license.url" := "License URL",
        "info.tos" := "Link to API's terms of service",
        "host" :="host of the api",
        "basePath" := "base path of the API",
        "basePath-restxq" := "base of the RestXQ path",
        "api:schemes" := "https"
    }
return rxq2s:swaggerize("/db-path-to-module", $params) 
~~~


## Notes

This repository makes use of Joe Wicentowski's implementation of XQuery 3.1's fn:xml-to-json function, integrated as a git submodule.
