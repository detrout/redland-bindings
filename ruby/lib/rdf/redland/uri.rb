require 'rdf/redland'

module Redland
  class Uri
    
    attr_accessor :uri

    # Initialize a Uri
    #
    #  uri = RDF::Redland::Uri.new('kris')
    #  uri2 = RDF::Redland::Uri.new(uri)
    #  require 'uri'
    #  uri = Uri.parse('http://www.xmlns.com')
    #  uri_from_Uri = RDF::Redland::Uri.new(uri)
    def initialize(uri_string)
      case uri_string
      when String
        @uri = Redland.librdf_new_uri($world.world,uri_string)
      when Uri
        @uri = Redland.librdf_new_uri_from_uri(uri_string.uri)
      when SWIG::TYPE_p_librdf_uri_s
        @uri = Redland.librdf_new_uri_from_uri(uri_string)
      end
      if not @uri then raise RedlandError.new("Unable to create Uri") end
      ObjectSpace.define_finalizer(self,Uri.create_finalizer(@uri))
    end

    # You shouldn't use this. Used internally for cleanup.
    def Uri.create_finalizer(uri)
      proc {|id| # "Finalizer on #{id}"
        #puts "closing uri"
        Redland::librdf_free_uri(uri)
      }
    end

    # Returns a string for this URI
    def to_s
      return Redland.librdf_uri_to_string(@uri)
    end

    # Equivalence. Only works with other URI objects
    def == (other)
      return (Redland.librdf_uri_equals(self.uri,other.uri) != 0)
    end
  end
end #module Redland

