package Email::Sender::Mouse::Failure::Temporary;
BEGIN {
  $Email::Sender::Mouse::Failure::Temporary::VERSION = '0.110001';
}
use Mouse;
extends 'Email::Sender::Mouse::Failure';
# ABSTRACT: a temporary delivery failure

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
no Mouse;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Failure::Temporary - a temporary delivery failure

=head1 VERSION

version 0.110001

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

