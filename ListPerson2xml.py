import pandas as pd
import xml.etree.ElementTree as ET

# Read data from a CSV file with a semicolon delimiter
df = pd.read_csv('standOff_List-Persons.csv', delimiter=';')

# Create the root element for the XML
root = ET.Element('listPerson')

# Iterate through the DataFrame
for _, row in df.iterrows():
    person_attributes = {
        'xml:id': row['xml:id'],
    }
    person_element = ET.SubElement(root, 'person', attrib=person_attributes)

    # Check if each field is empty before creating an XML element
    if not pd.isna(row['persName']):
        pers_name_element = ET.SubElement(person_element, 'persName')
        pers_name_element.text = row['persName']

    if not pd.isna(row['VIAF']):
        idno_element = ET.SubElement(person_element, 'idno', type='VIAF')
        idno_element.text = row['VIAF']

    if not pd.isna(row['CERL']):
        cerl_element = ET.SubElement(person_element, 'idno', type='CERL')
        cerl_element.text = row['CERL']

    if not pd.isna(row['WikiData']):
        wikidata_element = ET.SubElement(person_element, 'idno', type='WikiData')
        wikidata_element.text = row['WikiData']

# Create the XML file
tree = ET.ElementTree(root)
tree.write('standOff_List-Persons.xml')

print("Conversion complete. XML file saved as output.xml")
