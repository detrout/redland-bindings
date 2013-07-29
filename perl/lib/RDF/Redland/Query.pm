# -*- Mode: Perl -*-
#
# Query.pm - Redland Perl RDF Query module
#
# Copyright (C) 2004-2005 David Beckett - http://www.dajobe.org/
# Copyright (C) 2004-2005 University of Bristol - http://www.bristol.ac.uk/
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

package RDF::Redland::Query;

use strict;

use RDF::Redland::Stream;

=pod

=head1 NAME

RDF::Redland::Query - Redland RDF Syntax Query Class

=head1 SYNOPSIS

  use RDF::Redland;

  ...
  my $query=new RDF::Redland::Query($query_string); # default query language
  my $results=$query->execute($model);
  # or my $results=$model->query_execute($query);
  while(!$results->finished) {
    for (my $i=0; $i < $results->bindings_count(); $i++) {
      my $name=$results->binding_name($i);
      my $value=$results->binding_value($i);
      # ... do something with the results
    }
    $results->next_result;
  }

=head1 DESCRIPTION

This class represents queries of various syntaxes over an
RDF::Redland::Model returning a sequence of results that (currently)
bind variable names to RDF::Redland::Node values.

=cut

######################################################################

=pod

=head1 CONSTRUCTORS

=over

=item new QUERY-STRING [BASE-URI [QUERY-LANG-URI [QUERY-LANG]]]

Create a new RDF::Redland::Query object for a query string I<QUERY-STRING>
with optional base URI I<BASE-URI>
IN QUERY language I<QUERY-LANG> or query language URI I<QUERY-LANG-URI>
(both can be undef).
If I<QUERY-LANG-URI> is omitted, the current directory is used as the base URI.
If I<QUERY-LANG-NAME> is undef, the default query language "rdql" is used. 
If I<BASE-URI> is omitted, no base URI is used.

=cut

# CONSTRUCTOR
# (main)
sub new ($;$$$$) {
  my($proto,$query_string,$base_uri,$uri,$language)=@_;
  my $class = ref($proto) || $proto;
  my $self  = {};
  my $redbaseuri = undef;
  my $reduri = undef;
  $language ||= "rdql";

  if(defined $base_uri) {
    $redbaseuri=$base_uri->{URI};
  }
  if(defined $uri) {
    $reduri=$uri->{URI};
  }

  $self->{QUERY}=&RDF::Redland::CORE::librdf_new_query($RDF::Redland::World->{WORLD},$language,$reduri,$query_string,$redbaseuri);
  return undef if !$self->{QUERY};

  bless ($self, $class);
  return $self;
}

=pod

=back

=cut

sub DESTROY ($) {
  warn "RDF::Redland::Query DESTROY\n" if $RDF::Redland::Debug;
  &RDF::Redland::CORE::librdf_free_query(shift->{QUERY});
}

=head1 METHODS

=over

=item execute MODEL

Run the query against model I<MODEL> returning a RDF::Redland::QueryResults
object or undef on failure.


=cut

sub execute ($$) {
  my($self,$model)=@_;
  my $results = &RDF::Redland::CORE::librdf_query_execute($self->{QUERY},$model->{MODEL});
  return $results ? RDF::Redland::QueryResults->new($results) : undef;
}



=pod

=back

=head1 SEE ALSO

L<RDF::Redland::QueryResults>

=head1 AUTHOR

Dave Beckett - http://www.dajobe.org/

=cut

1;
