# SPARQL Query to identify Items that were assigned a shelfmark in RegC but carry a different shelfmark today

from rdflib import Graph



g = Graph()
with open("RegC.rdf", "r") as f:
    result = g.parse(f, format="application/rdf+xml")

query = """
PREFIX crm: <http://www.cidoc-crm.org/cidoc-crm/> 
SELECT DISTINCT ?item ?shelfmarkNew ?shelfmarkRegC
WHERE {
    ?item crm:P48_has_preferred_identifier ?shelfmarkNew .
    ?IDassignment crm:P140_assigned_attribute_to ?item .
    ?IDassignment crm:P37_assigned ?ID .
    ?ID crm:P90_has_value ?shelfmarkRegC .
    FILTER (?shelfmarkRegC  != ?shelfmarkNew)
}"""

qres = g.query(query)

print(len(qres))
for row in qres:
    print(f"{row.item} || {row.shelfmarkNew} || {row.shelfmarkRegC}")

