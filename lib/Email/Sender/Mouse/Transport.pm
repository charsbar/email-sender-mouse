package Email::Sender::Mouse::Transport;
BEGIN {
  $Email::Sender::Mouse::Transport::VERSION = '0.110001';
}
use Mouse::Role;
# ABSTRACT: a role for email transports


with 'Email::Sender::Mouse::Role::CommonSending';

sub is_simple {
  my ($self) = @_;
  return if $self->allow_partial_success;
  return 1;
}

sub allow_partial_success { 0 }

no Mouse::Role;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Transport - a role for email transports

=head1 VERSION

version 0.110001

=head1 DESCRIPTION

Email::Sender::Mouse::Transport is a Mouse role to aid in writing classes used to send
mail.  For the most part, its behavior comes entirely from the role
L<Email::Sender::Mouse::Role::CommonSending>, which it includes. The important
difference is that Transports are often intended to be used by
L<Email::Sender::Mouse::Simple>, and they provide two methods related to that purpose.

=for Pod::Coverage is_simple allow_partial_success

First, they provide an C<allow_partial_success> method which returns true or
false to indicate whether the transport will ever signal partial success.

Second, they provide an C<is_simple> method, which returns true if the
transport is suitable for use with Email::Sender::Mouse::Simple.  By default, this
method returns the inverse of C<allow_partial_success>.

It is B<imperative> that these methods be accurate to prevent
Email::Sender::Mouse::Simple users from sending partially successful transmissions.
Partial success is a complex case that almost all users will wish to avoid at
all times.

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

