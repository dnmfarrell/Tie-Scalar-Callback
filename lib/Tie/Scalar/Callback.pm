use strict;
use warnings;
package Tie::Scalar::Callback;

use parent 'Tie::Scalar';

#ABSTRACT: a tied scalar which executes a callback everytime it is used

sub TIESCALAR {
  my ($class, $sub, $val) = @_;

  die 'Must provide an anonymous subroutine argument'
    unless $sub && ref $sub eq 'CODE';

  bless {
    sub => $sub,
    val => $val,
  }, $class;
}

sub STORE {
  my ($self, $val) = @_;
  return $self->{sub}($self, 'STORE', $val);
}

sub FETCH {
  my ($self) = @_;
  return $self->{sub}($self, 'FETCH');
}

sub DESTROY {
  my ($self) = @_;
  return $self->{sub}($self, 'DESTROY');
}

1;

=head1 SYNOPSIS

  # this coderef doubles the scalar's value everytime it's fetched 
  my $coderef = sub {
    my ($self, $event, $val) = @_;

    if ($event eq 'STORE')
    {
      $self->{val} = $val;
    }
    elsif ($event eq 'FETCH')
    {
      my $old_val = $self->{val};
      $self->{val} *= 2;
      return $old_val;
    }
    else # DESTROY
    {
      undef $self;
    }
  };

  tie(my $doubler, 'Tie::Scalar::Callback', $coderef, 1);

  print $doubler; 1
  print $doubler; 2
  print $doubler; 4

=head1 DESCRIPTION

C<Tie::Scalar::Callback> is a class for creating tied scalars which execute
a callback everytime an event occurs on the scalar. There are three types of
event:

=over 4

=item * STORE ($self, 'STORE', $value)

Called anytime a value is assigned to the scalar.

=item * FETCH ($self, 'FETCH')

Called anytime the scalar's value is retrieved.

=item * DESTROY ($self, 'DESTROY')

Called on object destruction.

=back

See the synopsis for an example coderef which handles these events.

=head1 INTERNALS

C<Tie::Scalar::Callback> objects are just anonymous hashes. The coderef is
stored in C<$self->{sub}> and the current value of the scalar in
C<$self->{val}>.

=head1 SEE ALSO

L<Tie::Scalar::Decay|https://metacpan.org/pod/Tie::Scalar::Decay>
L<Tie::Scalar::Ratio|https://metacpan.org/pod/Tie::Scalar::Ratio>

