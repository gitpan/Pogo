/* pogocall.c - 1999 Sey */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "pogocall.h"

int _pogo_call_sv(void* func, void* argref) {
	SV *	codesv;
	SV *	argvref;
	AV *	av;
	I32		j, ac, outs;
	int		result;
	dSP;
	codesv = func;
	argvref = argref;
	ENTER;
	PUSHMARK(sp);
	if( argvref ) {
		if( !SvROK(argvref) || SvTYPE(SvRV(argvref)) != SVt_PVAV )
			croak("array reference required");
		av = (AV*)SvRV(argvref);
		ac = av_len(av);
		for( j = 0; j <= ac; j++ ) {
			XPUSHs(*(av_fetch(av,j,0)));
		}
	}
	PUTBACK;
	outs = perl_call_sv(codesv, G_SCALAR);
	SPAGAIN;
	result = outs == 1 ? POPi : 0;
	PUTBACK;
	LEAVE;
	return result;
}
