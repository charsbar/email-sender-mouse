#!perl
use strict;
use warnings;
use Test::More tests => 14;

use Email::Sender::Mouse::Util;

{
  package FakeSMTP;
  use Mouse;

  has code    => (is => 'rw');
  has message => (is => 'rw');

  no Mouse;
}

sub smtp { FakeSMTP->new({ code => $_[0], message => $_[1] }); }

my $i = 0;
sub test_fail {
  my ($error, $smtp, $rest, $class, $message) = @_;
  $rest ||= {};
  my $full_class = 'Email::Sender::Mouse::Failure';
  $full_class .= "::$class" if $class;
  $i++;

  my $fail = Email::Sender::Mouse::Util->_failure($error, $smtp, %$rest);

  is(ref $fail, $full_class, "class of failure $i is $full_class");
  is($fail->message, $message, "failure $i has the right message");
}

test_fail('xyzzy', undef,               {}, undef,       'xyzzy');
test_fail('xyzzy', smtp(100 => 'fail'), {}, undef,       'xyzzy: fail');
test_fail('xyzzy', smtp(400 => 'fail'), {}, 'Temporary', 'xyzzy: fail');
test_fail('xyzzy', smtp(500 => 'fail'), {}, 'Permanent', 'xyzzy: fail');

test_fail(undef,   smtp(100 => 'fail'), {}, undef,       'fail');
test_fail(undef,   smtp(400 => 'fail'), {}, 'Temporary', 'fail');
test_fail(undef,   smtp(500 => 'fail'), {}, 'Permanent', 'fail');

