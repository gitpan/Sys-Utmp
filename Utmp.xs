#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <utmp.h>

#ifdef NOUTFUNCS

#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#ifdef BSD
#define _NO_UT_ID
#define _NO_UT_TYPE
#define _NO_UT_PID
#define ut_user ut_name
#endif

/*
   define these so it still works as documented :)
*/

#ifndef USER_PROCESS
#define EMPTY           0       /* No valid user accounting information.  */

#define RUN_LVL         1       /* The system's runlevel.  */
#define BOOT_TIME       2       /* Time of system boot.  */
#define NEW_TIME        3       /* Time after system clock changed.  */
#define OLD_TIME        4       /* Time when system clock changed.  */

#define INIT_PROCESS    5       /* Process spawned by the init process.  */
#define LOGIN_PROCESS   6       /* Session leader of a logged in user.  */
#define USER_PROCESS    7       /* Normal process.  */
#define DEAD_PROCESS    8       /* Terminated process.  */

#define ACCOUNTING      9
#endif

static int ut_fd = -1;

static char _ut_name[] = _PATH_UTMP;

void utmpname(char *filename)
{
   strcpy(_ut_name, filename);
}

void setutent(void)
{
    if (ut_fd < 0)
    {
       if ((ut_fd = open(_ut_name, O_RDONLY)) < 0) 
       {
            croak("Can't open %s",_ut_name);
        }
    }

    lseek(ut_fd, (off_t) 0, SEEK_SET);
}

void endutent(void)
{
    if (ut_fd > 0)
    {
        close(ut_fd);
    }

    ut_fd = -1;
}

struct utmp *getutent(void) 
{
    static struct utmp s_utmp;
    int readval;

    if (ut_fd < 0)
    {
        setutent();
    }

    if ((readval = read(ut_fd, &s_utmp, sizeof(s_utmp))) < sizeof(s_utmp))
    {
        if (readval == 0)
        {
            return NULL;
        }
        else if (readval < 0) 
        {
            croak("Error reading %s", _ut_name);
        } 
        else 
        {
            croak("Partial record in %s [%d bytes]", _ut_name, readval );
        }
    }
    return &s_utmp;
}

#endif

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

