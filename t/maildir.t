#!perl
use strict;
use warnings;

use lib 't/lib';
use Test::Email::Sender::Mouse::Util;
use File::Spec ();
use File::Temp ();

use Test::More tests => 5;

use Email::Sender::Mouse::Transport::Maildir;

my $message = readfile('t/messages/simple.msg');

my $maildir   = File::Temp::tempdir(CLEANUP => 1);

my (undef, $failfile) = File::Temp::tempfile(UNLINK => 1);
my $faildir = File::Spec->catdir($failfile, 'Maildir');

my $sender = Email::Sender::Mouse::Transport::Maildir->new({
  dir => $maildir,
});

for (1..2) {
  my $result = $sender->send(
    join('', @$message),
    {
      to   => [ 'rjbs@example.com' ],
      from => 'rjbs@example.biz',
    },
  );

  isa_ok($result, 'Email::Sender::Mouse::Success', "delivery result");
}

my $new = File::Spec->catdir($maildir, 'new');

ok(-d $new, "$new directory exists now");

my @files = grep { $_ !~ /^\./ } <$new/*>;

is(@files, 2, "there are now two delivered messages in the Maildir");

my $lines = readfile($files[0]);

my $simple = Email::Simple->new(join '', @$lines);

is($simple->header('X-Email-Sender-Mouse-To'), 'rjbs@example.com', 'env info in hdr');

