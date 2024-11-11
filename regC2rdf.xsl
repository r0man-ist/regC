<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" xmlns:dcterms="http://purl.org/dc/terms"
    xmlns:prov="https://r0man-ist.github.io/regC#prov"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:t="http://www.tei-c.org/ns/1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>


    <!-- ================================ -->
    <!-- ================================ -->
    <!--           FUNCTIONS              -->
    <!-- ================================ -->
    <!-- ================================ -->

    <!-- root node as global variable -->
    <xsl:variable name="root" select="/"/>


    <!-- ================================ -->
    <!--      Item-specific functions     -->
    <!-- ================================ -->

    <!-- Creator - Function-->
    <xsl:function name="prov:addCreator">
        <xsl:param name="arg"/>
        <xsl:if
            test="$root//t:listObject/t:object[@xml:id = substring-after($arg, '#')]/t:biblStruct/t:monogr/t:author">
            <dcterms:creator>
                <xsl:choose>
                    <xsl:when
                        test="$root//t:listObject/t:object[@xml:id = substring-after($arg, '#')]/t:biblStruct/t:monogr/t:author[@ref]">
                        <crm:E21_Person>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="$root//t:listObject/t:object[@xml:id = substring-after($arg, '#')]/t:biblStruct/t:monogr/t:author/@ref"
                                />
                            </xsl:attribute>
                            <rdfs:label>
                                <xsl:value-of
                                    select="$root//t:listObject/t:object[@xml:id = substring-after($arg, '#')]/t:biblStruct/t:monogr/t:author"
                                />
                            </rdfs:label>
                        </crm:E21_Person>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="$root//t:listObject/t:object[@xml:id = substring-after($arg, '#')]/t:biblStruct/t:monogr/t:author"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </dcterms:creator>
        </xsl:if>
    </xsl:function>

    <!-- Title - Function -->
    <xsl:function name="prov:addTitle">
        <xsl:param name="arg"/>
        <dcterms:title>
            <xsl:value-of
                select="normalize-space($root//t:listObject/t:object[@xml:id = substring-after($arg, '#')]/t:biblStruct/t:monogr/t:title)"
            />
        </dcterms:title>
    </xsl:function>

    <!-- Current_Shelfmark - Function -->
    <xsl:function name="prov:addCurrentShelfmark">
        <xsl:param name="arg"/>
        <xsl:if
            test="$root//t:listObject/t:object[@xml:id = substring-after($arg, '#') and @ana = 'copy-identified']/t:objectIdentifier/t:idno[@type = 'shelfmark']">
            <crm:P48_has_preferred_identifier>
                <xsl:value-of
                    select="$root//t:listObject/t:object[@xml:id = substring-after($arg, '#')]/t:objectIdentifier/t:idno[@type = 'shelfmark']"
                />
            </crm:P48_has_preferred_identifier>
        </xsl:if>
    </xsl:function>

    <!-- Work-ID - Function -->
    <xsl:function name="prov:addWorkID">
        <xsl:param name="arg"/>
        <xsl:if
            test="$root//t:listObject/t:object[@xml:id = substring-after($arg, '#')]/t:biblStruct/t:monogr/t:title[@ref]">
            <dcterms:isVersionOf>
                <xsl:attribute name="rdf:resource">
                    <xsl:value-of
                        select="$root//t:listObject/t:object[@xml:id = substring-after($arg, '#')]/t:biblStruct/t:monogr/t:title/@ref"
                    />
                </xsl:attribute>
            </dcterms:isVersionOf>
        </xsl:if>
    </xsl:function>

    <!-- Item-Details - Function -->
    <!-- This function calls addTitle, addCreator, addCurrentShelfmark and addWorkID -->
    <xsl:function name="prov:addItemDetails">
        <xsl:param name="arg"/>
        <xsl:copy-of select="prov:addTitle($arg)"/>
        <xsl:copy-of select="prov:addCreator($arg)"/>
        <xsl:copy-of select="prov:addCurrentShelfmark($arg)"/>
        <xsl:copy-of select="prov:addWorkID($arg)"/>
    </xsl:function>

    <!-- ================================ -->
    <!--      ID Assignment function      -->
    <!-- ================================ -->


    <xsl:function name="prov:IDAssignment">
        <xsl:param name="category"/>
        <xsl:param name="abbreviation"/>
        <xsl:for-each select="$root//t:row[@ana = concat('prov:', $category)]">
            <xsl:variable name="count" select="position()"/>
            <xsl:if test="./descendant::t:ab[@type = 'shelfmark']">
                <crm:P70_documents>
                    <crm:E15_Identifier_Assignment>
                        <xsl:attribute name="rdf:about">
                            <xsl:value-of
                                select="concat('https://r0man-ist.github.io/regC#', $abbreviation, '-ID', $count)"
                            />
                        </xsl:attribute>
                        <xsl:for-each select="./descendant::t:bibl">
                            <xsl:variable name="count_item" select="position()"/>
                            <xsl:variable name="item_ID" select="./@corresp"/>

                            <crm:P140_assigned_attribute_to>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of
                                        select="concat('https://r0man-ist.github.io/regC#', $abbreviation, $count, '-I', $count_item)"
                                    />
                                </xsl:attribute>
                            </crm:P140_assigned_attribute_to>

                        </xsl:for-each>
                        <crm:P37_assigned>
                            <crm:E42_Identifier>
                                <xsl:attribute name="rdf:about">
                                    <xsl:value-of
                                        select="concat('https://r0man-ist.github.io/regC#', $abbreviation, $count, '-ID')"
                                    />
                                </xsl:attribute>
                                <crm:P90_has_value>
                                    <xsl:value-of
                                        select="./descendant::t:ab[@type = 'shelfmark']/t:choice/t:reg"
                                    />
                                </crm:P90_has_value>
                            </crm:E42_Identifier>
                        </crm:P37_assigned>
                        <!-- Time -->
                        <crm:P4_has_time_span>
                            <crm:E61_Time_Primitive>
                                <xsl:choose>
                                    <!-- determine whether time is specified in ancestor or descendant element; descendant takes precedence -->
                                    <xsl:when test="./descendant::t:ab[@ana = 'prov']">
                                        <crm:P82a_begin_of_the_begin
                                            rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                            <xsl:value-of
                                                select="concat(./descendant::t:date[@type = 'prov:ID-Assignment']/@notBefore | @when, 'T00:00:00')"
                                            />
                                        </crm:P82a_begin_of_the_begin>
                                        <crm:P82b_end_of_the_end
                                            rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                            <xsl:value-of
                                                select="concat(./descendant::t:date[@type = 'prov:ID-Assignment']/@notAfter | @when, 'T23:59:59')"
                                            />
                                        </crm:P82b_end_of_the_end>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <crm:P82a_begin_of_the_begin
                                            rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                            <xsl:value-of
                                                select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:purchase')]/@notAfter | @when, 'T00:00:00')"
                                            />
                                        </crm:P82a_begin_of_the_begin>
                                        <crm:P82b_end_of_the_end
                                            rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                            <xsl:value-of
                                                select="concat(./ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:purchase')]/@notAfter | @when, 'T23:59:59')"
                                            />
                                        </crm:P82b_end_of_the_end>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </crm:E61_Time_Primitive>
                        </crm:P4_has_time_span>
                    </crm:E15_Identifier_Assignment>
                </crm:P70_documents>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>

    <!-- ================================ -->
    <!--           Time Function          -->
    <!-- ================================ -->

    <xsl:function name="prov:addTime">
        <xsl:param name="category"/>
        <xsl:param name="context"/>
        <crm:P4_has_time_span>
            <crm:E61_Time_Primitive>
                <!-- determine whether time is specified in ancestor or descendant element; descendant takes precedence -->
                <xsl:choose>
                    <xsl:when
                        test="$context/descendant::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]">
                        <crm:P82a_begin_of_the_begin
                            rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">

                            <xsl:value-of
                                select="concat($context/descendant::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/(@notBefore | @when), 'T00:00:00')"
                            />
                        </crm:P82a_begin_of_the_begin>
                        <crm:P82b_end_of_the_end
                            rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                            <xsl:value-of
                                select="concat($context/descendant::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/(@notAfter | @when), 'T23:59:59')"/>

                        </crm:P82b_end_of_the_end>
                    </xsl:when>
                    <xsl:otherwise>
                        <crm:P82a_begin_of_the_begin
                            rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">

                            <xsl:value-of
                                select="concat($context/ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/(@notBefore | @when), 'T00:00:00')"
                            />
                        </crm:P82a_begin_of_the_begin>
                        <crm:P82b_end_of_the_end
                            rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                            <xsl:value-of
                                select="concat($context/ancestor::t:ab[@ana = 'prov']/t:date[@ana = 'prov:when' and not(@type = 'prov:ID-Assignment')]/(@notAfter | @when), 'T23:59:59')"/>

                        </crm:P82b_end_of_the_end>
                    </xsl:otherwise>

                </xsl:choose>
            </crm:E61_Time_Primitive>
        </crm:P4_has_time_span>
    </xsl:function>

    <!-- ================================ -->
    <!--          Actor Function          -->
    <!-- ================================ -->
    <!--       For Donors, Sellers or Buyers   -->
    <xsl:function name="prov:addActor">
        <xsl:param name="arg"/>
        <crm:E39_Actor>
            <xsl:attribute name="rdf:about">
                <!-- Authority statements in Order VIAF > Wikidata> CERL -->
                <xsl:choose>
                    <xsl:when
                        test="$root//t:listPerson/t:person[@xml:id = substring-after($arg, '#')]/t:idno[@type = 'VIAF']">
                        <xsl:value-of
                            select="concat('https://viaf.org/viaf/', $root//t:listPerson/t:person[@xml:id = substring-after($arg, '#')]/t:idno[@type = 'VIAF'])"
                        />
                    </xsl:when>
                    <xsl:when
                        test="$root//t:listPerson/t:person[@xml:id = substring-after($arg, '#')]/t:idno[@type = 'WikiData']">
                        <xsl:value-of
                            select="concat('https://www.wikidata.org/wiki/', $root//t:listPerson/t:person[@xml:id = substring-after($arg, '#')]/t:idno[@type = 'WikiData'])"
                        />
                    </xsl:when>
                    <xsl:when
                        test="$root//t:listPerson/t:person[@xml:id = substring-after($arg, '#')]/t:idno[@type = 'CERL']">
                        <xsl:value-of
                            select="concat('https://data.cerl.org/thesaurus/', $root//t:listPerson/t:person[@xml:id = substring-after($arg, '#')]/t:idno[@type = 'CERL'])"
                        />
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <rdfs:label>
                <xsl:value-of
                    select="$root//t:listPerson/t:person[@xml:id = substring-after($arg, '#')]/t:persName"
                />
            </rdfs:label>
        </crm:E39_Actor>
    </xsl:function>



    <!-- ================================ -->
    <!--          Price Functions          -->
    <!-- ================================ -->
    <xsl:function name="prov:monetaryAmount">
        <xsl:param name="context"/>
        <xsl:if test="$context/descendant::t:cell/t:measure">
            <crm:E97_Monetary_Amount>
                <crm:P180_has_currency>Pound</crm:P180_has_currency>
                <crm:P90_has_value>
                    <xsl:value-of
                        select="$context/descendant::t:cell/t:measure[@unit = 'pound']/@quantity"
                        />-<xsl:value-of
                        select="$context/descendant::t:cell/t:measure[@unit = 'shilling']/@quantity"
                        />-<xsl:value-of
                        select="$context/descendant::t:cell/t:measure[@unit = 'pence']/@quantity"
                    /></crm:P90_has_value>
            </crm:E97_Monetary_Amount>
        </xsl:if>
    </xsl:function>

    <xsl:function name="prov:addPrice">
        <xsl:param name="category"/>
        <xsl:param name="context"/>
        <xsl:if test="($category = 'purchase' or $category = 'sold')">
            <crm:P119_had_sales_price>
                <xsl:copy-of select="prov:monetaryAmount($context)"/>
            </crm:P119_had_sales_price>
        </xsl:if>
        <xsl:if test="$category = 'subscription'">
            <prov:subscription_price_paid>
                <xsl:copy-of select="prov:monetaryAmount($context)"/>
            </prov:subscription_price_paid>
        </xsl:if>
    </xsl:function>

    <!-- ================================ -->
    <!-- ================================ -->
    <!--           TEMPLATE               -->
    <!-- ================================ -->
    <!-- ================================ -->

    <xsl:template match="/">
        <rdf:RDF>
            <crm:E31_Document>
                <xsl:attribute name="rdf:about">https://r0man-ist.github.io/regC</xsl:attribute>



                <!-- ================================ -->
                <!--            Purchases             -->
                <!-- ================================ -->
                <xsl:for-each select="//t:row[@ana = 'prov:purchase']">
                    <xsl:variable name="count_purchase" select="position()"/>
                    <crm:P70_documents>
                        <crm:E96_Purchase>
                            <!-- Change of Ownership -->
                            <!-- basic counter for IDs and URI -->
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https://r0man-ist.github.io/regC#P', $count_purchase)"
                                />
                            </xsl:attribute>
                            <!-- buyer -->
                            <crm:P22_transferred_title_to>
                                <crm:E74_Group rdf:about="https://viaf.org/viaf/129788129">
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
                                    <!-- Add Actor Details -->
                                    <xsl:copy-of select="prov:addActor($seller-ID)"/>
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
                                                  select="concat('https://r0man-ist.github.io/regC#P', $count_purchase, '-I', $count_item)"
                                                />
                                            </xsl:attribute>

                                            <!-- Add Item Details -->
                                            <xsl:copy-of select="prov:addItemDetails($item_ID)"/>


                                        </prov:Item>
                                    </crm:P24_transferred_title_of>
                                </xsl:for-each>
                            </xsl:if>

                            <!-- Price -->
                            <xsl:copy-of select="prov:addPrice('purchase', .)"/>

                            <!-- time -->
                            <xsl:copy-of select="prov:addTime('purchase', .)"/>

                        </crm:E96_Purchase>
                    </crm:P70_documents>
                </xsl:for-each>


                <!-- ID-Assignment -->
                <xsl:copy-of select="prov:IDAssignment('purchase', 'P')"/>



                <!-- ================================ -->
                <!--         MOVE/Change-ID           -->
                <!-- ================================ -->
                <xsl:for-each select="//t:row[@ana = 'prov:move-changeId']">
                    <xsl:variable name="count_move" select="position()"/>
                    <crm:P70_documents>
                        <crm:E15_Identifier_Assignment>
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https://r0man-ist.github.io/regC#M', $count_move)"
                                />
                            </xsl:attribute>
                            <crm:P37_assigned>
                                <crm:E42_Identifier>
                                    <xsl:attribute name="rdf:about">
                                        <xsl:value-of
                                            select="concat('https://r0man-ist.github.io/regC#M', $count_move, '-IDnew')"
                                        />
                                    </xsl:attribute>
                                    <crm:P90_has_value>
                                        <xsl:value-of
                                            select="./descendant::t:ab[@type = 'shelfmark'][2]/t:choice/t:reg"
                                        />
                                    </crm:P90_has_value>
                                </crm:E42_Identifier>
                            </crm:P37_assigned>
                            <crm:P38_deassigned>
                                <crm:E42_Identifier>
                                    <xsl:attribute name="rdf:about">
                                        <xsl:value-of
                                            select="concat('https://r0man-ist.github.io/regC#M', $count_move, '-IDold')"
                                        />
                                    </xsl:attribute>
                                    <crm:P90_has_value>
                                        <xsl:value-of
                                            select="./descendant::t:ab[@type = 'shelfmark'][1]/t:choice/t:reg"
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
                                                  select="concat('https://r0man-ist.github.io/regC#M', $count_move, '-I', $count_item)"
                                                />
                                            </xsl:attribute>

                                            <!-- Add Item Details -->
                                            <xsl:copy-of select="prov:addItemDetails($item_ID)"/>

                                        </prov:Item>
                                    </crm:P140_assigned_attribute_to>


                                </xsl:for-each>
                            </xsl:if>
                            <!-- time -->
                            <xsl:copy-of select="prov:addTime('move-changeId', .)"/>

                        </crm:E15_Identifier_Assignment>
                    </crm:P70_documents>
                </xsl:for-each>



                <!-- ================================ -->
                <!--            DEPOSITS             -->
                <!-- ================================ -->
                <xsl:for-each select="//t:row[@ana = 'prov:deposit']">
                    <xsl:variable name="count_deposit" select="position()"/>
                    <crm:P70_documents>
                        <prov:Legal_Deposit>
                            <!-- Change of Ownership -->
                            <!-- basic counter for IDs and URI -->
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https://r0man-ist.github.io/regC#Dep', $count_deposit)"
                                />
                            </xsl:attribute>
                            <!-- acquirer -->
                            <crm:P22_transferred_title_to>
                                <crm:E74_Group rdf:about="https://viaf.org/viaf/129788129">
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
                                                  select="concat('https://r0man-ist.github.io/regC#Dep', $count_deposit, '-I', $count_item)"
                                                />
                                            </xsl:attribute>

                                            <!-- Add Item Details -->
                                            <xsl:copy-of select="prov:addItemDetails($item_ID)"/>

                                        </prov:Item>
                                    </crm:P24_transferred_title_of>
                                </xsl:for-each>
                            </xsl:if>

                            <!-- time -->
                            <xsl:copy-of select="prov:addTime('deposit', .)"/>

                        </prov:Legal_Deposit>
                    </crm:P70_documents>
                </xsl:for-each>

                <!-- ID-Assignment -->
                <xsl:copy-of select="prov:IDAssignment('deposit', 'Dep')"/>




                <!-- ================================ -->
                <!--            DONATIONS             -->
                <!-- ================================ -->
                <xsl:for-each select="//t:row[@ana = 'prov:donation']">
                    <xsl:variable name="count_donation" select="position()"/>
                    <crm:P70_documents>
                        <prov:Donation>
                            <!-- Change of Ownership -->
                            <!-- basic counter for IDs and URI -->
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https://r0man-ist.github.io/regC#D', $count_donation)"
                                />
                            </xsl:attribute>
                            <!-- acquirer -->
                            <crm:P22_transferred_title_to>
                                <crm:E74_Group rdf:about="https://viaf.org/viaf/129788129">
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
                                        <!-- Add Actor Details -->
                                        <xsl:copy-of select="prov:addActor($donor-ID)"/>
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
                                                  select="concat('https://r0man-ist.github.io/regC#D', $count_donation, '-I', $count_item)"
                                                />
                                            </xsl:attribute>

                                            <!-- Add Item Details -->
                                            <xsl:copy-of select="prov:addItemDetails($item_ID)"/>

                                        </prov:Item>
                                    </crm:P24_transferred_title_of>
                                </xsl:for-each>
                            </xsl:if>

                            <!-- time -->
                            <xsl:copy-of select="prov:addTime('deposit', .)"/>

                        </prov:Donation>
                    </crm:P70_documents>
                </xsl:for-each>
                <!-- ID-Assignment -->
                <xsl:copy-of select="prov:IDAssignment('donation', 'D')"/>

                <!-- ================================ -->
                <!--             SALES                -->
                <!-- ================================ -->
                <xsl:for-each select="//t:row[@ana = 'prov:sold']">
                    <xsl:variable name="count_sale" select="position()"/>
                    <crm:P70_documents>
                        <crm:E96_Purchase>
                            <!-- Change of Ownership -->
                            <!-- basic counter for IDs and URI -->
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https://r0man-ist.github.io/regC#S', $count_sale)"
                                />
                            </xsl:attribute>
                            <!-- seller -->
                            <crm:P23_transferred_title_from>
                                <crm:E74_Group rdf:about="https://viaf.org/viaf/129788129">
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
                                    <!-- Add Actor Details -->
                                    <xsl:copy-of select="prov:addActor($buyer-ID)"/>
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
                                                  select="concat('https://r0man-ist.github.io/regC#S', $count_sale, '-I', $count_item)"
                                                />
                                            </xsl:attribute>

                                            <!-- Add Item Details -->
                                            <xsl:copy-of select="prov:addItemDetails($item_ID)"/>

                                        </prov:Item>
                                    </crm:P24_transferred_title_of>

                                </xsl:for-each>
                            </xsl:if>

                            <!-- Price -->
                            <xsl:copy-of select="prov:addPrice('sold', .)"/>

                            <!-- time -->
                            <xsl:copy-of select="prov:addTime('sold', .)"/>

                        </crm:E96_Purchase>
                    </crm:P70_documents>
                </xsl:for-each>


                <!-- ================================ -->
                <!--          SUBSCRIPTIONS           -->
                <!-- ================================ -->
                <xsl:for-each select="//t:row[@ana = 'prov:subscription']">
                    <xsl:variable name="count_subscription" select="position()"/>
                    <crm:P70_documents>
                        <prov:Subscription>

                            <!-- basic counter for IDs and URI -->
                            <xsl:attribute name="rdf:about">
                                <xsl:value-of
                                    select="concat('https://r0man-ist.github.io/regC#Sub', $count_subscription)"
                                />
                            </xsl:attribute>
                            <!-- subscriber -->
                            <crm:P14_carried_out_by>
                                <crm:E74_Group rdf:about="https://viaf.org/viaf/129788129">
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
                                                  select="concat('https://r0man-ist.github.io/regC#Sub', $count_subscription, '-I', $count_item)"
                                                />
                                            </xsl:attribute>

                                            <!-- Add Item Details -->
                                            <xsl:copy-of select="prov:addItemDetails($item_ID)"/>

                                        </prov:Item>
                                    </crm:P67_refers_to>

                                </xsl:for-each>
                            </xsl:if>
                            <!-- time -->
                            <xsl:copy-of select="prov:addTime('deposit', .)"/>

                            <!-- Price -->
                            <xsl:copy-of select="prov:addPrice('subscription', .)"/>

                        </prov:Subscription>
                    </crm:P70_documents>
                </xsl:for-each>
            </crm:E31_Document>
        </rdf:RDF>
    </xsl:template>
</xsl:stylesheet>
