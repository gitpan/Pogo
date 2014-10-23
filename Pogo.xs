/* Pogo.xs - 1999 Sey */
#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include "nstring.h"
#include "pogocall.h"
#define _INXS_
#include "pogomain.h"

MODULE = Pogo		PACKAGE = Pogo::Var

char*
Pvar::get_class()

void
Pvar::set_class(name)
	char* name

void 
Pvar::begin_transaction()

void 
Pvar::abort_transaction()

void 
Pvar::end_transaction()

int
Pvar::_call(func, argref)
	SV* func
	SV* argref

int
Pvar::equal(var)
	Pvar* var

int
Pvar::wait_modification(sec = 0)
	unsigned sec

unsigned
Pvar::object_id()

MODULE = Pogo		PACKAGE = Pogo::Scalar		

Pscalar*
Pscalar::new(pogo = NULL)
	Pogo* pogo

void
Pscalar::DESTROY()

Pvar* 
Pscalar::get()

void     
Pscalar::set(val)
	Pvar* val

MODULE = Pogo		PACKAGE = Pogo::Array	

Parray*
Parray::new(size = 1, pogo = NULL)
	Pogo* pogo
	unsigned size

void
Parray::DESTROY()

Pvar*
Parray::get(idx)
	unsigned idx

void
Parray::set(idx, val)
	unsigned idx
	Pvar* val

unsigned
Parray::get_size()

void
Parray::set_size(size)
	unsigned size

void
Parray::clear()

void
Parray::push(val)
	Pvar* val

Pvar*
Parray::pop()

void
Parray::insert(idx, val)
	unsigned idx
	Pvar* val

Pvar*
Parray::remove(idx)
	unsigned idx

MODULE = Pogo		PACKAGE = Pogo::Hash		

Phash*
Phash::new(size = 256, pogo = NULL)
	Pogo* pogo
	unsigned size

void
Phash::DESTROY()

Pvar*
Phash::get(key)
	char* key

void
Phash::set(key, val)
	char* key
	Pvar* val

int
Phash::exists(key)
	char* key

Pvar*
Phash::remove(key)
	char* key

void
Phash::clear()

char*
Phash::first_key()

char*
Phash::next_key(key)
	char* key

MODULE = Pogo		PACKAGE = Pogo::Htree		

Phtree*
Phtree::new(size = 65536, pogo = NULL)
	Pogo* pogo
	unsigned size

void
Phtree::DESTROY()

Pvar*
Phtree::get(key)
	char* key

void
Phtree::set(key, val)
	char* key
	Pvar* val

int
Phtree::exists(key)
	char* key

Pvar*
Phtree::remove(key)
	char* key

void
Phtree::clear()

char*
Phtree::first_key()

char*
Phtree::next_key(key)
	char* key

MODULE = Pogo		PACKAGE = Pogo::Btree		

Pbtree*
Pbtree::new(pogo = NULL)
	Pogo* pogo

void
Pbtree::DESTROY()

Pvar*
Pbtree::get(key)
	char* key

void
Pbtree::set(key, val)
	char* key
	Pvar* val

int
Pbtree::exists(key)
	char* key

Pvar*
Pbtree::remove(key)
	char* key

void
Pbtree::clear()

char*
Pbtree::first_key()

char*
Pbtree::last_key()

char*
Pbtree::next_key(key)
	char* key

char*
Pbtree::prev_key(key)
	char* key

char*
Pbtree::find_key(key)
	char* key

MODULE = Pogo		PACKAGE = Pogo::Ntree		

Pntree*
Pntree::new(pogo = NULL)
	Pogo* pogo

void
Pntree::DESTROY()

Pvar*
Pntree::get(key)
	char* key

void
Pntree::set(key, val)
	char* key
	Pvar* val

int
Pntree::exists(key)
	char* key

Pvar*
Pntree::remove(key)
	char* key

void
Pntree::clear()

char*
Pntree::first_key()

char*
Pntree::last_key()

char*
Pntree::next_key(key)
	char* key

char*
Pntree::prev_key(key)
	char* key

char*
Pntree::find_key(key)
	char* key

MODULE = Pogo		PACKAGE = Pogo		

Pogo*
Pogo::new(cfgfile = NULL)
	char* cfgfile

void
Pogo::DESTROY()

int
Pogo::open(cfgfile)
	char* cfgfile

void
Pogo::close()

Pbtree*
Pogo::root()

void
Pogo::begin_transaction()

void
Pogo::abort_transaction()

void
Pogo::end_transaction()

