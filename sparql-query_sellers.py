# SPARQL Query to identify Sellers

from rdflib import Graph



g = Graph()
with open("RegC.rdf", "r") as f:
    result = g.parse(f, format="application/rdf+xml")

query = """
SELECT DISTINCT ?Seller ?SellerLabel
WHERE {
    ?s crm:P23_transferred_title_from ?Seller .
    ?s rdf:type crm:E96_Purchase .
    ?Seller rdfs:label ?SellerLabel .
    }"""

qres = g.query(query)

print(len(qres))
for row in qres:
    print(f"{row.SellerLabel} || {row.Seller}")

