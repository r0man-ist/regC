<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:dcterms="http://purl.org/dc/terms"
    xmlns:prov="https:r0man-ist.github.io/regC#prov"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:t="http://www.tei-c.org/ns/1.0">
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
                                    <rdfs:label>Bodleian Library</rdfs:label>
                                </crm:E74_Group>
                            </crm:P22_transferred_title_to>
                            <!-- seller -->
                            <!-- check if there is a seller -->
                            <xsl:if
                                test="./ancestor::t:ab[@ana = 'prov']/t:persName[@ana = 'prov:seller'] or ./descendant::t:ab[@ana = 'prov']/t:persName[@ana = 'prov:seller']">
                                <!-- get xml:id for seller -->
                                <xsl:variable name="seller-ID"
                                    select="./ancestor::t:ab[@ana = 'prov']/t:persName[@ana = 'prov:seller']/@corresp | ./descendant::t:ab[@ana = 'prov']/t:persName[@ana = 'prov:seller']/@corresp"/>

                                <crm:P23_transferred_title_from>
                                    <crm:E39_Actor>
                                        <xsl:attribute name="rdf:about">
                                            <!-- Authority statements in Order VIAF > Wikidata> CERL -->
                                            <xsl:choose>
                                                <xsl:when
                                                  test="//t:listPerson/t:person[@xml:id = substring-after($seller-ID, '#')]/t:idno[@type = 'VIAF']">
                                                  <xsl:value-of
                                                  select="concat('https://viaf.org/viaf/', //t:listPerson/t:person[@xml:id = substring-after($seller-ID, '#')]/t:idno[@type = 'VIAF'])"
                                                  />
                                                </xsl:when>
                                                <xsl:when
                                                  test="//t:listPerson/t:person[@xml:id = substring-after($seller-ID, '#')]/t:idno[@type = 'WikiData']">
                                                  <xsl:value-of
                                                  select="concat('https://www.wikidata.org/wiki/', //t:listPerson/t:person[@xml:id = substring-after($seller-ID, '#')]/t:idno[@type = 'WikiData'])"
                                                  />
                                                </xsl:when>
                                                <xsl:when
                                                  test="//t:listPerson/t:person[@xml:id = substring-after($seller-ID, '#')]/t:idno[@type = 'CERL']">
                                                  <xsl:value-of
                                                  select="concat('https://data.cerl.org/thesaurus/', //t:listPerson/t:person[@xml:id = substring-after($seller-ID, '#')]/t:idno[@type = 'CERL'])"
                                                  />
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        <rdfs:label>
                                            <xsl:value-of
                                                select="//t:listPerson/t:person[@xml:id = substring-after($seller-ID, '#')]/t:persName"
                                            />
                                        </rdfs:label>
                                    </crm:E39_Actor>
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
                                                  select="concat('https:r0man-ist.github.io/regC#P', $count_purchase, '-I', $count_item)"
                                                />
                                            </xsl:attribute>
                                            <dcterms:title>
                                                <xsl:value-of
                                                  select="normalize-space(//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title)"
                                                />
                                            </dcterms:title>
                                            <!-- Creator -->
                                            
                                            <xsl:if test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]"><dcterms:creator>
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                                                  <crm:E21_Person>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author/@ref"
                                                  />
                                                  </xsl:attribute>
                                                  <rdfs:label>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                  />
                                                  </rdfs:label>
                                                  </crm:E21_Person>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                  />
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </dcterms:creator></xsl:if>
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
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title[@ref]">
                                                <dcterms:isVersionOf>
                                                  <xsl:attribute name="rdf:resource">
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title/@ref"
                                                  />
                                                  </xsl:attribute>
                                                </dcterms:isVersionOf>
                                            </xsl:if>
                                        </prov:Item>
                                    </crm:P24_transferred_title_of>
                                </xsl:for-each>
                                    <!-- Price -->
                                    <xsl:if test="./descendant::t:cell/t:measure">
                                        <crm:P119_had_sales_price>
                                            <crm:E97_Monetary_Amount>
                                                <crm:P180_has_currency>Pound</crm:P180_has_currency>
                                                <crm:P90_has_value>
                                                  <xsl:value-of
                                                      select="./descendant::t:cell/t:measure[@unit = 'pound']/@quantity"
                                                  />-<xsl:value-of
                                                      select="./descendant::t:cell/t:measure[@unit = 'shilling']/@quantity"
                                                  />-<xsl:value-of
                                                      select="./descendant::t:cell/t:measure[@unit = 'pence']/@quantity"
                                                  /></crm:P90_has_value>
                                            </crm:E97_Monetary_Amount>
                                        </crm:P119_had_sales_price>
                                    </xsl:if>
                                
                            </xsl:if>
                            <!-- time -->
                            <crm:P4_has_time_span>
                                <crm:E61_Time_Primitive>
                                    <!-- determine whether time is specified in ancestor or descendant element -->
                                    <xsl:choose>
                                        <xsl:when
                                            test="./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]">
                                            <crm:P82a_begin_of_the_begin
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">

                                                <xsl:value-of
                                                  select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/@notBefore, 'T00:00:00')"
                                                />
                                            </crm:P82a_begin_of_the_begin>
                                            <crm:P82b_end_of_the_end
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                                <xsl:value-of
                                                  select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/@notAfter, 'T23:59:59')"/>

                                            </crm:P82b_end_of_the_end>
                                        </xsl:when>
                                        <xsl:when
                                            test="./descendant::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]">
                                            <crm:P82a_begin_of_the_begin
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">

                                                <xsl:value-of
                                                  select="concat(./descendant::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/@notBefore, 'T00:00:00')"
                                                />
                                            </crm:P82a_begin_of_the_begin>
                                            <crm:P82b_end_of_the_end
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                                <xsl:value-of
                                                  select="concat(./descendant::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/@notAfter, 'T23:59:59')"/>

                                            </crm:P82b_end_of_the_end>
                                        </xsl:when>
                                    </xsl:choose>
                                </crm:E61_Time_Primitive>
                            </crm:P4_has_time_span>
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
                                            select="concat('https:r0man-ist.github.io/regC#P-ID', $count_purchase)"
                                        />
                                    </xsl:attribute>
                                    <crm:P140_assigned_attribute_to>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('https:r0man-ist.github.io/regC#P', $count_purchase, '-I', $count_item)"
                                            />
                                        </xsl:attribute>
                                    </crm:P140_assigned_attribute_to>
                                    <crm:P37_assigned>
                                        <crm:E42_Identifier>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                  select="concat('https:r0man-ist.github.io/regC#P', $count_purchase, '-I', $count_item, '-ID')"
                                                />
                                            </xsl:attribute>
                                            <crm:P90_has_value>
                                                <xsl:value-of
                                                  select="./../../descendant::t:ab[@type = 'shelfmark']/t:choice/t:reg"
                                                />
                                            </crm:P90_has_value>
                                        </crm:E42_Identifier>
                                    </crm:P37_assigned>
                                    <crm:P4_has_time_span>
                                        <crm:E61_Time_Primitive>
                                            <crm:P82a_begin_of_the_begin
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                                <xsl:value-of
                                                  select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:purchase')]/@notBefore | @when | ./preceding-sibling::t:date[@type = 'prov:ID-Assignment']/@notBefore | @when, 'T00:00:00')"
                                                />
                                            </crm:P82a_begin_of_the_begin>
                                            <crm:P82b_end_of_the_end
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                                <xsl:value-of
                                                  select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:purchase')]/@notAfter | @when | ./preceding-sibling::t:date[@type = 'prov:ID-Assignment']/@notAfter | @when, 'T23:59:59')"
                                                />
                                            </crm:P82b_end_of_the_end>
                                        </crm:E61_Time_Primitive>
                                    </crm:P4_has_time_span>
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
                            <crm:P37_assigned>
                                <crm:E42_Identifier>
                                    <xsl:attribute name="rdf:about">
                                        <xsl:value-of
                                            select="concat('https:r0man-ist.github.io/regC#M', $count_move, '-ID1')"
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
                                            select="concat('https:r0man-ist.github.io/regC#M', $count_move, '-ID1')"
                                        />
                                    </xsl:attribute>
                                    <crm:P90_has_value>
                                        <xsl:value-of
                                            select="./../../descendant::t:ab[@type = 'shelfmark'][2]/t:choice/t:reg"
                                        />
                                    </crm:P90_has_value>
                                </crm:E42_Identifier>
                            </crm:P38_deassigned>
                            <xsl:if test="./descendant::t:bibl[@corresp]">
                                
                                
                                
                                <xsl:for-each select="./descendant::t:bibl">
                                    <xsl:variable name="count_item" select="position()"/>
                                    <xsl:variable name="item_ID" select="./@corresp"/>

                                    <crm:P140_assigned_attribute_to>
                                        
                                        <prov:Item>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                    select="concat('https:r0man-ist.github.io/regC#P', $count_move, '-I', $count_item)"
                                                />
                                            </xsl:attribute>
                                            <dcterms:title>
                                                <xsl:value-of
                                                    select="normalize-space(//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title)"
                                                />
                                            </dcterms:title>
                                            <!-- Creator -->
                                            
                                            <xsl:if test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]"><dcterms:creator>
                                                <xsl:choose>
                                                    <xsl:when
                                                        test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                                                        <crm:E21_Person>
                                                            <xsl:attribute name="rdf:about">
                                                                <xsl:value-of
                                                                    select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author/@ref"
                                                                />
                                                            </xsl:attribute>
                                                            <rdfs:label>
                                                                <xsl:value-of
                                                                    select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                                />
                                                            </rdfs:label>
                                                        </crm:E21_Person>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of
                                                            select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                        />
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </dcterms:creator></xsl:if>
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
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title[@ref]">
                                                <dcterms:isVersionOf>
                                                    <xsl:attribute name="rdf:resource">
                                                        <xsl:value-of
                                                            select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title/@ref"
                                                        />
                                                    </xsl:attribute>
                                                </dcterms:isVersionOf>
                                            </xsl:if>
                                        </prov:Item>
                                    </crm:P140_assigned_attribute_to>

                                    
                                </xsl:for-each>
                            </xsl:if>
                            <crm:P4_has_time_span>
                                <crm:E61_Time_Primitive>
                                    <crm:P82a_begin_of_the_begin
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:value-of
                                            select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notBefore, 'T00:00:00')"
                                        />
                                    </crm:P82a_begin_of_the_begin>
                                    <crm:P82b_end_of_the_end
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:value-of
                                            select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notAfter, 'T23:59:59')"
                                        />
                                    </crm:P82b_end_of_the_end>
                                </crm:E61_Time_Primitive>
                            </crm:P4_has_time_span>
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
                                    <rdfs:label>Bodleian Library</rdfs:label>
                                </crm:E74_Group>
                            </crm:P22_transferred_title_to>
                            <crm:P23_transferred_title_from>
                                <crm:E74_Group rdf:about="https://viaf.org/viaf/122574378">
                                    <rdfs:label>Stationers' Company London</rdfs:label>
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
                                                  select="concat('https:r0man-ist.github.io/regC#Dep', $count_deposit, '-I', $count_item)"
                                                />
                                            </xsl:attribute>
                                            <dcterms:title>
                                                <xsl:value-of
                                                  select="normalize-space(//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title)"
                                                />
                                            </dcterms:title>
                                            <xsl:if
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                                                <dcterms:creator>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                                                  <crm:E21_Person>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author/@ref"
                                                  />
                                                  </xsl:attribute>
                                                  <rdfs:label>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                  />
                                                  </rdfs:label>
                                                  </crm:E21_Person>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                  />
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </dcterms:creator>
                                            </xsl:if>
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
                            <crm:P4_has_time_span>
                                <crm:E61_Time_Primitive>
                                    <crm:P82a_begin_of_the_begin
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:value-of
                                            select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notBefore, 'T00:00:00')"
                                        />
                                    </crm:P82a_begin_of_the_begin>
                                    <crm:P82b_end_of_the_end
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:value-of
                                            select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notAfter, 'T23:59:59')"
                                        />
                                    </crm:P82b_end_of_the_end>
                                </crm:E61_Time_Primitive>
                            </crm:P4_has_time_span>
                        </prov:Legal_Deposit>
                    </crm:P70_documents>
                </xsl:for-each>
                <!-- ID-Assignment -->
                <xsl:for-each select="//t:row[@ana = 'prov:deposit']">
                    <xsl:variable name="count_deposit" select="position()"/>
                    <xsl:if test="./descendant::t:ab[@type = 'shelfmark']">
                        <crm:P70_documents>
                            <crm:E15_Identifier_Assignment>
                                <xsl:attribute name="rdf:about">
                                    <xsl:value-of
                                        select="concat('https:r0man-ist.github.io/regC#Dep-ID', $count_deposit)"
                                    />
                                </xsl:attribute>
                                <xsl:for-each select="./descendant::t:bibl">
                                    <xsl:variable name="count_item" select="position()"/>
                                    <xsl:variable name="item_ID" select="./@corresp"/>


                                    <crm:P140_assigned_attribute_to>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('https:r0man-ist.github.io/regC#Dep', $count_deposit, '-I', $count_item)"
                                            />
                                        </xsl:attribute>
                                    </crm:P140_assigned_attribute_to>
                                    <crm:P37_assigned>
                                        <crm:E42_Identifier>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                  select="concat('https:r0man-ist.github.io/regC#Dep', $count_deposit, '-I', $count_item, '-ID')"
                                                />
                                            </xsl:attribute>
                                            <crm:P90_has_value>
                                                <xsl:value-of
                                                  select="./../../descendant::t:ab[@type = 'shelfmark']/t:choice/t:reg"
                                                />
                                            </crm:P90_has_value>
                                        </crm:E42_Identifier>
                                    </crm:P37_assigned>
                                </xsl:for-each>
                                <crm:P4_has_time_span>
                                    <crm:E61_Time_Primitive>
                                        <crm:P82a_begin_of_the_begin
                                            rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                            <xsl:value-of
                                                select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notBefore, 'T00:00:00')"
                                            />
                                        </crm:P82a_begin_of_the_begin>
                                        <crm:P82b_end_of_the_end
                                            rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                            <xsl:value-of
                                                select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notAfter, 'T23:59:59')"
                                            />
                                        </crm:P82b_end_of_the_end>
                                    </crm:E61_Time_Primitive>
                                </crm:P4_has_time_span>
                            </crm:E15_Identifier_Assignment>
                        </crm:P70_documents>
                    </xsl:if>
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
                                    <rdfs:label>Bodleian Library</rdfs:label>
                                </crm:E74_Group>
                            </crm:P22_transferred_title_to>
                            <!-- donor -->
                            <!-- check if there is an identified donor; else just put out blank node and label-->
                            <xsl:choose>
                                <xsl:when
                                    test="./descendant::t:persName[@ana = 'prov:donor' and not(@corresp)]">
                                    <crm:P23_transferred_title_from>
                                        <prov:Donor>
                                            <rdfs:label>
                                                <xsl:value-of
                                                  select="./t:persName[@ana = 'prov:donor']"/>
                                            </rdfs:label>
                                        </prov:Donor>
                                    </crm:P23_transferred_title_from>
                                </xsl:when>
                                <xsl:when
                                    test="./descendant::t:persName[@ana = 'prov:donor' and @corresp]">
                                    <!-- get xml:id for donor -->
                                    <xsl:variable name="donor-ID"
                                        select="./descendant::t:persName[@ana = 'prov:donor']/@corresp"/>

                                    <crm:P23_transferred_title_from>
                                        <prov:Donor>
                                            <xsl:attribute name="rdf:about">
                                                <!-- Alternative for Name Authority with priority to VIAF > WIKIDATA > CERL -->
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="//t:listPerson/t:person[@xml:id = substring-after($donor-ID, '#')]/t:idno[@type = 'VIAF']">
                                                  <xsl:value-of
                                                  select="concat('https://viaf.org/viaf/', //t:listPerson/t:person[@xml:id = substring-after($donor-ID, '#')]/t:idno[@type = 'VIAF'])"
                                                  />
                                                  </xsl:when>
                                                  <xsl:when
                                                  test="//t:listPerson/t:person[@xml:id = substring-after($donor-ID, '#')]/t:idno[@type = 'WikiData']">
                                                  <xsl:value-of
                                                  select="concat('https://www.wikidata.org/wiki/', //t:listPerson/t:person[@xml:id = substring-after($donor-ID, '#')]/t:idno[@type = 'WikiData'])"
                                                  />
                                                  </xsl:when>
                                                  <xsl:when
                                                  test="//t:listPerson/t:person[@xml:id = substring-after($donor-ID, '#')]/t:idno[@type = 'CERL']">
                                                  <xsl:value-of
                                                  select="concat('https://data.cerl.org/thesaurus/', //t:listPerson/t:person[@xml:id = substring-after($donor-ID, '#')]/t:idno[@type = 'CERL'])"
                                                  />
                                                  </xsl:when>
                                                </xsl:choose>
                                            </xsl:attribute>
                                            <rdfs:label>
                                                <xsl:value-of
                                                  select="//t:listPerson/t:person[@xml:id = substring-after($donor-ID, '#')]/t:persName"
                                                />
                                            </rdfs:label>
                                        </prov:Donor>
                                    </crm:P23_transferred_title_from>
                                </xsl:when>
                            </xsl:choose>
                            <!-- check if there are associated items -->
                            <xsl:if test="./descendant::t:bibl[@corresp]">
                                <xsl:for-each select="./descendant::t:bibl">
                                    <xsl:variable name="count_item" select="position()"/>
                                    <xsl:variable name="item_ID" select="./@corresp"/>
                                    <crm:P24_transferred_title_of>
                                        <prov:Item>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                  select="concat('https:r0man-ist.github.io/regC#D', $count_donation, '-I', $count_item)"
                                                />
                                            </xsl:attribute>
                                            <dcterms:title>
                                                <xsl:value-of
                                                  select="normalize-space(//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title)"
                                                />
                                            </dcterms:title>
                                            <xsl:if
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                                                <dcterms:creator>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                                                  <crm:E21_Person>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author/@ref"
                                                  />
                                                  </xsl:attribute>
                                                  <rdfs:label>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                  />
                                                  </rdfs:label>
                                                  </crm:E21_Person>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                  />
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </dcterms:creator>
                                            </xsl:if>
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
                            <crm:P4_has_time_span>
                                <crm:E61_Time_Primitive>
                                    <crm:P82a_begin_of_the_begin
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:value-of
                                            select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notBefore, 'T00:00:00')"
                                        />
                                    </crm:P82a_begin_of_the_begin>
                                    <crm:P82b_end_of_the_end
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:value-of
                                            select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notAfter, 'T23:59:59')"
                                        />
                                    </crm:P82b_end_of_the_end>
                                </crm:E61_Time_Primitive>
                            </crm:P4_has_time_span>
                        </prov:Donation>
                    </crm:P70_documents>
                </xsl:for-each>
                <!-- ID-Assignment -->
                <xsl:for-each select="//t:row[@ana = 'prov:donation']">
                    <xsl:variable name="count_donation" select="position()"/>
                    <xsl:if test="./descendant::t:ab[@type = 'shelfmark']">
                        <crm:P70_documents>
                            <crm:E15_Identifier_Assignment>
                                <xsl:attribute name="rdf:about">
                                    <xsl:value-of
                                        select="concat('https:r0man-ist.github.io/regC#D-ID', $count_donation)"
                                    />
                                </xsl:attribute>
                                <xsl:for-each select="./descendant::t:bibl">
                                    <xsl:variable name="count_item" select="position()"/>
                                    <xsl:variable name="item_ID" select="./@corresp"/>


                                    <crm:P140_assigned_attribute_to>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('https:r0man-ist.github.io/regC#D', $count_donation, '-I', $count_item)"
                                            />
                                        </xsl:attribute>
                                    </crm:P140_assigned_attribute_to>
                                    <crm:P37_assigned>
                                        <crm:E42_Identifier>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                  select="concat('https:r0man-ist.github.io/regC#D', $count_donation, '-I', $count_item, '-ID')"
                                                />
                                            </xsl:attribute>
                                            <crm:P90_has_value>
                                                <xsl:value-of
                                                  select="./../../descendant::t:ab[@type = 'shelfmark']/t:choice/t:reg"
                                                />
                                            </crm:P90_has_value>
                                        </crm:E42_Identifier>
                                    </crm:P37_assigned>
                                    <crm:P4_has_time_span>
                                        <crm:E61_Time_Primitive>
                                            <crm:P82a_begin_of_the_begin
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                                <xsl:value-of
                                                  select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notBefore, 'T00:00:00')"
                                                />
                                            </crm:P82a_begin_of_the_begin>
                                            <crm:P82b_end_of_the_end
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                                <xsl:value-of
                                                  select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notAfter, 'T23:59:59')"
                                                />
                                            </crm:P82b_end_of_the_end>
                                        </crm:E61_Time_Primitive>
                                    </crm:P4_has_time_span>
                                </xsl:for-each>
                            </crm:E15_Identifier_Assignment>
                        </crm:P70_documents>
                    </xsl:if>
                </xsl:for-each>

                <!-- End loop Donation -->

                <!-- sale -->
                <xsl:for-each select="//t:row[@ana = 'prov:sold']">
                    <xsl:variable name="count_sale" select="position()"/>
                    <crm:P70_documents>
                        <crm:E96_Purchase>
                            <!-- Change of Ownership -->
                            <!-- basic counter for IDs and URI -->
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https:r0man-ist.github.io/regC#S', $count_sale)"
                                />
                            </xsl:attribute>
                            <!-- seller -->
                            <crm:P23_transferred_title_from>
                                <crm:E74_Group rdf:about="http://viaf.org/viaf/129788129">
                                    <rdfs:label>Bodleian Library</rdfs:label>
                                </crm:E74_Group>
                            </crm:P23_transferred_title_from>
                            <!-- buyer -->
                            <!-- check if there is a buyer -->
                            <xsl:if test="./ancestor::t:ab/t:persName[@ana = 'prov:buyer']">
                                <!-- get xml:id for buyer -->
                                <xsl:variable name="buyer-ID"
                                    select="./ancestor::t:ab/t:persName[@ana = 'prov:buyer']/@corresp"/>

                                <crm:P22_transferred_title_to>
                                    <crm:E39_Actor>
                                        <xsl:attribute name="rdf:about">
                                            <!-- Alternative for Name Authority with priority to VIAF > WIKIDATA > CERL -->
                                            <xsl:choose>
                                                <xsl:when
                                                  test="//t:listPerson/t:person[@xml:id = substring-after($buyer-ID, '#')]/t:idno[@type = 'VIAF']">
                                                  <xsl:value-of
                                                  select="concat('https://viaf.org/viaf/', //t:listPerson/t:person[@xml:id = substring-after($buyer-ID, '#')]/t:idno[@type = 'VIAF'])"
                                                  />
                                                </xsl:when>
                                                <xsl:when
                                                  test="//t:listPerson/t:person[@xml:id = substring-after($buyer-ID, '#')]/t:idno[@type = 'WikiData']">
                                                  <xsl:value-of
                                                  select="concat('https://www.wikidata.org/wiki/', //t:listPerson/t:person[@xml:id = substring-after($buyer-ID, '#')]/t:idno[@type = 'WikiData'])"
                                                  />
                                                </xsl:when>
                                                <xsl:when
                                                  test="//t:listPerson/t:person[@xml:id = substring-after($buyer-ID, '#')]/t:idno[@type = 'CERL']">
                                                  <xsl:value-of
                                                  select="concat('https://data.cerl.org/thesaurus/', //t:listPerson/t:person[@xml:id = substring-after($buyer-ID, '#')]/t:idno[@type = 'CERL'])"
                                                  />
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        <rdfs:label>
                                            <xsl:value-of
                                                select="//t:listPerson/t:person[@xml:id = substring-after($buyer-ID, '#')]/t:persName"
                                            />
                                        </rdfs:label>
                                    </crm:E39_Actor>
                                </crm:P22_transferred_title_to>
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
                                                  select="concat('https:r0man-ist.github.io/regC#S', $count_sale, '-I', $count_item)"
                                                />
                                            </xsl:attribute>
                                            <dcterms:title>
                                                <xsl:value-of
                                                  select="normalize-space(//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title)"
                                                />
                                            </dcterms:title>
                                            <xsl:if
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                                                <dcterms:creator>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                                                  <crm:E21_Person>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author/@ref"
                                                  />
                                                  </xsl:attribute>
                                                  <rdfs:label>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                  />
                                                  </rdfs:label>
                                                  </crm:E21_Person>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                  />
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </dcterms:creator>
                                            </xsl:if>
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
                            <!-- time -->
                            <crm:P4_has_time_span>
                                <crm:E61_Time_Primitive>
                                    <!-- determine whether time is specified in ancestor or descendant element -->
                                    <xsl:choose>
                                        <xsl:when
                                            test="./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]">
                                            <crm:P82a_begin_of_the_begin
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">

                                                <xsl:value-of
                                                  select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/@notBefore, 'T00:00:00')"
                                                />
                                            </crm:P82a_begin_of_the_begin>
                                            <crm:P82b_end_of_the_end
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                                <xsl:value-of
                                                  select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/@notAfter, 'T23:59:59')"/>

                                            </crm:P82b_end_of_the_end>
                                        </xsl:when>
                                        <xsl:when
                                            test="./descendant::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]">
                                            <crm:P82a_begin_of_the_begin
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">

                                                <xsl:value-of
                                                  select="concat(./descendant::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/@notBefore, 'T00:00:00')"
                                                />
                                            </crm:P82a_begin_of_the_begin>
                                            <crm:P82b_end_of_the_end
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                                <xsl:value-of
                                                  select="concat(./descendant::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/@notAfter, 'T23:59:59')"/>

                                            </crm:P82b_end_of_the_end>
                                        </xsl:when>
                                    </xsl:choose>
                                </crm:E61_Time_Primitive>
                            </crm:P4_has_time_span>
                        </crm:E96_Purchase>
                    </crm:P70_documents>
                </xsl:for-each>
                <!-- end loop sales -->

                <!-- Subscription -->
                <xsl:for-each select="//t:row[@ana = 'prov:subscription']">
                    <xsl:variable name="count_subscription" select="position()"/>
                    <crm:P70_documents>
                        <prov:Subscription>

                            <!-- basic counter for IDs and URI -->
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https:r0man-ist.github.io/regC#Sub', $count_subscription)"
                                />
                            </xsl:attribute>
                            <!-- subscriber -->
                            <crm:P14_carried_out_by>
                                <crm:E74_Group rdf:about="http://viaf.org/viaf/129788129">
                                    <rdfs:label>Bodleian Library</rdfs:label>
                                </crm:E74_Group>
                            </crm:P14_carried_out_by>

                            <!-- check if there are associated items -->
                            <xsl:if test="./descendant::t:bibl[@corresp]">
                                <xsl:for-each select="./descendant::t:bibl">
                                    <xsl:variable name="count_item" select="position()"/>
                                    <xsl:variable name="item_ID" select="./@corresp"/>
                                    <crm:P67_refers_to>
                                        <prov:Item>
                                            <xsl:attribute name="rdf:about">
                                                <xsl:value-of
                                                  select="concat('https:r0man-ist.github.io/regC#Sub', $count_subscription, '-I', $count_item)"
                                                />
                                            </xsl:attribute>
                                            <dcterms:title>
                                                <xsl:value-of
                                                  select="normalize-space(//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:title)"
                                                />
                                            </dcterms:title>
                                            <xsl:if
                                                test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                                                <dcterms:creator>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                                                  <crm:E21_Person>
                                                  <xsl:attribute name="rdf:about">
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author/@ref"
                                                  />
                                                  </xsl:attribute>
                                                  <rdfs:label>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                  />
                                                  </rdfs:label>
                                                  </crm:E21_Person>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="//t:listObject/t:object[@xml:id = substring-after($item_ID, '#')]/t:biblStruct/t:monogr/t:author"
                                                  />
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </dcterms:creator>
                                            </xsl:if>
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
                                    </crm:P67_refers_to>
                                    <!-- Price -->
                                    <xsl:if test="./../following-sibling::t:cell/t:measure">
                                        <prov:subscription_price_paid>
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
                                        </prov:subscription_price_paid>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:if>
                            <!-- time -->
                            <crm:P4_has_time_span>
                                <crm:E61_Time_Primitive>
                                    <crm:P82a_begin_of_the_begin
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:value-of
                                            select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notBefore, 'T00:00:00')"
                                        />
                                    </crm:P82a_begin_of_the_begin>
                                    <crm:P82b_end_of_the_end
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                        <xsl:value-of
                                            select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when']/@notAfter, 'T23:59:59')"
                                        />
                                    </crm:P82b_end_of_the_end>
                                </crm:E61_Time_Primitive>
                            </crm:P4_has_time_span>
                        </prov:Subscription>
                    </crm:P70_documents>
                </xsl:for-each>

            </crm:E31_Document>
        </rdf:RDF>
    </xsl:template>
</xsl:stylesheet>
