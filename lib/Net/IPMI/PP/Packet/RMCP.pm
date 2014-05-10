package Net::IPMI::PP::Packet::RMCP;
use parent 'Net::IPMI::PP::Packet';

use strict;
use warnings;
use Carp;

my @fields = (
  { format => 'C', name => 'ver' },
  { format => 'C', name => 'reserved' },
  { format => 'C', name => 'sequence' },
  { format => 'C', name => 'classid' },
);

sub new {
  my $class = shift;
  croak __PACKAGE__ . "::new called with no arguments" unless defined $class;

  my $data = ($class eq __PACKAGE__ ? shift : $class);
  croak "new called with no arguments" unless defined $data;
  croak "Too many arguments to new" if @_ > 0;

  my $self = bless { fields => \@fields };
  return $self->SUPER::new($data);
}

1;
