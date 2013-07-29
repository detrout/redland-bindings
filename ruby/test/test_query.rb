require 'test/unit'
require 'rdf/redland'
require 'rdf/redland/constants'
require 'rdf/redland/schemas/foaf'

class TestQuery < Test::Unit::TestCase
  include Redland
 
  def setup
    @foaf = Namespace.new('http://xmlns.com/foaf/0.1/')
    @exns = Namespace.new('http://example.org/')
  end

  def test_model_query_api()
    model = Model.new()

    query = Query.new("SELECT ?a ?b ?c WHERE { ?a ?b ?c}", "sparql", nil, nil)
    results = query.execute(model)
  end

  def test_query_api()
    model = Model.new()

    query = Query.new("SELECT ?a ?b ?c WHERE { ?a ?b ?c} ", "sparql", nil, nil)
    results = model.query_execute(query)
  end

  def test_model_query_results()
    model = Model.new()

    lit = Node.new("baz")
    st = Statement.new(@exns['subject'], @exns['pred'], lit)
    model.add_statement(st)

    query = Query.new("SELECT ?a ?b ?c WHERE { ?a ?b ?c }", "sparql", nil, nil)
    results = query.execute(model)
    assert(results != nil)

    # Result should be a single variable binding result with three values
    assert(results.is_bindings?)
    assert_equal(3, results.bindings_count)
    assert_equal(results.binding_value(0), @exns['subject'])
    assert_equal(results.binding_value(1), @exns['pred'])
    assert_equal(results.binding_value(2), lit)

    values = [@exns['subject'], @exns['pred'], lit]
    assert_equal(results.binding_values(), values)

    assert_equal(results.binding_name(0), "a")
    assert_equal(results.binding_name(1), "b")
    assert_equal(results.binding_name(2), "c")

    assert_equal(results.binding_names(), ["a", "b", "c"])

    results.next()
    assert(results.finished?)
  end

  def test_model_query_ask()
    model = Model.new()

    lit = Node.new("baz")
    st = Statement.new(@exns['subject'], @exns['pred'], lit)
    model.add_statement(st)

    query = Query.new("ASK WHERE { ?a ?b ?c }", "sparql", nil, nil)
    results = query.execute(model)
    assert(results != nil)

    # Result should be a true boolean

    assert(results.is_boolean?)
    assert(results.get_boolean?)
  end

  def test_model_query_construct()
    model = Model.new()

    @exns = Namespace.new('http://example.org/')
    lit = Node.new("baz")
    st = Statement.new(@exns['subject'], @exns['pred'], lit)
    model.add_statement(st)

    query = Query.new("CONSTRUCT { ?a ?b ?c . ?b ?a ?c } WHERE { ?a ?b ?c }", "sparql", nil, nil)
    results = query.execute(model)
    assert(results != nil)

    # Result should be a graph of two triples

    assert(results.is_graph?)
    stream = results.as_stream()
    assert(stream != nil)

    statement = stream.current()
    assert_equal(statement, st)
    stream.next()

    statement = stream.current()
    st2 = Statement.new(@exns['pred'], @exns['subject'], lit)
    assert_equal(statement, st2)
    stream.next()

    assert(stream.end?)
  end


  def test_model_query_serialize_bindings()
    model = Model.new()

    lit = Node.new("baz")
    st = Statement.new(@exns['subject'], @exns['pred'], lit)
    model.add_statement(st)

    query = Query.new("SELECT ?s ?p ?o WHERE {?s ?p ?o}", "sparql", nil, nil)
    results = query.execute(model)
    assert(results != nil)

    string = results.to_string(
      Uri.new("http://www.w3.org/2005/sparql-results#"),
      Uri.new("http://example.org/")
    )

    # length of a SPARQL results format string - might change
    assert(string.length() > 400)
    assert_match(%r|<binding name="s"><uri>http://example.org/subject</uri></binding>|, string)
    assert_match(%r|<binding name="p"><uri>http://example.org/pred</uri></binding>|, string)
    assert_match(%r|<binding name="o"><literal>baz</literal></binding>|, string)
  end


  def test_model_query_serialize_ask()
    model = Model.new()

    lit = Node.new("baz")
    st = Statement.new(@exns['subject'], @exns['pred'], lit)
    model.add_statement(st)

    query = Query.new("ASK WHERE { ?a ?b ?c }", "sparql", nil, nil)
    results = query.execute(model)
    assert(results != nil)

    string = results.to_string(Uri.new("http://www.w3.org/2001/sw/DataAccess/json-sparql/"), Uri.new("http://example.org/"))

    # length of a SPARQL results format string - might change
    assert(string.length() > 30)
    assert_match(%r|"boolean" : true|, string)
  end


  def test_model_query_serialize_construct()
    model = Model.new()

    @exns = Namespace.new('http://example.org/')
    lit = Node.new("baz")
    st = Statement.new(@exns['subject'], @exns['pred'], lit)
    model.add_statement(st)

    query = Query.new("CONSTRUCT { ?a ?b ?c . ?b ?a ?c } WHERE { ?a ?b ?c }", "sparql", nil, nil)
    results = query.execute(model)
    assert(results != nil)

    string = results.to_string()

    # length of an RDF/XML string - might change
    assert(string.length() > 300)
    assert_match(%r|<ns0:pred xmlns:ns0="http://example.org/">baz</ns0:pred>|, string)
    assert_match(%r|<ns0:subject xmlns:ns0="http://example.org/">baz</ns0:subject>|, string)
  end


  def test_model_query_serialize_bindings_json()
    model = Model.new()

    lit = Node.new("baz")
    st = Statement.new(@exns['subject'], @exns['pred'], lit)
    model.add_statement(st)

    query = Query.new("SELECT ?a ?b ?c WHERE { ?a ?b ?c }", "sparql", nil, nil)
    results = query.execute(model)
    assert(results != nil)

    string = results.to_string(Uri.new("http://www.w3.org/2001/sw/DataAccess/json-sparql/"), Uri.new("http://example.org/"))

    # length of a SPARQL results format string in JSON - might change
    assert(string.length() > 300)
    assert_match(%r|"vars": \[ "a", "b", "c" \]|, string)
    assert_match(%r|"a" : \{ "type": "uri", "value": "http://example.org/subject" \}|, string)
    assert_match(%r|"b" : \{ "type": "uri", "value": "http://example.org/pred" \}|, string)
    assert_match(%r|"c" : \{ "type": "literal", "value": "baz" \}|, string)
  end

end

