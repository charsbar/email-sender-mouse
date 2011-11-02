package Email::Sender::Mouse::Success::Partial;
BEGIN {
  $Email::Sender::Mouse::Success::Partial::VERSION = '0.110001';
}
use Mouse;
extends 'Email::Sender::Mouse::Success';
# ABSTRACT: a report of partial success when delivering


use Email::Sender::Mouse::Failure::Multi;

has failure => (
  is  => 'ro',
  isa => 'Email::Sender::Mouse::Failure::Multi',
  required => 1,
);

__PACKAGE__->meta->make_immutable;
no Mouse;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Success::Partial - a report of partial success when delivering

=head1 VERSION

version 0.110001

=head1 DESCRIPTION

These objects indicate that some deliver was accepted for some recipients and
not others.  The success object's C<failure> attribute will return a
L<Email::Sender::Mouse::Failure::Multi> describing which parts of the delivery failed.

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

