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
                <script src="https://code.jquery.com/jquery-3.6.0.min.js"/>
                <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"/>


                <!-- Script for pulling data into modal -->
                <script type="text/javascript">
                    <![CDATA[
    function openModal(target) {
      
      // Create a URL for the XML data file
      const xmlDataUrl = 'https://raw.githubusercontent.com/r0man-ist/regC/main/RegC.xml';

      // Use jQuery to load the XML data
      $.ajax({
        type: 'GET',
        url: xmlDataUrl,
        dataType: 'xml',
        success: function(xmlData) {

         const modifiedTarget = '[xml\\:id="' + target.substring(1) + '"]';

          const item = $(xmlData).find(modifiedTarget);
          if (item.length > 0) {
            const targetElement = item[0];
            const attributeValue = $(targetElement).attr('ana');
            const title = item.find('title').text();
            const author = item.find('author').text();
            const link = item.find('idno[type=SOLOlink]').text();
            const date = item.find('date').text();
            const place = item.find('pubPlace').text();
            const shelfmark = item.find('idno[type=shelfmark]').text();
             // conditional whether copy is identified
             if (attributeValue === "copy-identified") {
                const modalTitle = "The copy has been identified";
                const xmlContent = `
                <p>${author}</p>
                <p>${title}</p>
                <p>${place}, ${date}</p>
                <p>Today's Shelfmark: ${shelfmark}</p>
                <p><a href="${link}">Bibliographic Record in SOLO</a></p>`
                $('#modal-title').html(modalTitle);
                $('#modal-description').html(xmlContent);
                $('#myModal').modal('show');
                }
             else {
                const modalTitle = "The copy could not be localized";
                const xmlContent = `
                <p>The work/edition most likely is the following:</p>
                <p>${author}</p>
                <p>${title}</p>
                <p>${place}, ${date}</p>`
                $('#modal-title').html(modalTitle);
                $('#modal-description').html(xmlContent);
                $('#myModal').modal('show');
                }
          } else {
            console.error('Object with target ' + modifiedTarget + ' not found.');
          }
        },
        error: function(xhr, status, error) {
          console.error('Error loading XML data: ' + error);
        }
      });
    }
  ]]>
                </script>
                
<!-- css -->
<style>
    a {color: #CC9900;
    text-decoration: none;}
