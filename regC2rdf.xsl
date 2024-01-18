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
                                    <rdfs:label>Bodleian Library</rdfs:label>
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
                                        <rdfs:label>
                                            <xsl:value-of
                                                select="//t:listPerson/t:person[@xml:id = substring-after($seller-ID, '#')]/t:persName"
                                            />
                                        </rdfs:label>
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
                            <!-- time -->
                            <crm:P4_has_time_span>
                                <crm:E61_Time_Primitive>
                                    <crm:P82a_begin_of_the_begin
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                        <xsl:value-of
                                            select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notBefore"
                                        />
                                    </crm:P82a_begin_of_the_begin>
                                    <crm:P82b_end_of_the_end
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                        <xsl:value-of
                                            select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notAfter"
                                        />
                                    </crm:P82b_end_of_the_end>
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
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                                <xsl:value-of
                                                  select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notBefore"
                                                />
                                            </crm:P82a_begin_of_the_begin>
                                            <crm:P82b_end_of_the_end
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                                <xsl:value-of
                                                  select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notAfter"
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
                            <crm:P4_has_time_span>
                                <crm:E61_Time_Primitive>
                                    <crm:P82a_begin_of_the_begin
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                        <xsl:value-of
                                            select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notBefore"
                                        />
                                    </crm:P82a_begin_of_the_begin>
                                    <crm:P82b_end_of_the_end
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                        <xsl:value-of
                                            select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notAfter"
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
                            <crm:P4_has_time_span>
                                <crm:E61_Time_Primitive>
                                    <crm:P82a_begin_of_the_begin
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                        <xsl:value-of
                                            select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notBefore"
                                        />
                                    </crm:P82a_begin_of_the_begin>
                                    <crm:P82b_end_of_the_end
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                        <xsl:value-of
                                            select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notAfter"
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
                        <xsl:for-each select="./descendant::t:bibl">
                            <xsl:variable name="count_item" select="position()"/>
                            <xsl:variable name="item_ID" select="./@corresp"/>
                            <crm:P70_documents>
                                <crm:E15_Identifier_Assignment>
                                    <xsl:attribute name="rdf:about">
                                        <xsl:value-of
                                            select="concat('https:r0man-ist.github.io/regC/#Dep-ID', $count_deposit)"
                                        />
                                    </xsl:attribute>
                                    <crm:P140_assigned_identifier_to>
                                        <xsl:attribute name="rdf:resource">
                                            <xsl:value-of
                                                select="concat('https:r0man-ist.github.io/regC/#Dep', $count_deposit, '-I', $count_item)"
                                            />
                                        </xsl:attribute>
                                    </crm:P140_assigned_identifier_to>
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
                                    <crm:P4_has_time_span>
                                        <crm:E61_Time_Primitive>
                                            <crm:P82a_begin_of_the_begin
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                                <xsl:value-of
                                                  select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notBefore"
                                                />
                                            </crm:P82a_begin_of_the_begin>
                                            <crm:P82b_end_of_the_end
                                                rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                                <xsl:value-of
                                                  select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notAfter"
                                                />
                                            </crm:P82b_end_of_the_end>
                                        </crm:E61_Time_Primitive>
                                    </crm:P4_has_time_span>
                                </crm:E15_Identifier_Assignment>
                            </crm:P70_documents>
                        </xsl:for-each>
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
                                        <rdfs:label>
                                            <xsl:value-of
                                                select="//t:listPerson/t:person[@xml:id = substring-after($donor-ID, '#')]/t:persName"
                                            />
                                        </rdfs:label>
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
                            <crm:P4_has_time_span>
                                <crm:E61_Time_Primitive>
                                    <crm:P82a_begin_of_the_begin
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                        <xsl:value-of
                                            select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notBefore"
                                        />
                                    </crm:P82a_begin_of_the_begin>
                                    <crm:P82b_end_of_the_end
                                        rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                        <xsl:value-of
                                            select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notAfter"
                                        />
                                    </crm:P82b_end_of_the_end>
                                </crm:E61_Time_Primitive>
                            </crm:P4_has_time_span>
                        </prov:Donation>
                                            </crm:P70_documents>
                    <!-- ID-Assignment -->
                    <xsl:for-each select="//t:row[@ana = 'prov:donation']">
                        <xsl:variable name="count_deposit" select="position()"/>
                        <xsl:if test="./descendant::t:ab[@type = 'shelfmark']">
                            <xsl:for-each select="./descendant::t:bibl">
                                <xsl:variable name="count_item" select="position()"/>
                                <xsl:variable name="item_ID" select="./@corresp"/>
                                <crm:P70_documents>
                                    <crm:E15_Identifier_Assignment>
                                        <xsl:attribute name="rdf:about">
                                            <xsl:value-of
                                                select="concat('https:r0man-ist.github.io/regC/#D-ID', $count_donation)"
                                            />
                                        </xsl:attribute>
                                        <crm:P140_assigned_identifier_to>
                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of
                                                    select="concat('https:r0man-ist.github.io/regC/#D', $count_donation, '-I', $count_item)"
                                                />
                                            </xsl:attribute>
                                        </crm:P140_assigned_identifier_to>
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
                                                    rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                                    <xsl:value-of
                                                        select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notBefore"
                                                    />
                                                </crm:P82a_begin_of_the_begin>
                                                <crm:P82b_end_of_the_end
                                                    rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
                                                    <xsl:value-of
                                                        select="./ancestor::t:ab[@ana = 'prov:when']/t:date/@notAfter"
                                                    />
                                                </crm:P82b_end_of_the_end>
                                            </crm:E61_Time_Primitive>
                                        </crm:P4_has_time_span>
                                    </crm:E15_Identifier_Assignment>
                                </crm:P70_documents>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
                <!-- End loop Donation -->


            </crm:E31_Document>
        </rdf:RDF>
    </xsl:template>
</xsl:stylesheet>