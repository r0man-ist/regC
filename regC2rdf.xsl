<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:prov="URI##prov"
    xmlns:regC="https:r0man-ist.github.io/regC/" xmlns:foaf="http://xmlns.com/foaf/spec/"
    xmlns:dcterms="http://purl.org/dc/terms">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>


    <xsl:template match="/">


        <rdf:RDF>
            <crm:E31_Document>
                <xsl:attribute name="rdf:about">https:r0man-ist.github.io/regC</xsl:attribute>

                <!-- purchases -->
                <xsl:for-each select="//t:row[@ana = 'prov:purchase']">
                    <xsl:variable name="count_purchase" select="position()"/>
                    <crm:P70_documents>
                        <crm:E96_Purchase>
                            <!-- Change of Ownership -->
                            <!-- basic counter for IDs and URI -->
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https:r0man-ist.github.io/regC#P', $count_purchase)"
                                />
                            </xsl:attribute>
                            <!-- buyer -->
                            <crm:P22_transferred_title_to>
                                <crm:E74_Group rdf:about="http://viaf.org/viaf/129788129">
                                    <foaf:name>Bodleian Library</foaf:name>
                                </crm:E74_Group>
                            </crm:P22_transferred_title_to>
                            <!-- seller -->
                            <!-- check if there is a seller -->
                            <xsl:if test="./ancestor::t:ab/t:persName[@ana = 'prov:seller']">
                                <!-- get xml:id for seller -->
                                <xsl:variable name="seller-ID"
                                    select="./ancestor::t:ab/t:persName[@ana = 'prov:seller']/@corresp"/>

                                <crm:P23_transferred_title_from>
                                    <crm:E42_Actor>
                                        <xsl:attribute name="rdf:about">
                                            <!-- TODO: Alternative for Authority files!!! -->
                                            <xsl:value-of
                                                select="concat('ADRESS_AUTHORITY', //t:listPerson/t:person[@xml:id = substring-after($seller-ID, '#')]/t:idno[@type = 'CERL'])"
                                            />
                                        </xsl:attribute>
                                        <foaf:name>
                                            <xsl:value-of
                                                select="//t:listPerson/t:person[@xml:id = substring-after($seller-ID, '#')]/t:persName"
                                            />
                                        </foaf:name>
                                    </crm:E42_Actor>
                                </crm:P23_transferred_title_from>
                            </xsl:if>
                            <!-- check if there are associated items -->
                            <xsl:if test="./descendant::t:bibl[@corresp]">
                                <xsl:for-each select="./descendant::t:bibl">
                                    <xsl:variable name="count_item" select="position()"/>
                                    <xsl:variable name="item_ID" select="./@corresp"/>
                                    <crm:P24_transferred_title_of>
                                        <prov:Item>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                  select="concat('https:r0man-ist.github.io/regC/#P', $count_purchase, '-I', $count_item)"
                                                />
                                            </xsl:attribute>
                                            <dcterms:title>
                                                <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title"
                                                />
                                            </dcterms:title>
                                            <dcterms:creator>
                                                <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                />
                                            </dcterms:creator>
                                            <!-- current shelfmark -->
                                            <xsl:if
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:objectIdentifier/t:idno[@type = 'shelfmark']">
                                                <crm:P48_has_preferred_identifier>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:objectIdentifier/t:idno[@type = 'shelfmark']"
                                                  />
                                                </crm:P48_has_preferred_identifier>
                                            </xsl:if>
                                            <!-- Check if authority-statement for work exists -->
                                            <xsl:if
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:ref">
                                                <prov:instance_of rdf:resource="testwork-URI">
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:ref"
                                                  />
                                                  </xsl:attribute>
                                                </prov:instance_of>
                                            </xsl:if>
                                        </prov:Item>
                                    </crm:P24_transferred_title_of>
                                    <!-- Price -->
                                    <xsl:if test="./../following-sibling::t:cell/t:measure">
                                        <crm:P119_had_sales_price>
                                            <crm:E97_Monetary_Amount>
                                                <crm:P180_has_currency>Pound</crm:P180_has_currency>
                                                <crm:P90_has_value>
                                                  <xsl:value-of
                                                  select="./../following-sibling::t:cell/t:measure[@unit = 'pound']/@quantity"
                                                  />-<xsl:value-of
                                                  select="./../following-sibling::t:cell/t:measure[@unit = 'shilling']/@quantity"
                                                  />-<xsl:value-of
                                                  select="./../following-sibling::t:cell/t:measure[@unit = 'pence']/@quantity"
                                                  /></crm:P90_has_value>
                                            </crm:E97_Monetary_Amount>
                                        </crm:P119_had_sales_price>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:if>

                        </crm:E96_Purchase>
                    </crm:P70_documents>
                </xsl:for-each>


                <!-- ID-Assignment -->
                <xsl:for-each select="//t:row[@ana = 'prov:purchase']">
                    <xsl:variable name="count_purchase" select="position()"/>
                    <xsl:if test="./descendant::t:ab[@type = 'shelfmark']">
                        <xsl:for-each select="./descendant::t:bibl">
                            <xsl:variable name="count_item" select="position()"/>
                            <xsl:variable name="item_ID" select="./@corresp"/>
                            <crm:P70_documents>
                                <crm:E15_Identifier_Assignment>
                                    <xsl:attribute name="rdf:about">
                                        <xsl:value-of
                                            select="concat('https:r0man-ist.github.io/regC/#P-ID', $count_purchase)"
                                        />
                                    </xsl:attribute>
                                    <crm:P140_assigned_identifier_to>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('https:r0man-ist.github.io/regC/#P', $count_purchase, '-I', $count_item)"
                                            />
                                        </xsl:attribute>
                                    </crm:P140_assigned_identifier_to>
                                    <crm:P37_assigned>
                                        <crm:E42_Identifier>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                  select="concat('https:r0man-ist.github.io/regC#M', $count_purchase, '-I', $count_item, '-ID')"
                                                />
                                            </xsl:attribute>
                                            <crm:P90_has_value>
                                                <xsl:value-of
                                                  select="./../../descendant::t:ab[@type = 'shelfmark']/t:choice/t:reg"
                                                />
                                            </crm:P90_has_value>
                                        </crm:E42_Identifier>
                                    </crm:P37_assigned>
                                </crm:E15_Identifier_Assignment>
                            </crm:P70_documents>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:for-each>
                <!-- End loop Purchases -->

                <!-- MOVE/CHANGE-ID -->

                <xsl:for-each select="//t:row[@ana = 'prov:move-changeId']">
                    <xsl:variable name="count_move" select="position()"/>
                    <crm:P70_documents>
                        <crm:E15_Identifier_Assignment>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https:r0man-ist.github.io/regC#M', $count_move)"
                                />
                            </xsl:attribute>
                            <xsl:if test="./descendant::t:bibl[@corresp]">
                                <xsl:for-each select="./descendant::t:bibl">
                                    <xsl:variable name="count_item" select="position()"/>
                                    <xsl:variable name="item_ID" select="./@corresp"/>

                                    <crm:P140_assigned_identifier_to>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('https:r0man-ist.github.io/regC#M', $count_move, '-I', $count_item)"
                                            />
                                        </xsl:attribute>
                                    </crm:P140_assigned_identifier_to>

                                    <crm:P37_assigned>
                                        <crm:E42_Identifier>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                  select="concat('https:r0man-ist.github.io/regC#M', $count_move, '-I', $count_item, '-ID1')"
                                                />
                                            </xsl:attribute>
                                            <crm:P90_has_value>
                                                <xsl:value-of
                                                  select="./../../descendant::t:ab[@type = 'shelfmark'][1]/t:choice/t:reg"
                                                />
                                            </crm:P90_has_value>
                                        </crm:E42_Identifier>
                                    </crm:P37_assigned>
                                    <crm:P38_deassigned>
                                        <crm:E42_Identifier>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                  select="concat('https:r0man-ist.github.io/regC#M', $count_move, '-I', $count_item, '-ID2')"
                                                />
                                            </xsl:attribute>
                                            <crm:P90_has_value>
                                                <xsl:value-of
                                                  select="./../../descendant::t:ab[@type = 'shelfmark'][2]/t:choice/t:reg"
                                                />
                                            </crm:P90_has_value>
                                        </crm:E42_Identifier>
                                    </crm:P38_deassigned>
                                </xsl:for-each>
                            </xsl:if>
                        </crm:E15_Identifier_Assignment>
                    </crm:P70_documents>
                </xsl:for-each>
                <!-- End loop Move-Change-ID -->

                <!-- Deposit -->
                <xsl:for-each select="//t:row[@ana = 'prov:deposit']"> 
                    <xsl:variable name="count_deposit" select="position()"/>
                    <crm:P70_documents>
                        <prov:Legal_Deposit>
                            <!-- Change of Ownership -->
                            <!-- basic counter for IDs and URI -->
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https:r0man-ist.github.io/regC#Dep', $count_deposit)"
                                />
                            </xsl:attribute>
                            <!-- acquirer -->
                            <crm:P22_transferred_title_to>
                                <crm:E74_Group rdf:about="http://viaf.org/viaf/129788129">
                                    <foaf:name>Bodleian Library</foaf:name>
                                </crm:E74_Group>
                            </crm:P22_transferred_title_to>
                            <crm:P23_transferred_title_from>
                                <crm:E74_Group rdf:about="https://viaf.org/viaf/122574378">
                                    <foaf:name>Stationers' Company London</foaf:name>
                                </crm:E74_Group>
                                </crm:P23_transferred_title_from>
                            <!-- check if there are associated items -->
                            <xsl:if test="./descendant::t:bibl[@corresp]">
                                <xsl:for-each select="./descendant::t:bibl">
                                    <xsl:variable name="count_item" select="position()"/>
                                    <xsl:variable name="item_ID" select="./@corresp"/>
                                    <crm:P24_transferred_title_of>
                                        <prov:Item>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                    select="concat('https:r0man-ist.github.io/regC/#Dep', $count_deposit, '-I', $count_item)"
                                                />
                                            </xsl:attribute>
                                            <dcterms:title>
                                                <xsl:value-of
                                                    select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title"
                                                />
                                            </dcterms:title>
                                            <dcterms:creator>
                                                <xsl:value-of
                                                    select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                />
                                            </dcterms:creator>
                                            <!-- current shelfmark -->
                                            <xsl:if
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:objectIdentifier/t:idno[@type = 'shelfmark']">
                                                <crm:P48_has_preferred_identifier>
                                                    <xsl:value-of
                                                        select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:objectIdentifier/t:idno[@type = 'shelfmark']"
                                                    />
                                                </crm:P48_has_preferred_identifier>
                                            </xsl:if>
                                            <!-- Check if authority-statement for work exists -->
                                            <xsl:if
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:ref">
                                                <prov:instance_of rdf:resource="testwork-URI">
                                                    <xsl:attribute name="rdf:resource">
                                                        <xsl:value-of
                                                            select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:ref"
                                                        />
                                                    </xsl:attribute>
                                                </prov:instance_of>
                                            </xsl:if>
                                        </prov:Item>
                                    </crm:P24_transferred_title_of>
                                </xsl:for-each>
                            </xsl:if>
                        </prov:Legal_Deposit>
                    </crm:P70_documents>
                </xsl:for-each>

                <!-- End loop Deposit -->



                <!-- Donation -->
                <xsl:for-each select="//t:row[@ana = 'prov:donation']">
                    <xsl:variable name="count_donation" select="position()"/>
                    <crm:P70_documents>
                        <prov:Donation>
                            <!-- Change of Ownership -->
                            <!-- basic counter for IDs and URI -->
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https:r0man-ist.github.io/regC#D', $count_donation)"
                                />
                            </xsl:attribute>
                            <!-- acquirer -->
                            <crm:P22_transferred_title_to>
                                <crm:E74_Group rdf:about="http://viaf.org/viaf/129788129">
                                    <foaf:name>Bodleian Library</foaf:name>
                                </crm:E74_Group>
                            </crm:P22_transferred_title_to>
                            <!-- donor -->
                            <!-- check if there is a donor -->
                            <xsl:if test="./descendant::t:persName[@ana = 'prov:donor']">
                                <!-- get xml:id for donor -->
                                <xsl:variable name="donor-ID"
                                    select="./descendant::t:persName[@ana = 'prov:donor']/@corresp"/>

                                <crm:P23_transferred_title_from>
                                    <prov:Donor>
                                        <xsl:attribute name="rdf:about">
                                            <xsl:value-of
                                                select="concat('ADRESS_AUTHORITY', //t:listPerson/t:person[@xml:id = substring-after($donor-ID, '#')]/t:idno[@type = 'CERL'])"
                                            />
                                        </xsl:attribute>
                                        <foaf:name>
                                            <xsl:value-of
                                                select="//t:listPerson/t:person[@xml:id = substring-after($donor-ID, '#')]/t:persName"
                                            />
                                        </foaf:name>
                                    </prov:Donor>
                                </crm:P23_transferred_title_from>
                            </xsl:if>
                            <!-- check if there are associated items -->
                            <xsl:if test="./descendant::t:bibl[@corresp]">
                                <xsl:for-each select="./descendant::t:bibl">
                                    <xsl:variable name="count_item" select="position()"/>
                                    <xsl:variable name="item_ID" select="./@corresp"/>
                                    <crm:P24_transferred_title_of>
                                        <prov:Item>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                  select="concat('https:r0man-ist.github.io/regC/#D', $count_donation, '-I', $count_item)"
                                                />
                                            </xsl:attribute>
                                            <dcterms:title>
                                                <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title"
                                                />
                                            </dcterms:title>
                                            <dcterms:creator>
                                                <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                />
                                            </dcterms:creator>
                                            <!-- current shelfmark -->
                                            <xsl:if
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:objectIdentifier/t:idno[@type = 'shelfmark']">
                                                <crm:P48_has_preferred_identifier>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:objectIdentifier/t:idno[@type = 'shelfmark']"
                                                  />
                                                </crm:P48_has_preferred_identifier>
                                            </xsl:if>
                                            <!-- Check if authority-statement for work exists -->
                                            <xsl:if
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:ref">
                                                <prov:instance_of rdf:resource="testwork-URI">
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:ref"
                                                  />
                                                  </xsl:attribute>
                                                </prov:instance_of>
                                            </xsl:if>
                                        </prov:Item>
                                    </crm:P24_transferred_title_of>
                                </xsl:for-each>
                            </xsl:if>
                        </prov:Donation>
                    </crm:P70_documents>
                </xsl:for-each>
                <!-- End loop Donation -->


            </crm:E31_Document>
        </rdf:RDF>
    </xsl:template>
