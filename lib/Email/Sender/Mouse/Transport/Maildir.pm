package Email::Sender::Mouse::Transport::Maildir;
BEGIN {
  $Email::Sender::Mouse::Transport::Maildir::VERSION = '0.110001';
}
use Mouse;
with 'Email::Sender::Mouse::Transport';
# ABSTRACT: deliver mail to a maildir on disk

use Errno ();
use Fcntl;
use File::Path;
use File::Spec;

use Sys::Hostname;


my $HOSTNAME;
BEGIN { ($HOSTNAME = hostname) =~ s/\..*//; }
sub _hostname { $HOSTNAME }

my $MAILDIR_TIME    = 0;
my $MAILDIR_COUNTER = 0;

has dir => (
  is  => 'ro',
  required => 1,
  default  => sub { File::Spec->catdir(File::Spec->curdir, 'Maildir') },
);

sub send_email {
  my ($self, $email, $env) = @_;

  my $dupe = Email::Abstract->new(\do { $email->as_string });

  $dupe->set_header('X-Email-Sender-Mouse-From' => $env->{from});
  $dupe->set_header('X-Email-Sender-Mouse-To'   => @{ $env->{to} });

  $self->_ensure_maildir_exists;

  $self->_add_lines_header($dupe);
  $self->_update_time;

  $self->_deliver_email($dupe);

  return $self->success;
}

sub _ensure_maildir_exists {
  my ($self) = @_;

  for my $dir (qw(cur tmp new)) {
    my $subdir = File::Spec->catdir($self->dir, $dir);
    next if -d $subdir;

    Email::Sender::Mouse::Failure->throw("couldn't create $subdir: $!")
      unless File::Path::mkpath($subdir);
  }
}

sub _add_lines_header {
  my ($class, $email) = @_;
  return if $email->get_header("Lines");
  my @lines = split /\n/, $email->get_body;
  $email->set_header("Lines", scalar @lines);
}

sub _update_time {
  my $time = time;
  if ($MAILDIR_TIME != $time) {
    $MAILDIR_TIME    = $time;
    $MAILDIR_COUNTER = 0;
  } else {
    $MAILDIR_COUNTER++;
  }
}

sub _deliver_email {
  my ($self, $email) = @_;

  my ($tmp_filename, $tmp_fh) = $self->_delivery_fh;

  # if (eval { $email->can('stream_to') }) {
  #  eval { $mail->stream_to($fh); 1 } or return;
  #} else {
  print $tmp_fh $email->as_string
    or Email::Sender::Mouse::Failure->throw("could not write to $tmp_filename: $!");

  close $tmp_fh
    or Email::Sender::Mouse::Failure->throw("error closing $tmp_filename: $!");

  my $ok = rename(
    File::Spec->catfile($self->dir, 'tmp', $tmp_filename),
    File::Spec->catfile($self->dir, 'new', $tmp_filename),
  );

  Email::Sender::Mouse::Failure->throw("could not move $tmp_filename from tmp to new")
    unless $ok;
}

sub _delivery_fh {
  my ($self) = @_;

  my $hostname = $self->_hostname;

  my ($filename, $fh);
  until ($fh) {
    $filename = join q{.}, $MAILDIR_TIME, $$, ++$MAILDIR_COUNTER, $hostname;
    my $filespec = File::Spec->catfile($self->dir, 'tmp', $filename);
    sysopen $fh, $filespec, O_CREAT|O_EXCL|O_WRONLY;
    Email::Sender::Mouse::Failure->throw("cannot create $filespec for delivery: $!")
      unless $fh or $!{EEXIST};
  }

  return ($filename, $fh);
}

__PACKAGE__->meta->make_immutable;
no Mouse;
1;

__END__
=pod

=head1 NAME

Email::Sender::Mouse::Transport::Maildir - deliver mail to a maildir on disk

=head1 VERSION

version 0.110001

=head1 DESCRIPTION

This transport delivers into a maildir.  The maildir's location may be given as
the F<dir> argument to the constructor, and defaults to F<Maildir> in the
current directory (at the time of transport initialization).

If the directory does not exist, it will be created.

Three headers will be added:

 * X-Email-Sender-Mouse-From - the envelope sender
 * X-Email-Sender-Mouse-To   - the envelope recipients (one header per rcpt)
 * Lines               - the number of lines in the body

=head1 AUTHOR

Ricardo Signes <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Ricardo Signes.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

