# -*- Mode: Perl -*-
#
# Parser.pm - Redland Perl RDF Parser module
#
# Copyright (C) 2000-2005 David Beckett - http://www.dajobe.org/
# Copyright (C) 2000-2005 University of Bristol - http://www.bristol.ac.uk/
# 
# This package is Free Software and part of Redland http://librdf.org/
# 
# It is licensed under the following three licenses as alternatives:
#   1. GNU Lesser General Public License (LGPL) V2.1 or any newer version
#   2. GNU General Public License (GPL) V2 or any newer version
#   3. Apache License, V2.0 or any newer version
# 
# You may not use this file except in compliance with at least one of
# the above three licenses.
# 
# See LICENSE.html or LICENSE.txt at the top of this package for the
# full license terms.
# 
# 
#

package RDF::Redland::Parser;

use strict;

use RDF::Redland::Stream;

=pod

=head1 NAME

RDF::Redland::Parser - Redland RDF Syntax Parsers Class

=head1 SYNOPSIS

  use RDF::Redland;

  ...
  my $parser=new RDF::Redland::Parser("rdfxml");
  my $parser2=new RDF::Redland::Parser(undef, "application/rdf+xml);

  # Return as an RDF::Redland::Stream
  my $stream=$parser->parse_as_stream($source_uri, $base_uri);
  
  # Store in an RDF::Redland::Model
  $parser->parse_into_model($source_uri, $base_uri, $model);

=head1 DESCRIPTION

This class represents parsers of various syntaxes that can deliver a
RDF model either as a RDF::Redland::Stream of RDF::Redland::Statement objects or
directly into an RDF::Redland::Model object.

=cut

######################################################################

=pod

=head1 CONSTRUCTORS

=over

=item new [NAME [MIME_TYPE [URI]]]

Create a new RDF::Redland::Parser object for a syntax parser named I<NAME>,
with MIME Type I<MIME_TYPE> and/or URI I<URI>.  Any field can be undef
or omitted; if all are omitted, a parser that provides MIME Type 
application/rdf+xml will be requested.

=cut

# CONSTRUCTOR
# (main)
sub new ($;$$$) {
  my($proto,$name,$mime_type,$uri)=@_;
  my $class = ref($proto) || $proto;
  my $self  = {};
  my $reduri = undef;

  if(defined $uri) {
    $reduri=$uri->{URI};
  }

  $self->{PARSER}=&RDF::Redland::CORE::librdf_new_parser($RDF::Redland::World->{WORLD},$name,$mime_type,$reduri);
  return undef if !$self->{PARSER};

  bless ($self, $class);
  return $self;
}

=pod

=back

=cut

sub DESTROY ($) {
  warn "RDF::Redland::Parser DESTROY\n" if $RDF::Redland::Debug;
  &RDF::Redland::CORE::librdf_free_parser(shift->{PARSER});
}

=head1 METHODS

=over

=item parse_as_stream SOURCE_URI BASE_URI

Parse the syntax at the RDF::Redland::URI I<SOURCE_URI> with optional base
RDF::Redland::URI I<BASE_URI>.  If the base URI is given then the content is
parsed as if it was at the base URI rather than the source URI.

Returns an RDF::Redland::Stream of RDF::Redland::Statement objects or
undef on failure.

=cut

sub parse_as_stream ($$$) {
  my($self,$uri,$base_uri)=@_;
  my $rbase_uri=$base_uri ? $base_uri->{URI} : undef;
  my $stream=&RDF::Redland::CORE::librdf_parser_parse_as_stream($self->{PARSER},$uri->{URI}, $rbase_uri);
  return undef if !$stream;
  return new RDF::Redland::Stream($stream,$self);
}

=item parse_into_model SOURCE_URI BASE_URI MODEL [HANDLER]

Parse the syntax at the RDF::Redland::URI I<SOURCE_URI> with optional base
RDF::Redland::URI I<BASE_URI> into RDF::Redland::Model I<MODEL>.  If the base URI is
given then the content is parsed as if it was at the base URI rather
than the source URI.

If the optional I<HANDLER> is given, it is a reference to a sub with the signature
  sub handler($$$$$$$$$) {
    my($code, $level, $facility, $message, $line, $column, $byte, $file, $uri)=@_;
    ...
  }
that receives errors in parsing.

=cut

sub parse_into_model ($$$$;$) {
  my($self,$uri,$base_uri,$model,$handler)=@_;
  if($handler) {
    &RDF::Redland::set_log_handler($handler);
  }
  my $rbase_uri=$base_uri ? $base_uri->{URI} : undef;
  my $rc=&RDF::Redland::CORE::librdf_parser_parse_into_model($self->{PARSER},$uri->{URI},$rbase_uri,$model->{MODEL});
  if($handler) {
    &RDF::Redland::reset_log_handler();
  }
  return $rc;
}

=item parse_string_as_stream STRING BASE_URI

Parse the syntax in I<STRING> with required base
RDF::Redland::URI I<BASE_URI>.

Returns an RDF::Redland::Stream of RDF::Redland::Statement objects or
undef on failure.

=cut

sub parse_string_as_stream ($$$) {
  my($self,$string,$base_uri)=@_;
  my $rbase_uri=$base_uri ? $base_uri->{URI} : undef;
  my $stream=&RDF::Redland::CORE::librdf_parser_parse_string_as_stream($self->{PARSER},$string, $rbase_uri);
  return undef if !$stream;
  return new RDF::Redland::Stream($stream,$self);
}

=item parse_string_into_model STRING BASE_URI MODEL [HANDLER]

Parse the syntax in I<STRING> with required base
RDF::Redland::URI I<BASE_URI> into RDF::Redfland::Model I<MODEL>.

If the optional I<HANDLER> is given, it is a reference to a sub with the signature
  sub handler($$$$$$$$$) {
    my($code, $level, $facility, $message, $line, $column, $byte, $file, $uri)=@_;
    ...
  }
that receives errors in parsing.

=cut

sub parse_string_into_model ($$$$;$) {
  my($self,$string,$base_uri,$model,$handler)=@_;
  if($handler) {
    &RDF::Redland::set_log_handler($handler);
  }
  my $rbase_uri=$base_uri ? $base_uri->{URI} : undef;
  my $rc=&RDF::Redland::CORE::librdf_parser_parse_string_into_model($self->{PARSER},$string,$rbase_uri,$model->{MODEL});
  if($handler) {
    &RDF::Redland::reset_log_handler();
  }
  return $rc;
}

=item feature URI [VALUE]

Get/set a parser feature.  The feature is named via RDF::Redland::URI
I<URI> and the value is a RDF::Redland::Node.  If I<VALUE> is given,
the feature is set to that value, otherwise the current value is
returned.

=cut

sub feature ($$;$) {
  my($self,$uri,$value)=@_;

  warn "RDF::Redland::Parser->feature('$uri', '$value')\n"
    if $RDF::Redland::Debug;
  $uri=RDF::Redland::URI->new($uri)
    unless ref $uri;

  if(!defined $value) {
    $value=&RDF::Redland::CORE::librdf_parser_get_feature($self->{PARSER},
							  $uri->{URI});
    return $value ? RDF::Redland::Node->_new_from_object($value,1) : undef;
  }

  $value=RDF::Redland::LiteralNode->new($value)
    unless ref $value;

  return &RDF::Redland::CORE::librdf_parser_set_feature($self->{PARSER},
							$uri->{URI},
							$value->{NODE})

}


=item namespaces_seen

Get the set of namespace declarations seen during parsing as a
hash of key:prefix string (may be ''), value: RDF::Redland::URI objects.

=cut

sub namespaces_seen($) {
  my $self=shift;

  my $count=&RDF::Redland::CORE::librdf_parser_get_namespaces_seen_count($self->{PARSER});
  my(%namespaces)=();
  for (my $offset=0; $offset < $count; $offset++) {
    my $prefix=&RDF::Redland::CORE::librdf_parser_get_namespaces_seen_prefix($self->{PARSER}, $offset);
    $prefix ||= '';
    my $uri=&RDF::Redland::CORE::librdf_parser_get_namespaces_seen_uri($self->{PARSER}, $offset);
    my $ruri=$uri ?  RDF::Redland::URI->_new_from_object($uri) : undef;
    $namespaces{$prefix}=$ruri;
    }
  return %namespaces;
}


=pod

=back

=head1 SEE ALSO

L<RDF::Redland::URI>

=head1 AUTHOR

Dave Beckett - http://www.dajobe.org/

=cut

1;
