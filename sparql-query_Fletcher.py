# SPARQL Query to identify books bought from Stephen Fletcher

from rdflib import Graph



g = Graph()
with open("RegC.rdf", "r") as f:
    result = g.parse(f, format="application/rdf+xml")

query = """
PREFIX dcterms: <http://purl.org/dc/terms>
SELECT ?Item ?ItemTitle ?ItemShelfmark
WHERE {
    ?s crm:P23_transferred_title_from ?Seller .
    ?s rdf:type crm:E96_Purchase .
    ?s crm:P24_transferred_title_of ?Item .
    ?Item dcterms:title ?ItemTitle .
    OPTIONAL { ?Item crm:P48_has_preferred_identifier ?ItemShelfmark }
    FILTER (?Seller = <https://data.cerl.org/thesaurus/cnp00058554>) .
    }"""

qres = g.query(query)

print(len(qres))
for row in qres:
    print(f"{row.ItemTitle} || {row.ItemShelfmark}")

