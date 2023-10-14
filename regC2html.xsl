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
                <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
                <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
              
                <script type="text/javascript">
                    <![CDATA[
    function openModal(target) {
      console.log('Opening modal for ' + target);

      // Create a URL for the XML data file
      const xmlDataUrl = 'regC.xml';

      // Use jQuery to load the XML data
      $.ajax({
        type: 'GET',
        url: xmlDataUrl,
        dataType: 'xml',
        success: function(xmlData) {
          console.log('XML Data:', xmlData);

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
                <p>The edition most likely is the following:</p>
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

    <!-- Dealing with rows -->
    <!-- General styling of rows -->
    <xsl:template match="t:row">
        <tr>
            <xsl:apply-templates select="t:cell"/>
            <xsl:choose>
                <xsl:when test="@ana = 'prov:purchase'">
                    <td style="width:5%">
                        <!-- Modal -->
                        <div class="modal fade" id="myModal" role="dialog">
                            <div class="modal-dialog">
                                <!-- Modal content -->
                                <div class="modal-content">
                                    <div class="modal-header">
                                       <h4 class="modal-title" id="modal-title"></h4>
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
                        <xsl:variable name="target" select="t:cell/t:ptr/@target"/>
                        <button type="button" class="btn btn-light" onclick="openModal('{$target}')">Details</button>

                        
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
    
    <!-- notes -->
   <xsl:template match="t:note">
       <span title="{.}" style="color:red">*</span>
   </xsl:template>
    <!-- choice for abbreviations -->
    <xsl:template match="t:choice">
        <span title="{t:expan}">
            <u style="text-decoration:underline dotted"><xsl:value-of select="t:abbr"/></u>
        </span>
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
            <xsl:apply-templates></xsl:apply-templates>
        </li>
    </xsl:template>
    <!-- pagebreaks -->
    <xsl:template match="t:pb">
        <xsl:variable name="pageId" select="./@xml:id"/>
        <div class="page text-center text-muted mt-5 mb-3" level="" id="{$pageId}">
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
    

</xsl:stylesheet>
