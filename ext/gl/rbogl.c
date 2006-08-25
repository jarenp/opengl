/*
 * Last edit by previous maintainer:
 * 2003/08/17 03:46:15, yoshi
 *
 * $Date: 2006/07/09 02:31:19 $
 * $Author: john $
 *
 * Copyright (C) 1999 - 2005 Yoshi <yoshi@giganet.net>
 * Copyright (C) 2006 John M. Gabriele <jmg3000@gmail.com>
 *
 * This program is distributed under the terms of the MIT license.
 * See the included COPYRIGHT file for the terms of this license.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifdef __APPLE__
#include <OpenGL/gl.h>
#elif defined WIN32
#include <windows.h>
#include <GL/gl.h>
#else
#include <GL/gl.h>
#endif

#include "rbogl.h"

/* -------------------------------------------------------------------- */
#ifdef _NO_NUM2DBL_
extern double num2double( VALUE val )
{
    struct RFloat* flt;
    if (NIL_P(val)) return 0;
    flt = RFLOAT(f_float(0, val));
    return flt->value;
}
#endif

/* -------------------------------------------------------------------- */
extern int ary2cint( arg, cary, maxlen )
VALUE arg;
int cary[];
int maxlen;
{
    int i;
    struct RArray* ary;
    VALUE entry;
    ary = RARRAY(rb_Array(arg));
    if (maxlen < 1)
        maxlen = ary->len;
    else
        maxlen = maxlen < ary->len ? maxlen : ary->len;
    for (i=0; i < maxlen; i++)
    {
        entry = rb_ary_entry((VALUE)ary,i);
        cary[i] = NUM2INT(entry);
    }
    return i;
}

/* -------------------------------------------------------------------- */
extern int ary2cflt(arg, cary, maxlen)
VALUE arg;
float cary[];
int maxlen;
{
    int i;
    struct RArray* ary;
    ary = RARRAY(rb_Array(arg));
    if (maxlen < 1)
        maxlen = ary->len;
    else
        maxlen = maxlen < ary->len ? maxlen : ary->len;
    for (i=0; i < maxlen; i++)
        cary[i] = (float)NUM2DBL(rb_ary_entry((VALUE)ary,i));
    return i;
}

/* -------------------------------------------------------------------- */
extern int ary2cdbl(arg, cary, maxlen)
VALUE arg;
double cary[];
int maxlen;
{
    int i;
    struct RArray* ary;
    ary = RARRAY(rb_Array(arg));
    if (maxlen < 1)
        maxlen = ary->len;
    else
        maxlen = maxlen < ary->len ? maxlen : ary->len;
    for (i=0; i < maxlen; i++)
        cary[i] = NUM2DBL(rb_ary_entry((VALUE)ary,i));
    return i;
}

/* -------------------------------------------------------------------- */
extern void mary2ary(src, ary)
VALUE src;
VALUE ary;
{
    struct RArray* tmp_ary;
    int i;
    tmp_ary = RARRAY(rb_Array(src));
    for (i = 0; i < tmp_ary->len; i++)
    {
        if (TYPE(tmp_ary->ptr[i]) == T_ARRAY)
            mary2ary((VALUE)tmp_ary, ary);
        else
            rb_ary_push(ary, tmp_ary->ptr[i]);
    }
}

/* -------------------------------------------------------------------- */
extern void ary2cmat4x4(ary, cary)
VALUE ary;
double cary[];
{
    int i,j;
    RArray *ary_r,*ary_c;
    memset(cary, 0x0, sizeof(double[4*4]));
    ary_c = RARRAY(rb_Array(ary));
    if (TYPE(ary_c->ptr[0]) != T_ARRAY)
        ary2cdbl((VALUE)ary_c, cary, 16);
    else
    {
        for (i = 0; i < ary_c->len && i < 4; i++)
        {
            ary_r = RARRAY(rb_Array(ary_c->ptr[i]));
            for(j = 0; j < ary_r->len && j < 4; j++)
                cary[i*4+j] = (GLdouble)NUM2DBL(ary_r->ptr[j]);
        }
    }
}

/* -------------------------------------------------------------------- */
/*Need to find proper size for glReadPixels array*/
int glformat_size(GLenum format)
{
    switch(format)
    {
        case GL_COLOR_INDEX:
        case GL_RED:
        case GL_GREEN:
        case GL_BLUE:
        case GL_ALPHA:
        case GL_STENCIL_INDEX:
        case GL_DEPTH_COMPONENT:
        case GL_LUMINANCE:
            return 1;

        case GL_LUMINANCE_ALPHA:
            return 2;

        case GL_RGB:
#ifdef GL_BGR_EXT
        case GL_BGR_EXT:
#endif
            return 3;

        case GL_RGBA:
#ifdef GL_BGRA_EXT
        case GL_BGRA_EXT:
#endif
#ifdef GL_ABGR_EXT
        case GL_ABGR_EXT:
#endif
            return 4;
        case 1:
        case 2:
        case 3:
        case 4:
            return format;
        default:
            return -1;
    }
}

/* -------------------------------------------------------------------- */
int gltype_size(GLenum type)
{
    switch(type)
    {
        case GL_BYTE:
        case GL_UNSIGNED_BYTE:
            return 8;

        case GL_SHORT:
        case GL_UNSIGNED_SHORT:
            return 16;

        case GL_INT:
        case GL_UNSIGNED_INT:
        case GL_FLOAT:
            return 32;

        case GL_BITMAP:
            return 1;

        default:
            return -1;
    }
}

/* -------------------------------------------------------------------- */
VALUE allocate_buffer_with_string( int size )
{
    return rb_str_new(NULL, size);
}

/* -------------------------------------------------------------------- */
void Init_opengl()
{
  Init_GL();
  /* RxINC: InitializeGLU(); */
}
