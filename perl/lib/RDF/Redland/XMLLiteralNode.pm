# -*- Mode: Perl -*-
#
# XMLLiteralNode.pm - Redland Perl RDF URI Node module
#
# Copyright (C) 2005 David Beckett - http://www.dajobe.org/
# Copyright (C) 2005 University of Bristol - http://www.bristol.ac.uk/
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

package RDF::Redland::XMLLiteralNode;

use strict;

use vars qw(@ISA);

@ISA='RDF::Redland::Node';


=pod

=head1 NAME

RDF::Redland::XMLLiteralNode - Redland RDF URI Node Class

=head1 SYNOPSIS

  use RDF::Redland;
  my $node1=new RDF::Redland::XMLLiteralNode("<tag>content</tag>");

=head1 DESCRIPTION

This class represents RDF Typed Literals for XML in the RDF graph.
See L<RDF::Redland::Node> for the methods on this object.

=cut

######################################################################

=pod

=head1 CONSTRUCTOR

=over

=item new STRING

Create a new XML datatyped literal node for the XML in I<STRING>.

=cut

# CONSTRUCTOR
sub new ($$) {
  my($proto,$arg)=@_;
  my $class = ref($proto) || $proto;
  my $self  = {};

  return RDF::Redland::Node->new_xml_literal($arg);
}

=back

=head1 SEE ALSO

L<RDF::Redland::Node>

=head1 AUTHOR

Dave Beckett - http://www.dajobe.org/

=cut

1;
