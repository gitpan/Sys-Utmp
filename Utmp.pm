#*****************************************************************************
#*                                                                           *
#*                            Netscalibur UK                                 *
#*                                                                           *
#*                                                                           *
#*****************************************************************************
#*                                                                           *
#*      MODULE      :  Sys::Utmp                                             *
#*                                                                           *
#*      AUTHOR      :  JNS                                                   *
#*                                                                           *
#*      DESCRIPTION :  Object(ish) interface to utmp information             *
#*                                                                           *
#*                                                                           *
#*****************************************************************************
#*                                                                           *
#*      $Log: Utmp.pm,v $
#*      Revision 1.1  2001/02/09 22:27:30  gellyfish
#*      Initial revision
#*
#*                                                                           *
#*                                                                           *
#*****************************************************************************

package Sys::Utmp;

=head1 NAME

Sys::Utmp - Object(ish) Interface to UTMP files.

=head1 SYNOPSIS

  use Sys::Utmp;

  my $utmp = Sys::Utmp->new();
  
  while ( my $utent =  $utmp->getutent() )
  {
     if ( $utent->user_process )
     {
        print $utent->ut_user,"\n";
     }
   }

   $utmp->endutent;

=head1 DESCRIPTION

Sys::Utmp provides a vaguely object oriented interface to the Unix user
accounting file ( usually /etc/utmp ). Currently it only supports systems
that provide the getutent library function (which excludes BSD ).
 
This may not be the module that you are looking for - there is a User::Utmp
which provides a different procedural interface and may well be more complete
for your purposes.

=head2 METHODS

=over 4

=item new

The constructor of the class.

=item getutent

Iterates of the records in the utmp file returning a Sys::Utmp::Utent object
for each record in turn - the methods that are available on these objects
are descrived below in 'PER RECORD METHODS'

=item setutent

Rewinds the file pointer on the utmp filehandle so repeated searches can be
done.

=item endutent

Closes the file handle on the utmp file.

=back

=head2 PER RECORD METHODS

As mentioned above the getutent method returns an object of the type
Sys::Utmp::Utent which provides methods for accessing the fields in the
utmp record.  There are also methods for determining the type of the record.

The access methods relate to the common names for the members of the C
struct utent - those provided are the superset from the Gnu implementation and
may not be available on all systems: where they are not they will return the
empty string.

=over 4

=item  ut_user

Returns the use this record was created for if this is a record for a user
process.  Some systems may return other information depending on the record
type.  If no user was set this will be the empty string.

=item  ut_id

The identifier for this record - it might be the inittab tag or some other
system dependent value.

=item ut_line

For user process records this will be the name of the terminalor line that the
user is connected on.

=item  ut_pid

The process ID of the process that created this record.

=item ut_type

The type of the record this will have a value corresponding to one of the
constants (not all of these may be available on all systems and there may
well be others which should be described in the getutent manpage or in
/usr/include/utmp.h ) :

=over 2

=item ACCOUNTING - record was created for system accounting purposes.

=item BOOT_TIME - the record was created at boot time.

=item DEAD_PROCESS - The process that created this record has terminated.

=item EMPTY  - record probably contains no other useful information.

=item INIT_PROCESS - this is a record for process created by init.

=item LOGIN_PROCESS - this record was created for a login process (e.g. getty).

=item NEW_TIME  - record created when the system time has been set.

=item OLD_TIME - record recording the old tme when the system time has been set.

=item RUN_LVL - records the time at which the current run level was started.

=item USER_PROCESS - record created for a user process (e.g. a login )

=back

for convenience Sys::Utmp::Utent provides methods which are lower case
versions of the constant names which return true if the record is of that
type.

=item ut_host

On systems which support this the method will return the hostname of the 
host for which the process that created the record was started - for example
for a telnet login.

=item ut_time

The time in epoch seconds wt which the record was created.

=back

=cut

use strict;
use Carp;

require Exporter;
require DynaLoader;

use vars qw(
            @ISA
            %EXPORT_TAGS
            @EXPORT_OK
            @EXPORT
            $VERSION
            $AUTOLOAD
           );

@ISA = qw(Exporter DynaLoader);

my @constants = qw(
                   ACCOUNTING
                   BOOT_TIME
                   DEAD_PROCESS
                   EMPTY
                   INIT_PROCESS
                   LOGIN_PROCESS
                   NEW_TIME
                   OLD_TIME
                   RUN_LVL
                   USER_PROCESS
                  );

%EXPORT_TAGS = (  
                 'constants' => [ @constants ] 
               );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'constants'} } );

@EXPORT = qw();

($VERSION) = q$Revision: 1.1 $ =~ /([\d.]+)/;

sub new 
{
  my ( $proto, $args ) = @_;

  my $self = {};

  my $class = ref($proto) || $proto;

  bless $self, $class;

}

sub AUTOLOAD 
{
    my ( $self ) = @_;

    my $constname;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "& not defined" if $constname eq 'constant';
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) 
    {
	    croak "Your vendor has not defined Sys::Utmp macro $constname";
    }
    {
	no strict 'refs';
	*{$AUTOLOAD} = sub { $val };
    }
    goto &$AUTOLOAD;
}

sub DESTROY
{
  my ( $self ) = @_;

  $self->endutent()
}

1;

bootstrap Sys::Utmp $VERSION;

package Sys::Utmp::Utent;

use Carp;

use vars qw(
             @methods
             %meth2index
             %const2meth
             $AUTOLOAD
           );

@methods = qw(
              ut_user
              ut_id
              ut_line
              ut_pid
              ut_type
              ut_host
              ut_time
             );


@meth2index{@methods} = ( 0 .. $#methods );

$const2meth{lc $_ } = $_ foreach @constants;

sub AUTOLOAD
{
   my ( $self ) = @_;

   return if ( $AUTOLOAD =~ /DESTROY/ );

  (my $methname = $AUTOLOAD) =~ s/.*:://;


  {
    no strict 'refs';

     if ( exists $meth2index{$methname} )
     { 
        *{$AUTOLOAD} = sub { 
                             my ($self) = @_;
                             return $self->[$meth2index{$methname}];
                            };
      }
      elsif ( exists $const2meth{$methname})
      {
         *{$AUTOLOAD} = sub {
                              my ( $self ) = @_;
                              return $self->ut_type == &{"Sys::Utmp::$const2meth{$methname}"};
                             };
       }
       else
       {
         croak "$methname not defined" unless exists $meth2index{$methname};
       }

       goto &{$AUTOLOAD};
   }
}

1;

__END__

=head2 EXPORT

No methods or constants are exported by default.

=head2 Exportable constants

These constants are exportable under the tag ':constants':

     ACCOUNTING
     BOOT_TIME
     DEAD_PROCESS
     EMPTY
     INIT_PROCESS
     LOGIN_PROCESS
     NEW_TIME
     OLD_TIME
     RUN_LVL
     USER_PROCESS

=item BUGS

Probably.  This module has been tested on Linux, Solaris and SCO Openserver
and found to work on those platforms.  It doesnt work on BSD at the moment.
If you have difficulty building the module or it doesnt behave as expected
then please contact the author including if appropriate your /usr/include/utmp.h

=head1 AUTHOR

Jonathan Stowe, E<lt>Jonathan.Stowe@netscalibur.co.ukE<gt>

=head1 LICENCE

This Software is Copyright Netscalibur UK 2001.  

This Software is published as-is with no warranty express or implied.

This is free software and can be distributed under the same terms as
Perl itself.

=head1 SEE ALSO

L<perl>.

=cut
