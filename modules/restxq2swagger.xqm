xquery version "3.1";

(:~ 
 : A XQuery module to serialize RestXQ annotations as a swagger document.   
 : 
 : @author Daniel Schopper
 : @version 0.1 
 :)

module namespace rxq2s = "http://acdh.oeaw.ac.at/restxq2swagger";

import module namespace inspect="http://exist-db.org/xquery/inspection";
import module namespace config="http://acdh.oeaw.ac.at/restxq2swagger/config" at "config.xqm";
import module namespace jx = "http://joewiz.org/ns/xquery/json-xml" at "json-xml.xqm";

declare variable $rxq2s:xml2json-xml as document-node() := doc($config:app-root||"/resources/xslt/restxq2swagger.xsl");

(:~
 : Turns a RestXQ module to a swagger file.
 : 
 : @param $ref A reference to a RestXQ module or the output of exist-db's inspect:module() function   
 : @param $parameters A map containing additional metadata which is not part of the output of inspect:module()
 : @returns a JSON Swagger document
~:)
declare function rxq2s:swaggerize($ref as item(), $parameters as map(*)){
    let $data := 
        typeswitch ($ref) 
            case xs:anyURI return inspect:inspect-module($ref)
            case document-node() return rxq2s:swaggerize($ref/*, $parameters)
            case element(module) return $ref
            default return fn:error(QName("http://acdh.oeaw.ac.at/restxq2swagger", "unexpectedInput"), "Unexpected input for function argument #1", $ref)
    let $xsl-params := <parameters>{
            for $key in map:keys($parameters) 
            return <param name="{$key}" value="{map:get($parameters, $key)}"/>
        }</parameters>
    let $xsl := $rxq2s:xml2json-xml
    let $json-xml := transform:transform($data, $xsl, $xsl-params)
    return jx:xml-to-json($json-xml)
};