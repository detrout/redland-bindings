# -*- Mode: Perl -*-
#
# Redland.pm - Redland top level Perl module
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

use RDF::Redland::Iterator;
use RDF::Redland::Model;
use RDF::Redland::Node;
use RDF::Redland::BlankNode;
use RDF::Redland::URINode;
use RDF::Redland::LiteralNode;
use RDF::Redland::XMLLiteralNode;
use RDF::Redland::Parser;
use RDF::Redland::Query;
use RDF::Redland::QueryResults;
use RDF::Redland::Serializer;
use RDF::Redland::Statement;
use RDF::Redland::Storage;
use RDF::Redland::Stream;
use RDF::Redland::URI;

use RDF::Redland::CORE;

package RDF::Redland::World;

sub new ($) {
  my($proto)=@_;
  my $class = ref($proto) || $proto;
  my $self  = {};

  # This line is needed because otherwise will perl will barf a
  # warning (that CANNOT be disabled with no warnings 'once') about
  # an unused variable.
  $_p_librdf_world_s::OWNER = 1;

  $self->{WORLD} = &RDF::Redland::CORE::librdf_new_world();
  &RDF::Redland::CORE::librdf_world_open($self->{WORLD});

  &RDF::Redland::CORE::librdf_perl_world_init($self->{WORLD});

  bless ($self, $class);
  $self->{ME}=$self;
  return $self;
}

sub DESTROY ($) {
  warn "RDF::World DESTROY\n" if $RDF::Debug;
  &RDF::Redland::CORE::librdf_perl_world_finish();
}

sub message ($$$$$$$$$) {
  if(ref $RDF::Redland::Log_Sub) {
    return $RDF::Redland::Log_Sub->(@_);
  }

  my($code, $level, $facility, $message, $line, $column, $byte, $file, $uri)=@_;
  if($level > 3) {
    if(ref $RDF::Redland::Error_Sub) {
      return $RDF::Redland::Error_Sub->($message);
    } else {
      die "Redland error: $message\n";
    }
  } else {
    if(ref $RDF::Redland::Warning_Sub) {
      return $RDF::Redland::Warning_Sub->($message);
    } else {
      warn "Redland warning: $message\n";
    }
  }
  1;
}

package RDF::Redland;

use vars qw($VERSION $Debug $World $Error_Sub $Warning_Sub);

$VERSION= eval sprintf("%s.%02d_%02d_%02d", split(/\./, "1.0.16.1"));

$Debug=0;

$World=new RDF::Redland::World;

$Error_Sub=undef;

$Warning_Sub=undef;

$Log_Sub=undef;

=pod

=head1 NAME

RDF::Redland - Redland RDF Class

=head1 SYNOPSIS

  use RDF::Redland;
  my $storage=new RDF::Redland::Storage("hashes", "test", "new='yes',hash-type='memory'");
  my $model=new RDF::Redland::Model($storage, "");

  ...

=head1 DESCRIPTION

This class initialises the Redland RDF classes.

See the main classes for full detail:
L<RDF::Redland::Node>, 
L<RDF::Redland::BlankNode>, L<RDF::Redland::URINode>,
L<RDF::Redland::LiteralNode>, L<RDF::Redland::XMLLiteralNode>,
L<RDF::Redland::URI>,
L<RDF::Redland::Statement>, L<RDF::Redland::Model>,
L<RDF::Redland::Storage>, L<RDF::Redland::Parser>,
L<RDF::Redland::Query>, L<RDF::Redland::QueryResults>,
L<RDF::Redland::Iterator>, L<RDF::Redland::Stream>
and L<RDF::Redland::RSS>.

=head1 STATIC METHODS

=over

=item set_log_handler SUB

Set I<SUB> as the subroutine to be called on any Redland error, warning
or log message.  The subroutine must have the followign signature:


  sub handler ($$$$$$$$$) {
    my($code, $level, $facility, $message, $line, $column, $byte, $file, $uri)=@_;
    # int error code
    # int log level
    # int facility causing the error (parsing, serializing, ...)
    # string error message
    # int line number (<0 if not relevant)
    # int column number (<0 if not relevant)
    # int byte number (<0 if not relevant)
    # string file name or undef
    # string URI or undef
    
    # ...do something with the information ...
  };

  RDF::Redland::set_log_handler(\&handler);

=cut

sub set_log_handler ($) {
  $Log_Sub=shift;
}


=item reset_log_handler

Reset redland to use the default logging handler, typically printing
the message to stdout or stderr and exiting on a fatal error.

=cut

sub reset_log_handler () {
  $Log_Sub=undef;
}


=item set_error_handler SUB

The method set_log_handler is much more flexible than this and includes
this functionality.

Set I<SUB> as the subroutine to be called on a Redland error with
the error message as the single argument.  For example:

  RDF::Redland::set_error_handler(sub {
    my $msg=shift;
    # Do something with $msg
  });

The default if this is not set, is to run die $msg

=cut

sub set_error_handler ($) {
  $Error_Sub=shift;
}


=item set_warning_handler SUB

The method set_log_handler is much more flexible than this and includes
this functionality.

Set I<SUB> as the subroutine to be called on a Redland warning with
the warning message as the single argument.  For example:

  RDF::Redland::set_warning_handler(sub {
    my $msg=shift;
    # Do something with $msg
  });

The default if this is not set, is to run warn $msg

=cut

sub set_warning_handler ($) {
  $Warning_Sub=shift;
}

=pod

=back

=head1 SEE ALSO

L<RDF::Redland::Node>, 
L<RDF::Redland::BlankNode>, L<RDF::Redland::URINode>,
L<RDF::Redland::LiteralNode>, L<RDF::Redland::XMLLiteralNode>,
L<RDF::Redland::URI>,
L<RDF::Redland::Statement>, L<RDF::Redland::Model>,
L<RDF::Redland::Storage>, L<RDF::Redland::Parser>,
L<RDF::Redland::Query>, L<RDF::Redland::QueryResults>,
L<RDF::Redland::Iterator>, L<RDF::Redland::Stream>
and L<RDF::Redland::RSS>.

=head1 AUTHOR

Dave Beckett - http://www.dajobe.org/

=cut

1;
