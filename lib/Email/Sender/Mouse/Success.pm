package Email::Sender::Mouse::Success;
BEGIN {
  $Email::Sender::Mouse::Success::VERSION = '0.110001';
}
use Mouse;
# ABSTRACT: the result of successfully sending mail


__PACKAGE__->meta->make_immutable;
no Mouse;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Success - the result of successfully sending mail

=head1 VERSION

version 0.110001

=head1 DESCRIPTION

An Email::Sender::Mouse::Success object is just an indicator that an email message was
successfully sent.  Unless extended, it has no properties of its own.

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

