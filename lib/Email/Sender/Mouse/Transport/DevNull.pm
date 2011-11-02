package Email::Sender::Mouse::Transport::DevNull;
BEGIN {
  $Email::Sender::Mouse::Transport::DevNull::VERSION = '0.110001';
}
use Mouse;
with 'Email::Sender::Mouse::Transport';
# ABSTRACT: happily throw away your mail


sub send_email { return $_[0]->success }

__PACKAGE__->meta->make_immutable;
no Mouse;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Transport::DevNull - happily throw away your mail

=head1 VERSION

version 0.110001

=head1 DESCRIPTION

This class implements L<Email::Sender::Mouse::Transport>.  Any mail sent through a
DevNull transport will be silently discarded.

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

