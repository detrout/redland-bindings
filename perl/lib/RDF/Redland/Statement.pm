# -*- Mode: Perl -*-
#
# Statement.pm - Redland Perl RDF Statement module
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

package RDF::Redland::Statement;

use strict;

use RDF::Redland::Node;

=pod

=head1 NAME

RDF::Redland::Statement - Redland RDF Statement Class

=head1 SYNOPSIS

  use RDF::Redland;
  my $statement1=new RDF::Redland::Statement($statement);
  my $statement2=new RDF::Redland::Statement($subject,$predicate,$object);
  ...

  if($statement->subject->equals($node)) { 
    ...
  }

=head1 DESCRIPTION

Manipulate RDF statements which comprise three RDF::Redland::Node objects.
Also used for I<partial> statements which can have empty parts and
are used for matching statements in statement queries of the
model - see the L<RDF::Redland::Model>.

=cut

######################################################################

=pod

=head1 CONSTRUCTORS

=over

=item new NODE NODE NODE|STATEMENT

Create a new statement from nodes or copy an existing statement.

If three I<NODE>s are given, make a new statement from them.
Each Node can be a Redland::RDF:Node, a Redland::RDF::URI,
a perl URI or a string literal.
Otherwise I<STATEMENT> must be an existing statement to copy.

=cut

sub new ($;$$$) {
  my($proto,@args)=@_;
  my $class = ref($proto) || $proto;
  my $self  = {};

  if(scalar(@args)==3) {
    for (@args) {
      next if !defined $_;
      if(my $class=ref $_) {
	$_=&RDF::Redland::Node::_ensure($_);
	die "Cannot make a Node from an object of class $class\n"
	  unless $_;
      } else {
	$_=&RDF::Redland::CORE::librdf_new_node_from_uri_string($RDF::Redland::World->{WORLD},$_);
      }
    } # end for args
    $self->{STATEMENT}=&RDF::Redland::CORE::librdf_new_statement_from_nodes($RDF::Redland::World->{WORLD}, @args);
  } elsif (scalar(@args) == 1) {
    my $s=$args[0];
    if(!ref($s) || ref($s) ne 'RDF::Redland::Statement') {
      die "RDF::Redland::Statement::new - Cannot copy a statement object not of class RDF::Redland::Statement\n";
    }
    $self->{STATEMENT}=&RDF::Redland::CORE::librdf_new_statement_from_statement($RDF::Redland::World->{WORLD}, $s->{STATEMENT});
  } elsif (scalar(@args) == 0) {
    $self->{STATEMENT}=&RDF::Redland::CORE::librdf_new_statement($RDF::Redland::World->{WORLD});
  } else {
    die "RDF::Redland::Statement::new - bad arguments.  Either give one argument to copy a statement or three to build from nodes.\n";
  }
  return undef if !$self->{STATEMENT};

  bless ($self, $class);
  return $self;
}


=item clone

Copy a RDF::Redland::Statement.

=cut

sub clone ($$) {
  my($statement)=@_;
  my $class = ref($statement);
  my $self  = {};

  if(!$class || $class ne 'RDF::Redland::Statement') {
    die "RDF::Redland::Statement::clone - Cannot copy a statement object not of class RDF::Redland::Statement\n";
  }

  $self->{STATEMENT}=&RDF::Redland::CORE::librdf_new_statement_from_statement($statement->{STATEMENT});
  return undef if !$self->{STATEMENT};

  bless ($self, $class);
  return $self;
}

sub new_from_statement ($$) {
  my($proto,$statement)=@_;
  return $statement->clone;
}

sub new_from_nodes ($$$$) {
  my($proto,$s,$p,$o)=@_;
  return RDF::Redland::Statement->new($s,$p,$o);
}

