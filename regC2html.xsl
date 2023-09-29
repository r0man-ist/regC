<?xml version="1.0" encoding="UTF-8"?>
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="/">
        
        <!--  Main output -->
        <html lang="en">
            <head>
                <title>
                    <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title"/>
                </title>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"/>
                
            </head>
            <body>
                
                <div class="jumbotron text-center">
                    <h1>
                        <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title"/>
                    </h1>
                </div>
                <p>
                    <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:respStmt"/>
                </p>
                <p>
                    <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:publicationStmt"/>
                </p>
                <p>
                    <xsl:value-of select="/t:TEI/t:teiHeader[1]/t:fileDesc[1]/t:sourceDesc[1]"/>
                </p>
                <div class="container mt-5">
                    <xsl:apply-templates select="//t:text"/>
                </div>
            </body>
        </html>
        
    </xsl:template>
    <!-- Dressing Table -->
    <xsl:attribute-set name="full.size.table">
        <xsl:attribute name="class" select="'table table-fixed'"/>
        <!--<xsl:attribute name="style" select="'width:100%'"/>-->
    </xsl:attribute-set>
    <xsl:template match="t:table">
        <xsl:element name="table" use-attribute-sets="full.size.table">
            <xsl:apply-templates select="t:row"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Dealing with rows -->
    <!-- General styling of rows -->
    <xsl:template match="t:row">
        <tr>
            <xsl:apply-templates select="t:cell"/>
            <xsl:choose>
                <xsl:when test="@ana = 'prov:purchase'">
                    <td style="width:5%">
                        <xsl:variable name="rowId" select="t:cell/t:ptr/@target"/>
                        <button type="button" class="btn btn-light" data-bs-toggle="modal"
                            data-bs-target="#myModal" value="{$rowId}"><xsl:value-of select="$rowId"></xsl:value-of></button>
                        
                        <div class="modal" id="myModal">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <!-- Modal Header -->
                                    <div class="modal-header">
                                        
                                        <h4 class="modal-title">test</h4>
                                        <button type="button" class="btn-close"
                                            data-bs-dismiss="modal"/>
                                    </div>
                                    <!-- Modal body -->
                                    <div class="modal-body">
                                        <p id="input">
                                            <xsl:value-of select="../t:cell/t:ref"/>
                                        </p>
                                        
                                    </div>
                                    <!-- Modal footer -->
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-danger"
                                            data-bs-dismiss="modal">Close</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </td>
                </xsl:when>
            </xsl:choose>
            
            
        </tr>
    </xsl:template>
    
    
    
    <!-- style cells, borders and headings -->
    <xsl:template match="t:cell[@cols and @rows]">
        <xsl:choose>
            <xsl:when test="@rend = 'border-top'">
                <td colspan="{@cols}" rowspan="{@rows}" style="border-top:2px double">
                    <xsl:apply-templates/>
                </td>
            </xsl:when>
            <xsl:when test="@rend = 'head'">
                <th colspan="{@cols}" rowspan="{@rows}">
                    <xsl:apply-templates/>
                </th>
            </xsl:when>
            <xsl:otherwise>
                <td colspan="{@cols}" rowspan="{@rows}">
                    <xsl:apply-templates/>
                </td>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    
    <!-- linebreaks -->
    <xsl:template match="t:lb">
        <br>
            <xsl:apply-templates/>
        </br>
    </xsl:template>
    
    <!-- supercripts -->
    <xsl:template match="t:hi[@rend = 'superscript:true']">
        <sup>
            <xsl:apply-templates/>
        </sup>
    </xsl:template>
    <!-- underlined -->
    <xsl:template match="t:hi[@rend = 'underlined:true']">
        <u>
            <xsl:apply-templates/>
        </u>
    </xsl:template>
    <!-- deletions -->
    <xsl:template match="//t:del">
        <s>
            <xsl:apply-templates/>
        </s>
    </xsl:template>
    <!-- choice for abbreviations -->
    <xsl:template match="t:choice">
        <span title="{t:expan}">
            <xsl:value-of select="t:abbr"/>
        </span>
    </xsl:template>
    <!-- choice for shelfmark normalisation -->
    <xsl:template match="t:ab[@type='shelfmark']/t:choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="t:reg"></xsl:template>
    <!-- deletions -->
    <xsl:template match="t:del">
        <s>
            <xsl:apply-templates/>
        </s>
    </xsl:template>
    
    <!-- pagebreaks -->
    <xsl:template match="t:pb">
        <div class="page text-center text-muted mt-5 mb-3" level="" id="">
            <span class="pageNumber">
                <b>
                    <xsl:value-of select="./@xml:id"/><xsl:if test="./@n castable as xs:integer"> / Page <xsl:value-of select="./@n"/></xsl:if>
                </b>
                <hr/>
            </span>
        </div>
        
        
    </xsl:template>
    
    <!--List of purchased books by year-->
    <!--       <xsl:result-document href="purchased.html" method="html">
            <head>
                <title>
                    <xsl:text>Books purchased</xsl:text>
                </title>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
            </head>
            <body>

                <div class="jumbotron text-center">
                    <h1>
                        <xsl:text>List of purchased books by year</xsl:text> </h1>
                </div>
                <ul><xsl:for-each-group select="//t:ab[@ana][.//t:row[@ana='prov:purchase']]" group-by="@ana">
                    <li><xsl:value-of select="//t:objectName"/><xsl:value-of select="current-grouping-key()"/> </li></xsl:for-each-group></ul>
                
            </body>
        </xsl:result-document>
    </xsl:template>-->
    
    
</xsl:stylesheet>