static double
constant__HAVE_UT_T(char *name, int len, int arg)
{
    switch (name[10 + 0]) {
    case 'V':
	if (strEQ(name + 10, "V")) {	/* _HAVE_UT_T removed */
#ifdef _HAVE_UT_TV
	    return _HAVE_UT_TV;
#else
	    goto not_there;
#endif
	}
    case 'Y':
	if (strEQ(name + 10, "YPE")) {	/* _HAVE_UT_T removed */
#ifdef _HAVE_UT_TYPE
	    return _HAVE_UT_TYPE;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant__(char *name, int len, int arg)
{
    if (1 + 8 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[1 + 8]) {
    case 'H':
	if (strEQ(name + 1, "HAVE_UT_HOST")) {	/* _ removed */
#ifdef _HAVE_UT_HOST
	    return _HAVE_UT_HOST;
#else
	    goto not_there;
#endif
	}
    case 'I':
	if (strEQ(name + 1, "HAVE_UT_ID")) {	/* _ removed */
#ifdef _HAVE_UT_ID
	    return _HAVE_UT_ID;
#else
	    goto not_there;
#endif
	}
    case 'P':
	if (strEQ(name + 1, "HAVE_UT_PID")) {	/* _ removed */
#ifdef _HAVE_UT_PID
	    return _HAVE_UT_PID;
#else
	    goto not_there;
#endif
	}
    case 'T':
	if (!strnEQ(name + 1,"HAVE_UT_", 8))
	    break;
	return constant__HAVE_UT_T(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_UT(char *name, int len, int arg)
{
    if (2 + 1 >= len ) {
	errno = EINVAL;
	return 0;
    }
    switch (name[2 + 1]) {
    case 'H':
	if (strEQ(name + 2, "_HOSTSIZE")) {	/* UT removed */
#ifdef UT_HOSTSIZE
	    return UT_HOSTSIZE;
#else
	    goto not_there;
#endif
	}
    case 'L':
	if (strEQ(name + 2, "_LINESIZE")) {	/* UT removed */
#ifdef UT_LINESIZE
	    return UT_LINESIZE;
#else
	    goto not_there;
#endif
	}
    case 'N':
	if (strEQ(name + 2, "_NAMESIZE")) {	/* UT removed */
#ifdef UT_NAMESIZE
	    return UT_NAMESIZE;
#else
	    goto not_there;
#endif
	}
    case 'U':
	if (strEQ(name + 2, "_UNKNOWN")) {	/* UT removed */
#ifdef UT_UNKNOWN
	    return UT_UNKNOWN;
#else
	    goto not_there;
#endif
	}
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant_U(char *name, int len, int arg)
{
    switch (name[1 + 0]) {
    case 'S':
	if (strEQ(name + 1, "SER_PROCESS")) {	/* U removed */
#ifdef USER_PROCESS
	    return USER_PROCESS;
#else
	    goto not_there;
#endif
	}
    case 'T':
	return constant_UT(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static double
constant(char *name, int len, int arg)
{
    errno = 0;
    switch (name[0 + 0]) {
    case 'A':
	if (strEQ(name + 0, "ACCOUNTING")) {	/*  removed */
#ifdef ACCOUNTING
	    return ACCOUNTING;
#else
	    goto not_there;
#endif
	}
    case 'B':
	if (strEQ(name + 0, "BOOT_TIME")) {	/*  removed */
#ifdef BOOT_TIME
	    return BOOT_TIME;
#else
	    goto not_there;
#endif
	}
    case 'D':
	if (strEQ(name + 0, "DEAD_PROCESS")) {	/*  removed */
#ifdef DEAD_PROCESS
	    return DEAD_PROCESS;
#else
	    goto not_there;
#endif
	}
    case 'E':
	if (strEQ(name + 0, "EMPTY")) {	/*  removed */
#ifdef EMPTY
	    return EMPTY;
#else
	    goto not_there;
#endif
	}
    case 'I':
	if (strEQ(name + 0, "INIT_PROCESS")) {	/*  removed */
#ifdef INIT_PROCESS
	    return INIT_PROCESS;
#else
	    goto not_there;
#endif
	}
    case 'L':
	if (strEQ(name + 0, "LOGIN_PROCESS")) {	/*  removed */
#ifdef LOGIN_PROCESS
	    return LOGIN_PROCESS;
#else
	    goto not_there;
#endif
	}
    case 'N':
	if (strEQ(name + 0, "NEW_TIME")) {	/*  removed */
#ifdef NEW_TIME
	    return NEW_TIME;
#else
	    goto not_there;
#endif
	}
    case 'O':
	if (strEQ(name + 0, "OLD_TIME")) {	/*  removed */
#ifdef OLD_TIME
	    return OLD_TIME;
#else
	    goto not_there;
#endif
	}
    case 'R':
	if (strEQ(name + 0, "RUN_LVL")) {	/*  removed */
#ifdef RUN_LVL
	    return RUN_LVL;
#else
	    goto not_there;
#endif
	}
    case 'U':
	return constant_U(name, len, arg);
    case '_':
	return constant__(name, len, arg);
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}


MODULE = Sys::Utmp		PACKAGE = Sys::Utmp		

PROTOTYPES: DISABLE

double
constant(sv,arg)
    PREINIT:
	STRLEN		len;
    INPUT:
	SV *		sv
	char *		s = SvPV(sv, len);
	int		arg
    CODE:
	RETVAL = constant(s,len,arg);
    OUTPUT:
	RETVAL



void
getutent(self)
SV *self
   PPCODE:
     AV *ut;
     HV *meth_stash;
     struct utmp *utent;
     IV ut_tv;
     char *_ut_id;
     IV _ut_pid;
     IV _ut_type; 
     SV *ut_ref;
     char *ut_host;
     utent = getutent();
     ut = newAV();
     if ( utent )
     {
#ifdef _NO_UT_ID
       _ut_id = "";
#else
       _ut_id = utent->ut_id;
#endif
#ifdef _NO_UT_TYPE
       _ut_type = 7;
#else
       _ut_type = utent->ut_type;
#endif
#ifdef _NO_UT_PID
       _ut_pid = -1; 
#else
       _ut_pid = utent->ut_pid;
#endif
#ifdef _HAVE_UT_TV
       ut_tv = (IV)utent->ut_tv.tv_sec;
#else
       ut_tv = (IV)utent->ut_time;
#endif
#ifdef _HAVE_UT_HOST
       ut_host = utent->ut_host;
#else
       ut_host = strdup("");
#endif

       if ( GIMME_V == G_ARRAY )
       {
         EXTEND(SP,7);
         PUSHs(sv_2mortal(newSVpv(utent->ut_user,0)));
         PUSHs(sv_2mortal(newSVpv(_ut_id,0)));
         PUSHs(sv_2mortal(newSVpv(utent->ut_line,0)));
         PUSHs(sv_2mortal(newSViv(_ut_pid)));
         PUSHs(sv_2mortal(newSViv(_ut_type)));
         PUSHs(sv_2mortal(newSVpv(ut_host,0)));
         PUSHs(sv_2mortal(newSViv(ut_tv)));
       }
       else
       {
         av_push(ut,newSVpv(utent->ut_user,0));
         av_push(ut,newSVpv(_ut_id,0));
         av_push(ut,newSVpv(utent->ut_line,0));
         av_push(ut,newSViv(_ut_pid));
         av_push(ut,newSViv(_ut_type));
         av_push(ut,newSVpv(ut_host,0));
         av_push(ut,newSViv(ut_tv));
         EXTEND(SP,1);
         meth_stash = gv_stashpv("Sys::Utmp::Utent",1);
         ut_ref = newRV((SV *)ut);
         sv_bless(ut_ref, meth_stash);
         PUSHs(sv_2mortal(ut_ref));
       }
     }
     else
     {
        XSRETURN_EMPTY;
     }


void
setutent(self)
SV *self
   PPCODE:
    setutent();

void
endutent(self)
SV *self
   PPCODE:
    endutent();

void
utmpname(self, filename)
SV *self
SV *filename
   PPCODE:
     char *ff;

     ff = SvPV_nolen(filename);
     utmpname(ff);

