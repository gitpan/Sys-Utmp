use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'Sys::Utmp',
    'VERSION_FROM'	=> 'Utmp.pm',
    'PREREQ_PM'		=> {},
    ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'Utmp.pm',
       AUTHOR     => 'Jonathan Stowe <jonathan.stowe@netscalibur.co.uk>') : ()),
    'LIBS'		=> ['-lc'],
    'DEFINE'		=> '',
    'INC'		=> '' 
);
