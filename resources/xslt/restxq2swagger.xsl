<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:param name="info.description"/>
    <xsl:param name="info.version">0.1</xsl:param>
    <xsl:param name="info.title"/>
    <xsl:param name="info.tos"/>
    <xsl:param name="info.maintainer"/>
    <xsl:param name="info.license.name"/>
    <xsl:param name="info.license.url"/>
    <xsl:param name="host"/>
    <xsl:param name="basePath"/>
    <xsl:param name="basePath-restxq"/>
    <!-- comma-separated list of schemes-->
    <xsl:param name="schemes"/>
    <xsl:param name="docs.description"/>
    <xsl:param name="docs.url"/>
    
    <xsl:template match="/module">
        <map xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.w3.org/2005/xpath-functions https://www.w3.org/TR/xpath-functions-31/schema-for-json.xsd">
            <string key="swagger">2.0</string>
            <map key="info">
                <string key="description"><xsl:value-of select="$info.description"/></string>
                <string key="version"><xsl:value-of select="$info.version"/></string>
                <string key="title"><xsl:value-of select="$info.title"/></string>
                <string key="termsOfService"><xsl:value-of select="$info.tos"/></string>
                <map key="contact">
                    <string key="email"><xsl:value-of select="$info.maintainer"/></string>
                </map>
                <map key="license">
                    <string key="name"><xsl:value-of select="$info.license.name"/></string>
                    <string key="url"><xsl:value-of select="$info.license.url"/></string>
                </map>
            </map>
            <string key="host"><xsl:value-of select="$host"/></string>
            <string key="basePath"><xsl:value-of select="concat($basePath,$basePath-restxq)"/></string>
            <array key="tags">
                <xsl:for-each-group select="//annotation[@name = 'swagger:tag']" group-by="value[1]">
                    <map>
                        <string key="name"><xsl:value-of select="current-grouping-key()"/></string>
                        <string key="description"><xsl:value-of select="current-group()/value[2]"/></string>
                    </map>
                </xsl:for-each-group>
            </array>
            <map key="paths">
                <xsl:for-each-group select="//function[annotation[@name = 'rest:path']][not(annotation[@name = 'swagger:ignore'])][annotation[@name = 'api:version']/value[1] = $info.version]" group-by="annotation[@name = 'rest:path']/value[1]">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:variable name="path" select="replace(replace(current-grouping-key(),'\$',''),$basePath-restxq,'')"/>
                    <map key="{($path,'.')[.!=''][1]}">
                        <xsl:for-each-group select="current-group()/annotation[matches(@name,'rest:\p{Lu}+$')]" group-by="@name">
                            <xsl:variable name="method" select="substring-after(current-grouping-key(),'rest:')"/>
                            <map key="{lower-case($method)}">
                                <array key="tags">
                                    <xsl:for-each-group select="current-group()/../annotation[@name = 'swagger:tag']" group-by="value[1]">
                                        <string><xsl:value-of select="current-grouping-key()"/></string>
                                    </xsl:for-each-group>
                                </array>
                                <xsl:apply-templates select="current-group()/../annotation[@name = 'swagger:summary']"/>
                                <xsl:apply-templates select="current-group()/../annotation[@name = 'swagger:description']"/>
                                <xsl:apply-templates select="current-group()/../annotation[@name = 'swagger:operationId']"/>
                                <array key="produces">
                                    <xsl:apply-templates select="current-group()/../annotation[@name = 'rest:produces']"/>
                                </array>
                                
                                
                                <map key="responses">
                                    <xsl:apply-templates select="current-group()/../annotation[@name = 'swagger:response']"/>
                                    <xsl:if test="not(exists(current-group()/../annotation[@name = 'swagger:response'][value[2] = '200']))">
                                        <map key="200">
                                            <string key="description">success</string>
                                        </map>
                                    </xsl:if>
                                </map>
                                
                                
                                <xsl:if test="current-group()/../annotation[@name = 'rest:query-param'] | current-group()/../argument[not(@var = current-group()/../annotation[@name = 'rest:query-param']/value[1])]">
                                    <array key="parameters">
                                        <xsl:for-each-group select="current-group()/../annotation[@name = 'rest:query-param']" group-by="value[1]">
                                            <xsl:apply-templates select="current-group()[1]"/>
                                        </xsl:for-each-group>
                                        <xsl:for-each-group select="current-group()/../argument[not(@var = current-group()/../annotation[@name = 'rest:query-param']/value[1])]" group-by="@var">
                                            <xsl:apply-templates select="current-group()[1]"/>
                                        </xsl:for-each-group>
                                    </array>
                                </xsl:if>
                            </map>
                        </xsl:for-each-group>
                    </map>
                </xsl:for-each-group>
            </map>
            <array key="schemes">
                <xsl:for-each select="tokenize($schemes,',')">
                    <string><xsl:value-of select="normalize-space(.)"/></string>
                </xsl:for-each>
            </array>
            <xsl:if test="$docs.description != '' and $docs.url != ''">
                <map key="externalDocs">
                    <string key="description"><xsl:value-of select="$docs.description"/></string>
                    <string key="url"><xsl:value-of select="$docs.url"/></string>
                </map>
            </xsl:if>
        </map>
    </xsl:template>
    
    <xsl:template match="annotation[@name  = ('swagger:summary', 'swagger:description','swagger:operationId')]">
        <xsl:for-each select="value">
            <string key="{substring-after(../@name,':')}">
                <xsl:value-of select="."/>
            </string>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="annotation[@name  = ('rest:produces')]">
        <xsl:for-each select="value">
            <string>
                <xsl:value-of select="."/>
            </string>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="annotation[@name = 'swagger:response']">
        <map key="{value[1]}">
            <string key="description"><xsl:value-of select="value[2]"/></string>
        </map>
    </xsl:template>
    
    <xsl:template match="annotation[@name = 'rest:query-param']">
        <map>
            <string key="in">query</string>
            <string key="name"><xsl:value-of select="value[1]"/></string>
            <string key="description">
                <xsl:apply-templates select="../annotation[@name = 'swagger:query-param-description'][value[1] = current()/value[1]]/value[2]"/>    
            </string>
            <xsl:apply-templates select="../annotation[@name = 'api:query-param-properties'][value[1] = current()/value[1]]"/>
            <string key="type">
                <xsl:variable name="x-type" select="../argument[@var = current()/value[1]]/@type"/>
                <xsl:value-of select="substring-after($x-type, ':')"/>
            </string>
            <string key="default">
                <xsl:value-of select="value[3]"/>
            </string>
        </map>
    </xsl:template>
    
    <xsl:template match="annotation[@name = 'api:query-param-properties']">
        <xsl:variable name="val" select="value[3]"/>
        <xsl:variable name="elem">
            <xsl:choose>
                <xsl:when test="$val = ('true','false')">boolean</xsl:when>
                <xsl:when test="matches($val,'^\d+$')">integer</xsl:when>
                <xsl:otherwise>string</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$elem}">
            <xsl:attribute name="key" select="value[2]"/>
            <xsl:value-of select="$val"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="argument">
        <map>
            <string key="name"><xsl:value-of select="@var"/></string>
            <string key="in">path</string>
            <string key="description">
                <xsl:apply-templates select="../annotation[@name = 'swagger:query-param-description'][value[1] = current()/@var]/value[2]"/>
            </string>
            <string key="type"><xsl:value-of select="substring-after(@type,':')"/></string>
            <boolean key="required">true</boolean>
            <xsl:apply-templates select="../annotation[@name = 'api:query-param-properties'][value[1] = current()/@var]"/>
        </map>
    </xsl:template>
    
    
</xsl:stylesheet>