</xsl:stylesheet>
<!--

<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
    xmlns:lrm="http://iflastandards.info/ns/lrm/lrmoo/"
    xmlns:prov="URI##prov"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:dcterms="http://purl.org/dc/terms"
    xmlns:foaf="http://xmlns.com/foaf/spec/">
    <crm:E31_Document rdf:about="RegC">
        <crm:P70_documents>
            <crm:E96_Purchase rdf:about="Activity_ID">
                <crm:P22_transferred_title_to>
                    <crm:E42_Actor rdf:about="viaf_ID">
                        <foaf:name>NAME</foaf:name>
                    </crm:E42_Actor>
                </crm:P22_transferred_title_to>
                
                <crm:P23_transferred_title_from>
                    <crm:Agent rdf:about="testseller">
                        <foaf:name>NAME</foaf:name>
                        <foaf:id rdf:resource="viaf.com"></foaf:id>
                    </crm:Agent>
                </crm:P23_transferred_title_from>
                <crm:P24_transferred_title_of>
                    <prov:Item rdf:about="testitem">
                        <dcterms:title>TESTTITLE</dcterms:title>
                        <dcterms:creator>TESTCREATOR</dcterms:creator>
                        <prov:instance_of rdf:resource="testwork-URI"></prov:instance_of>
                        <crm:P48_has_preferred_identifier>FF 42 Jur.</crm:P48_has_preferred_identifier>
                    </prov:Item>
                </crm:P24_transferred_title_of>
                <crm:P174_starts_before_the_end_of>1720-11-08</crm:P174_starts_before_the_end_of>
                <crm:P174i_ends_after_the_start_of>1721-11-09</crm:P174i_ends_after_the_start_of>
                <crm:P179_had_sales_price>
                    <crm:Monetary_Amount>
                        <crm:P180_has_currency>Pound</crm:P180_has_currency>
                        <crm:P90_has_value>1-8-5</crm:P90_has_value>
                    </crm:Monetary_Amount>
                </crm:P179_had_sales_price>
            </crm:E96_Purchase>
        </crm:P70_documents>
        <crm:P70_documents>
            <crm:E15_Identifier_Asignment rdf:about="Activity_ID2">
                <crm:P140_assigned_identifier_to rdf:resource="testitem"></crm:P140_assigned_identifier_to>
                <crm:E42_Identifier>FF 42 Jur.</crm:E42_Identifier>
                <crm:P174_starts_before_the_end_of>1720-11-08</crm:P174_starts_before_the_end_of>
                <crm:P174i_ends_after_the_start_of>1721-11-09</crm:P174i_ends_after_the_start_of>
            </crm:E15_Identifier_Asignment>
        </crm:P70_documents>
    </crm:E31_Document>
    <crm:P22_transferred_title_to rdf:resource="http://viaf.org/viaf/129788129"/>
    <prov:has_timespan>
        <prov:Timespan rdf:about="regC#d2e7792">
            <prov:has_beginning/>
            <prov:has_end/>
        </prov:Timespan>
    </prov:has_timespan>
    <prov:has_price>
        <prov:Monetary_Amount rdf:about="regC#d2e7792">
            <prov:has_currency>https://www.wikidata.org/wiki/Q25224</prov:has_currency>
            <prov:has_unit>3-3-0</prov:has_unit>
        </prov:Monetary_Amount>
    </prov:has_price>
    <crm:P24_transferred_title_of>
        <lrm:F5_Item>
            <crm:P48_has_preferred_identifier/>
            <lrm:R7_exemplifies>
                <lrm:F3_Manifestation>
                    <crm:P102_has_title>Voyages de Corneille Le Brun par la Moscovie, en Perse, et aux Indes Orientales. : Ouvrage enrichi de plus de 320 tailles douces ... On y a ajoûté la route qu'a suivie Mr. Isbrants, ambassadeur de Moscovie, en traversant la Russie &amp; la Tartarie, pour se rendre à la Chine. Et quelques remarques contre Mrs. Chardin &amp; Kempfer. Avec une lettre écrite à l'auteur, sur ce sujet..</crm:P102_has_title>
                </lrm:F3_Manifestation>
            </lrm:R7_exemplifies>
        </lrm:F5_Item>
    </crm:P24_transferred_title_of>
    </crm:E31_Document>
    <prov:Purchase rdf:about="prov:ID">
        <crm:P22_transferred_title_to rdf:resource="http://viaf.org/viaf/129788129"/>
        <prov:has_timespan>
            <prov:Timespan rdf:about="regC#d2e8195">
                <prov:has_beginning>1719-11-09</prov:has_beginning>
                <prov:has_end>1720-11-08</prov:has_end>
            </prov:Timespan>
        </prov:has_timespan>
        <prov:has_price>
            <prov:Monetary_Amount rdf:about="regC#d2e8195">
                <prov:has_currency>https://www.wikidata.org/wiki/Q25224</prov:has_currency>
                <prov:has_unit>0-12-6</prov:has_unit>
            </prov:Monetary_Amount>
        </prov:has_price>
        <crm:P24_transferred_title_of>
            <lrm:F5_Item>
                <crm:P48_has_preferred_identifier>C 16.13 Th.</crm:P48_has_preferred_identifier>
                <lrm:R7_exemplifies>
                    <lrm:F3_Manifestation>
                        <crm:P102_has_title>A rational illustration of the Book of Common Prayer, : and administration of the sacraments, and other rites and ceremonies of the Church, according to the use of the Church of England. Wherein liturgies in general are proved lawful and necessary, and an historical account is given of our own: the several tables, rules, and kalendar are consider'd, and the seeming differences reconcil'd: all the rubricks, prayers, rites, and ceremonies are explained, and compared with the liturgies of the Primitive Church: the exact method and harmony of every office is shew'd, and all the material alterations are observ'd, which have at any time been made since the first common-prayer-book of King Edward VI. with the particular reasons that occasion'd them. The whole being the substance of every thing material in all former ritualists comentators or others, upon the same subject; collected and reduc'd into one continued and regular method, and interspersed all along with new observations. /</crm:P102_has_title>
                    </lrm:F3_Manifestation>
                </lrm:R7_exemplifies>
            </lrm:F5_Item>
        </crm:P24_transferred_title_of>
    </prov:Purchase>
    <prov:Purchase rdf:about="prov:ID">
        <crm:P22_transferred_title_to rdf:resource="http://viaf.org/viaf/129788129"/>
        <prov:has_timespan>
            <prov:Timespan rdf:about="regC#d2e8396">
                <prov:has_beginning>1719-11-09</prov:has_beginning>
                <prov:has_end>1720-11-08</prov:has_end>
            </prov:Timespan>
        </prov:has_timespan>
        <prov:has_price>
            <prov:Monetary_Amount rdf:about="regC#d2e8396">
                <prov:has_currency>https://www.wikidata.org/wiki/Q25224</prov:has_currency>
                <prov:has_unit>0-0-6</prov:has_unit>
            </prov:Monetary_Amount>
        </prov:has_price>
        <crm:P24_transferred_title_of>
            <lrm:F5_Item>
                <crm:P48_has_preferred_identifier>8° M 236(2) Th.</crm:P48_has_preferred_identifier>
                <lrm:R7_exemplifies>
                    <lrm:F3_Manifestation>
                        <crm:P102_has_title>A true account of the present state of Trinity college in Cambridge, under the oppressive government of ... Richard Bentley [by C. Middleton.].</crm:P102_has_title>
                    </lrm:F3_Manifestation>
                </lrm:R7_exemplifies>
            </lrm:F5_Item>
        </crm:P24_transferred_title_of>
    </prov:Purchase>
    -->
