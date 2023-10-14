# Prefix
<standOff>
<listObject>

# rows
<object xml:id="{{cells['regC-ID'].value}}" ana="{{cells['copy identified?'].value}}">
<objectIdentifier>
<institution>Bodleian Library</institution>
<idno type="SOLOlink">https://solo.bodleian.ox.ac.uk/permalink/44OXF_INST/35n82s/alma{{cells['MMS Id'].value}}</idno>
<idno type="shelfmark">{{cells['Permanent Call Number'].value}}</idno>
<idno type="ALMA-ID">{{cells['MMS Id'].value}}</idno>
</objectIdentifier>
<biblStruct>
<monogr>
<author>{{cells['Author'].value}}</author>
<title>{{cells['Title'].value}}</title>
<imprint>
<date>{{cells['Date of Publication'].value}}</date>
<pubPlace>{{cells['Publication Place'].value}}</pubPlace>
</imprint>
</monogr>
</biblStruct>
</object>

# RowSeparator
[null]

# Suffix
</listObject>
</standOff>