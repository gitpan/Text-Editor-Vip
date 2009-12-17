#play the game of "regex or divide?"

sin / ...
time / ...
localtime / ...
caller / ...
        eof / ...

# Got those right? How about these?

use constant FOO => 35;
FOO / ...

use Fcntl qw(LOCK_SH);
LOCK_SH / ...

#now some of your own:

sub no_args ();
sub one_arg ($);
sub normal (@);

no_args / ...
one_arg / ...
normal / ...

# same problem, different file

use Random::Module qw(aaa bbb ccc);
aaa / ...
bbb / ...
ccc / ...

#So now you have to parse OUTSIDE the file to get your answer. And as if that wasn't enough, let's get weird:

BEGIN {
  eval (time % 2 ? 'sub zany ();' : 'sub zany (@);');
}
zany / ...

#

sin  / 25 ; # / ; die "this dies!";
time / 25 ; # / ; die "this doesn't die";
 