# internal constructor to build a new object from a statement created
# by librdf e.g. from the result of a stream->next operation
# It always makes a new Redland Statement
sub _new_from_object ($$) {
  my($proto,$object)=@_;
  return undef if !$object;
  my $class = ref($proto) || $proto;
  my $self  = {};

  $self->{STATEMENT}=&RDF::Redland::CORE::librdf_new_statement_from_statement($object);
  bless ($self, $class);
  return $self;
}

=pod

=back

=cut

sub DESTROY ($) {
  my $self=shift;
  warn "RDF::Redland::Statement DESTROY $self\n" if $RDF::Redland::Debug;
  if($self->{STATEMENT}) {
    &RDF::Redland::CORE::librdf_free_statement($self->{STATEMENT});
  }
  warn "RDF::Redland::Statement DESTROY done\n" if $RDF::Redland::Debug;
}

=head1 METHODS

=over

=item subject [SUBJECT]

Get/set the statement subject.  When a RDF::Redland::Node I<SUBJECT>
is given, sets the subject of the statement, otherwise returns a
reference to the statement RDF::Redland::Node subject.

=cut

sub subject ($;$) {
  my($self,$subject)=@_;

  return RDF::Redland::Node->_new_from_object(&RDF::Redland::CORE::librdf_statement_get_subject(shift->{STATEMENT}))
    unless $subject;

  my $s=&RDF::Redland::CORE::librdf_new_node_from_node($subject->{NODE});
  return &RDF::Redland::CORE::librdf_statement_set_subject($self->{STATEMENT},$s);
}

=item predicate [PREDICATE]

Get/set the statement predicate.  When RDF::Redland::Node
I<PREDICATE> is given, sets the predicate of the statement, otherwise
returns a reference to the statement RDF::Redland::Node predicate.

=cut

sub predicate ($;$) {
  my($self,$predicate)=@_;
  
  return RDF::Redland::Node->_new_from_object(&RDF::Redland::CORE::librdf_statement_get_predicate(shift->{STATEMENT}))
    unless $predicate;

  my $p=&RDF::Redland::CORE::librdf_new_node_from_node($predicate->{NODE});
  return &RDF::Redland::CORE::librdf_statement_set_predicate($self->{STATEMENT},$p);
}

=item object [OBJECT]

Get/set the statement object.  When RDF::Redland::Node I<OBJECT> is given, sets
the object of the statement, otherwise returns a reference to the
statement RDF::Redland::Node object.

=cut

sub object ($;$) {
  my($self,$object)=@_;

  return RDF::Redland::Node->_new_from_object(&RDF::Redland::CORE::librdf_statement_get_object(shift->{STATEMENT}))
    unless $object;

  my $o=&RDF::Redland::CORE::librdf_new_node_from_node($object->{NODE});
  return &RDF::Redland::CORE::librdf_statement_set_object($self->{STATEMENT},$o);
}

=item as_string

Return the statement formatted as a string (UTF-8 encoded).

=cut

sub as_string ($) {
  &RDF::Redland::CORE::librdf_statement_to_string(shift->{STATEMENT});
}

=item equals STATEMENT

Return non zero if this statement is equal to STATEMENT

=cut

sub equals ($$) {
  my($self,$statement)=@_;
  &RDF::Redland::CORE::librdf_statement_equals($self->{STATEMENT}, $statement->{STATEMENT});
}

=pod

=back


=head1 OLD METHODS

=over

=item new_from_nodes SUBJECT PREDICATE OBJECT

Create a new RDF::Redland::Statement with the given
RDF::Redland::Node objects as parts (or undef when empty for a
I<partial> statement).  Use instead:

  $a=new RDF::Redland::Statement($subject, $predicate, $object);

=item new_from_statement STATEMENT

Create a new RDF::Redland::Statement object from
RDF::Redland::Statement I<STATEMENT> (copy constructor).
Use instead:

  $s=$old_statement->clone;

=cut


=back

=head1 SEE ALSO

L<RDF::Redland::Node>

=head1 AUTHOR

Dave Beckett - http://www.dajobe.org/

=cut

1;
