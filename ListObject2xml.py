import pandas as pd
import xml.etree.ElementTree as ET

# Read data from the CSV file with a comma delimiter
df = pd.read_csv('standOff_List-Objects.csv', delimiter=',', dtype=str)

# Create the root element for the XML
root = ET.Element('listObject')

# Iterate through the DataFrame
for _, row in df.iterrows():
    object_attributes = {
        'xml:id': row['regC-ID'], 'ana': row['copy identified?']
    }
    object_element = ET.SubElement(root, 'object', attrib=object_attributes)

    objectIdentifier_element = ET.SubElement(object_element, 'objectIdentifier')

    institution_element = ET.SubElement(objectIdentifier_element, 'institution')
    institution_element.text = "Bodleian Library"


    # Check if each field is empty before creating an XML element
    if not pd.isna(row['Permanent Call Number']):
        shelfmark_element = ET.SubElement(objectIdentifier_element, 'idno', type='shelfmark')
        shelfmark_element.text = row['Permanent Call Number']

    if not pd.isna(row['MMS Id']):
        ALMAID_element = ET.SubElement(objectIdentifier_element, 'idno', type='ALMA-ID')
        ALMAID_element.text = (row['MMS Id'])
        SOLOlink_element = ET.SubElement(objectIdentifier_element, 'idno', type='SOLOlink')
        SOLOlink_element.text = "https://solo.bodleian.ox.ac.uk/permalink/44OXF_INST/35n82s/alma"+str((row['MMS Id']))    

    if not (pd.isna(row['AuthorReconcile']) and pd.isna(row['Title']) and pd.isna(row['Publication Place']) and pd.isna(row['Date of Publication'])):
        biblStruct_element = ET.SubElement(object_element, 'biblStruct')
        monogr_element = ET.SubElement(biblStruct_element, 'monogr')
        if pd.isna(row['VIAF-ID']):
            if not pd.isna(row['AuthorReconcile']):
                author_element = ET.SubElement(monogr_element, 'author')
                author_element.text = (row['AuthorReconcile'])
        else:
            if not pd.isna(row['AuthorReconcile']):
                author_element = ET.SubElement(monogr_element, 'author', ref='https://viaf.org/viaf/'+(row['VIAF-ID']))
                author_element.text = (row['AuthorReconcile'])
        if pd.isna(row['VIAF-ID_WORK']): 
            if not pd.isna(row['Title']):
                title_element = ET.SubElement(monogr_element, 'title')
                title_element.text = (row['Title'])
        else:
            if not pd.isna(row['Title']):
                title_element = ET.SubElement(monogr_element, 'title', ref='https://viaf.org/viaf/'+str((row['VIAF-ID_WORK'])))
                title_element.text = (row['Title'])
        imprint_element = ET.SubElement(monogr_element, 'imprint')    
        if not pd.isna(row['Publication Place']):
            place_element = ET.SubElement(imprint_element, 'pubPlace')
            place_element.text = (row['Publication Place'])
        if not pd.isna(row['Date of Publication']):
            date_element = ET.SubElement(imprint_element, 'date')
            date_element.text = (row['Date of Publication'])
        
              

      



# Create the XML file
tree = ET.ElementTree(root)
tree.write('standOff_List-Objects.xml')
