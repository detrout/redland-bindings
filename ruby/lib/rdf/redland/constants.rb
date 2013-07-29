require 'rdf/redland'

module Redland

RDFNS = Redland::Namespace.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")

# Syntax names
RDF = RDFNS["RDF"]
DESCRIPTION = RDFNS["Description"]
ID = RDFNS["ID"]
ABOUT = RDFNS["about"]
BAG_ID = RDFNS["bagID"]
PARSE_TYPE = RDFNS["parseType"]
RESOURCE = RDFNS["resource"]
LI = RDFNS["li"]
NODE_ID = RDFNS["nodeID"]
DATATYPE = RDFNS["datatype"]

# RDF Classes
SEQ = RDFNS["Seq"]
BAG = RDFNS["Bag"]
ALT = RDFNS["Alt"]
STATEMENT = RDFNS["Statement"]
PROPERTY = RDFNS["Property"]
XMLLiteral = RDFNS["XMLLiteral"]
LIST = RDFNS["List"]

# RDF Properties
SUBJECT = RDFNS["subject"]
PREDICATE = RDFNS["predicate"]
OBJECT = RDFNS["object"]
TYPE = RDFNS["type"]
VALUE = RDFNS["value"]
FIRST = RDFNS["first"]
REST = RDFNS["rest"]
# and _n where n is a non-negative integer

# RDF Resources

# http://www.w3.org/TR/rdf-syntax-grammar/#eventterm-attribute-URI
# A mapping from unqualified terms to there qualified version.


# http://www.w3.org/TR/rdf-syntax-grammar/#coreSyntaxTerms
CORE_SYNTAX_TERMS = [RDF, ID, ABOUT, BAG_ID, PARSE_TYPE, RESOURCE, NODE_ID, DATATYPE]

# http://www.w3.org/TR/rdf-syntax-grammar/#syntaxTerms
SYNTAX_TERMS = CORE_SYNTAX_TERMS + [DESCRIPTION, LI]

# http://www.w3.org/TR/rdf-syntax-grammar/#oldTerms


end
