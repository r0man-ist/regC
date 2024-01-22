# SPARQL Query to identify Items that were assigned a shelfmark in RegC but carry a different shelfmark today

from rdflib import Graph



g = Graph()
with open("RegC.rdf", "r") as f:
    result = g.parse(f, format="application/rdf+xml", encoding="utf-8")

g.serialize(destination="RegC.ttl", encoding="utf-8")