
use Test;
BEGIN { plan tests => 4 };
use Sys::Utmp ':constants';
ok(1); 

my $utmp = Sys::Utmp->new();

ok(2);

eval 
{
   while( my $utent = $utmp->getutent() )
   {
      my $t = $utent->ut_line();
      $t    = $utent->user_process();
    }
};
if ( $@ )
{
  ok(0);
}
else
{
  ok(3);
}
 
eval
{
  $utmp->setutent();
};
if ($@)
{
  ok(0);
}
else
{
  ok(4);
}