</style>


            </head>


            <body>
                <!-- Navbar -->

                <nav class="navbar navbar-expand-lg"
                    style="position: sticky;  top: 0;background: silver;z-index: 100;">
                    <div class="container-fluid">
                        <div class="navbar-header">
                            <a class="navbar-brand" href="index.html">RegC</a>
                        </div>
                        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                            data-bs-target="#navbarSupportedContent">
                            <span class="navbar-toggler-icon"/>
                        </button>
                        <div class="collapse navbar-collapse" id="navbarSupportedContent">
                            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                                <li class="nav-item">
                                    <a class="nav-link active" aria-current="page" href="about.html"
                                        >about</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link active" href="persons.html">persons</a>
                                </li>
                                <li class="nav-item dropdown">
                                    <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown"
                                        role="button" data-bs-toggle="dropdown"
                                        aria-expanded="false"> go to page </a>
                                    <ul class="dropdown-menu"
                                        style="height: auto;max-height: 400px; overflow-x: hidden;">
                                        <li>
                                            <xsl:for-each select="//t:pb">
                                                <xsl:variable name="pageNav" select="./@xml:id"/>
                                                <a class="dropdown-item" href="#{$pageNav}">
                                                  <xsl:value-of select="./@xml:id"/>
                                                  <xsl:if test="./@n castable as xs:integer"> / Page
                                                  <xsl:value-of select="./@n"/></xsl:if>
                                                </a>
                                            </xsl:for-each>
                                        </li>
                                    </ul>
                                </li>
                                <li class="nav-item dropdown">
                                    <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown"
                                        role="button" data-bs-toggle="dropdown"
                                        aria-expanded="false"> go to year </a>
                                    <ul class="dropdown-menu"
                                        style="height: auto;max-height: 400px; overflow-x: hidden;">
                                        <li>

                                            <a class="dropdown-item" href="#fol-7r">1720</a>
                                        </li>
                                    </ul>
                                </li>
                            </ul>
                           
                        </div>
                    </div>
                </nav>


                <!-- title -->
                <div class="content-container" style="padding-top: 70px;">
                    <div class="jumbotron text-center">
                        <h1>
                            <xsl:value-of select="/t:TEI/t:teiHeader/t:fileDesc/t:titleStmt/t:title"
                            />
                        </h1>
                    </div>

                    <!-- text -->
                    <div class="container mt-5">
                        <xsl:apply-templates select="//t:text"/>
                    </div>
                </div>
            </body>
        </html>

        <!-- persons html document -->
        <xsl:result-document href="persons.html" method="html">
            <html lang="en">
                <title>Index of persons</title>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"/>
                <script src="https://code.jquery.com/jquery-3.6.0.min.js"/>
                <body>
                    <nav class="navbar navbar-expand-lg sticky-top"
                        style="position: sticky;  top: 0;background: silver;z-index: 100;">
                        <div class="container-fluid">
                            <div class="navbar-header">
                                <a class="navbar-brand" href="index.html">RegC</a>
                            </div>
                            <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                                data-bs-target="#navbarSupportedContent">
                                <span class="navbar-toggler-icon"/>
                            </button>
                            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                                    <li class="nav-item">
                                        <a class="nav-link active" aria-current="page"
                                            href="about.html">about</a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link active" href="persons.html">persons</a>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </nav>
                    <div class="container mt-5">
                        <xsl:apply-templates select="//t:listPerson"/>
                    </div>
                    <!-- css  -->
                    <style>
                        :target {background-color: #FFCC33;scroll-margin-top: 70px}<!-- to highlight target fragments -->
                        a {color: #CC9900;
                        text-decoration: none;}}
                    </style>
                </body>
            </html>

        </xsl:result-document>

        <!-- about html document -->
        <xsl:result-document href="about.html" method="html">
            <html lang="en">
                <title>Index of persons</title>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"/>
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"/>
                <script src="https://code.jquery.com/jquery-3.6.0.min.js"/>
                <body>
                    <nav class="navbar navbar-expand-lg"
                        style="position: sticky;  top: 0;background: silver;z-index: 100;">
                        <div class="container-fluid">
                            <div class="navbar-header">
                                <a class="navbar-brand" href="index.html">RegC</a>
                            </div>
                            <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                                data-bs-target="#navbarSupportedContent">
                                <span class="navbar-toggler-icon"/>
                            </button>
                            <div class="collapse navbar-collapse" id="navbarSupportedContent">
                                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                                    <li class="nav-item">
                                        <a class="nav-link active" aria-current="page"
                                            href="about.html">about</a>
                                    </li>
                                    <li class="nav-item">
                                        <a class="nav-link active" href="persons.html">persons</a>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </nav>
                    <div class="container mt-5">
                        <xsl:apply-templates select="/t:fileDesc"/>
                    </div>
                </body>
            </html>

        </xsl:result-document>

    </xsl:template>




    <!-- Title -->
    <xsl:template match="t:docTitle">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>
    <!--  Table -->
    <xsl:attribute-set name="full.size.table">
        <xsl:attribute name="class" select="'table table-fixed'"/>
        <!--<xsl:attribute name="style" select="'width:100%'"/>-->
    </xsl:attribute-set>
    <xsl:template match="t:table">
        <xsl:element name="table" use-attribute-sets="full.size.table">
            <xsl:apply-templates select="t:row"/>
        </xsl:element>
    </xsl:template>
    <!-- paragraphs -->
    <xsl:template match="t:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <!-- Dealing with rows -->

    <!-- General styling of rows -->
    <xsl:template match="t:row">
        <xsl:variable name="call-modal">
            <td style="width:5%">
                <!-- Modal -->
                <div class="modal fade" id="myModal" role="dialog">
                    <div class="modal-dialog">
                        <!-- Modal content -->
                        <div class="modal-content">
                            <div class="modal-header">
                                <h4 class="modal-title" id="modal-title"/>
                            </div>
                            <div class="modal-body" id="modal-description">
                                <!-- XML data will be added here -->
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default"
                                    data-bs-dismiss="modal">Close</button>
                            </div>
                        </div>
                    </div>
                </div>
                <xsl:variable name="target" select="t:cell/t:bibl[1]/@corresp"/>
                <button type="button" class="btn btn-light" onclick="openModal('{$target}')"
                    >Details</button>
            </td>
        </xsl:variable>

        <tr>
            <xsl:apply-templates select="t:cell"/>
            <xsl:choose>
                <xsl:when test="@ana = 'prov:purchase' and ./t:cell/t:bibl/@corresp">
                    <xsl:copy-of select="$call-modal"/>
                </xsl:when>
                <xsl:when test="@ana = 'prov:subscription' and ./t:cell/t:bibl/@corresp">
                    <xsl:copy-of select="$call-modal"/>
                </xsl:when>
                <xsl:when test="@ana = 'prov:sold' and ./t:cell/t:bibl/@corresp">
                    <xsl:copy-of select="$call-modal"/>
                </xsl:when>
                <xsl:when test="@ana = 'prov:move-changeId' and ./t:cell/t:bibl/@corresp">
                    <xsl:copy-of select="$call-modal"/>
                </xsl:when>
                <xsl:when test="@ana = 'prov:donation' and ./t:cell/t:bibl/@corresp">
                    <xsl:copy-of select="$call-modal"/>
                </xsl:when>
            </xsl:choose>
        </tr>
    </xsl:template>



    <!-- Gaps -->
    <xsl:template match="t:gap[@reason = 'deleted']">
        <xsl:text>##deletion##</xsl:text>
        <xsl:apply-templates/>
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

    <!-- notes -->
    <xsl:template match="t:note">
        <span title="{.}" style="color:red">*</span>
    </xsl:template>
    <!-- choice for abbreviations -->
    <xsl:template match="t:choice">
        <abbr title="{t:expan}">
            <xsl:value-of select="t:abbr"/>
        </abbr>
    </xsl:template>
    <!-- choice for shelfmark normalisation -->
    <xsl:template match="t:ab[@type = 'shelfmark']/t:choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="t:reg"/>
    <!-- deletions -->
    <xsl:template match="t:del">
        <s>
            <xsl:apply-templates/>
        </s>
    </xsl:template>

    <!-- item List -->
    <xsl:template match="t:list">
        <ul style="list-style-type:none;">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="t:item">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <!-- pagebreaks -->
    <xsl:template match="t:pb" name="pages">
        <xsl:variable name="pageId" select="./@xml:id"/>
        <div style="scroll-margin-top: 70px" class="page text-center text-muted mt-5 mb-3" level=""
            id="{$pageId}">
            <span class="pageNumber">
                <b>
                    <xsl:value-of select="./@xml:id"/>
                    <xsl:if test="./@n castable as xs:integer"> / Page <xsl:value-of select="./@n"
                        /></xsl:if>
                </b>
                <hr/>
            </span>
        </div>
    </xsl:template>

    <!-- page links -->
    <xsl:template match="t:ref">
        <xsl:variable name="refID" select="./@target"/>
        <a href="{$refID}">
            <xsl:apply-templates/>
        </a>

    </xsl:template>

    <!-- persons -->
    <xsl:template match="t:listPerson">
        <ul class="list-group">
            <xsl:apply-templates select="t:person">
                <xsl:sort select="t:persName"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>

    <xsl:template match="t:person">
        <xsl:variable name="persId" select="./@xml:id"/>
        <xsl:variable name="VIAF-ID" select="./t:idno[@type = 'VIAF']"/>
        <xsl:variable name="Wikidata-ID" select="./t:idno[@type = 'WikiData']"/>
        <xsl:variable name="CERL-ID" select="./t:idno[@type = 'CERL']"/>

        <li class="list-group-item" id="{$persId}">
            <xsl:value-of select="./t:persName"/>
            <xsl:if test="./t:idno/@type = 'VIAF'">; <a href="https://viaf.org/viaf/{$VIAF-ID}"
                    target="_blank">VIAF</a></xsl:if>
            <xsl:if test="./t:idno/@type = 'CERL'">; <a
                    href="https://data.cerl.org/thesaurus/{$CERL-ID}" target="_blank"
                >CERL</a></xsl:if>
            <xsl:if test="./t:idno/@type = 'WikiData'">; <a
                    href="https://www.wikidata.org/wiki/{$Wikidata-ID}" target="_blank"
                >Wikidata</a></xsl:if>
        </li>
    </xsl:template>

<!-- links to persons -->
    <xsl:template match="t:persName[@corresp]">
        <xsl:variable name="persRef" select="./@corresp"/>
        <a rel="noopener" href="persons.html{$persRef}" target="_blank">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
 



    <!-- about/fileDesc -->
    <xsl:template match="//t:fileDesc">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>
