/*
 * Copyright (C) 2007 Jan Dvorak <jan.dvorak@kraxnet.cz>
 *
 * This program is distributed under the terms of the MIT license.
 * See the included MIT-LICENSE file for the terms of this license.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/* Functions and macros for datatype conversion between Ruby and C */

/*
   Fast inline conversion functions as a replacement for the ones in libruby.
   FIXNUM_P is simple logical AND check so it comes first, TYPE() is simple function,
   and specified in header file so it can be inlined. For conversion, FIX2LONG is
   simple right shift, and RFLOAT()-> just pointer dereference. For converting
   Fixnum and Float types (which accounts for 99.9% of things you would want to pass
   to OpenGL), there is large performance boost as result.

	 Also ruby 'true' and 'false' are converted to GL_TRUE/GL_FALSE for compatibility, and
	 finally, we fallback to library functions for any other data types (and error handling).
*/
#define FASTCONV(_name_,_type_,_convfix_,_convfallback_) \
static inline _type_ _name_(val) \
VALUE val; \
{ \
	if (FIXNUM_P(val)) \
		return (_type_) _convfix_(val); \
\
	if (TYPE(val) == T_FLOAT) \
		return (_type_)(RFLOAT(val)->value); \
\
	if ((val) == Qtrue) \
		return (_type_)(GL_TRUE); \
\
	if ((val) == Qfalse || (val) == Qnil) \
		return (_type_)(GL_FALSE); \
\
	return (_convfallback_(val)); \
}

FASTCONV(num2double,double,FIX2LONG,rb_num2dbl)
#if SIZEOF_INT < SIZEOF_LONG
FASTCONV(num2int,long,FIX2LONG,rb_num2int)
FASTCONV(num2uint,unsigned long,FIX2ULONG,rb_num2uint)
#else
FASTCONV(num2int,long,FIX2LONG,(int)NUM2LONG)
FASTCONV(num2uint,unsigned long,FIX2ULONG,(unsigned int)NUM2ULONG(x))
#endif

#undef NUM2DBL
#define NUM2DBL num2double

#undef NUM2INT
#define NUM2INT num2int

#undef NUM2UINT
#define NUM2UINT num2uint

#undef FASTCONV

/* For conversion between ruby and GL boolean values */
#define GLBOOL2RUBY(x) (x)==GL_TRUE? Qtrue : Qfalse
#define RUBYBOOL2GL(x) (x)==Qtrue? GL_TRUE : GL_FALSE

/* For conversion between ruby array (or object that can be converted to array) and C array.
   The C array has to be preallocated by calling function. */
#define ARY2CTYPE(_type_,_convert_) \
static inline int ary2c##_type_( arg, cary, maxlen ) \
VALUE arg; \
GL##_type_ cary[]; \
int maxlen; \
{ \
    int i; \
    struct RArray* ary; \
    ary = RARRAY(rb_Array(arg)); \
    if (maxlen < 1) \
        maxlen = ary->len; \
    else \
        maxlen = maxlen < ary->len ? maxlen : ary->len; \
    for (i=0; i < maxlen; i++) \
        cary[i] = (GL##_type_)_convert_(rb_ary_entry((VALUE)ary,i)); \
    return i; \
}

ARY2CTYPE(int,NUM2INT)
ARY2CTYPE(uint,NUM2UINT)
ARY2CTYPE(byte,NUM2INT)
ARY2CTYPE(ubyte,NUM2INT)
ARY2CTYPE(short,NUM2INT)
ARY2CTYPE(ushort,NUM2INT)
ARY2CTYPE(boolean,NUM2INT)
ARY2CTYPE(float,NUM2DBL)
ARY2CTYPE(double,NUM2DBL)

#define ary2cflt ary2cfloat
#define ary2cdbl ary2cdouble

#undef ARY2CTYPE

/* Converts either array or object responding to #to_a to C-style array */
#define ARY2CMAT(_type_) \
static inline void ary2cmat##_type_(rary, cary, cols, rows) \
VALUE rary; \
_type_ cary[]; \
int cols,rows; \
{ \
	int i; \
\
	rary = rb_Array(rary); \
	rary = rb_funcall(rary,rb_intern("flatten"),0); \
\
	if (RARRAY(rary)->len != cols*rows) \
		rb_raise(rb_eArgError, "passed array/matrix must have %i*%i elements",cols,rows); \
\
	for (i=0; i < cols*rows; i++) \
		cary[i] = (_type_) NUM2DBL(rb_ary_entry(rary,i)); \
}

ARY2CMAT(double)
ARY2CMAT(float)
#undef ARY2CMAT
