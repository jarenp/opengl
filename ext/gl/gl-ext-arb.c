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

#include "../common/common.h"

/* OpenGL ARB extensions */

/* #3 GL_ARB_transpose_matrix */
#define TRANSPOSEMATRIX_FUNC(_name_,_type_) \
static void (APIENTRY * fptr_gl##_name_)(const _type_[]); \
static VALUE \
gl_##_name_(obj,arg1) \
VALUE obj,arg1; \
{ \
	_type_ m[4*4]; \
	LOAD_GL_EXT_FUNC(gl##_name_,"GL_ARB_transpose_matrix") \
	ary2cmat##_type_(arg1, m, 4, 4); \
	fptr_gl##_name_(m); \
	CHECK_GLERROR \
	return Qnil; \
}

TRANSPOSEMATRIX_FUNC(LoadTransposeMatrixfARB,GLfloat)
TRANSPOSEMATRIX_FUNC(LoadTransposeMatrixdARB,GLdouble)
TRANSPOSEMATRIX_FUNC(MultTransposeMatrixfARB,GLfloat)
TRANSPOSEMATRIX_FUNC(MultTransposeMatrixdARB,GLdouble)

#undef TRANSPOSEMATRIX_FUNC

/* #5 GL_ARB_multisample */
static void (APIENTRY * fptr_glSampleCoverageARB)(GLclampf,GLboolean);
static VALUE gl_SampleCoverageARB(VALUE obj,VALUE arg1,VALUE arg2)
{
	LOAD_GL_EXT_FUNC(glSampleCoverageARB,"GL_ARB_multisample")
	fptr_glSampleCoverageARB((GLclampf)NUM2DBL(arg1),(GLboolean)NUM2INT(arg2));
	CHECK_GLERROR
	return Qnil;
}

/* #26 GL_ARB_vertex_program */
static void (APIENTRY * fptr_glProgramStringARB)(GLenum,GLenum,GLsizei,const void *);
static VALUE gl_ProgramStringARB(VALUE obj,VALUE arg1,VALUE arg2,VALUE arg3)
{
	LOAD_GL_EXT_FUNC(glProgramStringARB,"GL_ARB_vertex_program")
	Check_Type(arg3,T_STRING);
	fptr_glProgramStringARB(NUM2INT(arg1),NUM2INT(arg2),RSTRING(arg3)->len,RSTRING(arg3)->ptr);
	CHECK_GLERROR
	return Qnil;
}

static void (APIENTRY * fptr_glGetProgramivARB)(GLenum,GLenum,GLint *);
static VALUE gl_GetProgramivARB(VALUE obj,VALUE arg1,VALUE arg2)
{
	GLint ret = 0;
	LOAD_GL_EXT_FUNC(glGetProgramivARB,"GL_ARB_vertex_program")
	fptr_glGetProgramivARB(NUM2INT(arg1),NUM2INT(arg2),&ret);
	CHECK_GLERROR
	return INT2NUM(ret);
}

static void (APIENTRY * fptr_glGetProgramStringARB)(GLenum,GLenum,void *string);
static VALUE gl_GetProgramStringARB(VALUE obj,VALUE arg1,VALUE arg2)
{
	GLsizei len = 0;
	char *buffer;
	VALUE ret_buffer;

	LOAD_GL_EXT_FUNC(glGetProgramStringARB,"GL_ARB_vertex_program")
	LOAD_GL_EXT_FUNC(glGetProgramivARB,"GL_ARB_vertex_program")

	fptr_glGetProgramivARB(NUM2INT(arg1),GL_PROGRAM_LENGTH_ARB,&len);
	CHECK_GLERROR
	if (len<=0)
		return rb_str_new2("");
	
	buffer = ALLOC_N(GLchar,len+1);
	memset(buffer,0,sizeof(GLchar) * (len+1));
		fptr_glGetProgramStringARB(NUM2INT(arg1),NUM2INT(arg2),buffer);
	ret_buffer = rb_str_new2(buffer);
	xfree(buffer);

	CHECK_GLERROR
	return Qnil;
}

static void (APIENTRY * fptr_glBindProgramARB)(GLenum,GLuint);
static VALUE gl_BindProgramARB(VALUE obj,VALUE arg1,VALUE arg2)
{
	LOAD_GL_EXT_FUNC(glBindProgramARB,"GL_ARB_vertex_program")
	fptr_glBindProgramARB(NUM2INT(arg1),NUM2UINT(arg2));
	CHECK_GLERROR
	return Qnil;
}

static void (APIENTRY * fptr_glGenProgramsARB)(GLsizei, GLuint *);
static VALUE gl_GenProgramsARB(VALUE obj,VALUE arg1)
{
	GLsizei n;
	GLuint *programs;
	RArray *ret;
	int i;

	LOAD_GL_EXT_FUNC(glGenProgramsARB,"GL_ARB_vertex_program")
	n = (GLsizei)NUM2UINT(arg1);
	programs = ALLOC_N(GLuint, n);
	fptr_glGenProgramsARB(n,programs);
	ret = RARRAY(rb_ary_new2(n));
	for (i = 0; i < n; i++)
		rb_ary_push((VALUE)ret, INT2NUM(programs[i]));
	xfree(programs);
	CHECK_GLERROR
	return (VALUE)ret;
}

static void (APIENTRY * fptr_glDeleteProgramsARB)(GLsizei,const GLuint *);
static VALUE gl_DeleteProgramsARB(VALUE obj,VALUE arg1)
{
	LOAD_GL_EXT_FUNC(glDeleteProgramsARB,"GL_ARB_vertex_program")
	if (TYPE(arg1)==T_ARRAY) {
		GLsizei n;
		GLuint *programs;
		n = RARRAY(arg1)->len;
		programs = ALLOC_N(GLuint,n);
		ary2cuint(arg1,programs,n); 
		fptr_glDeleteProgramsARB( n, programs);
		xfree(programs);
	} else {
		GLuint program;
		program = NUM2INT(arg1);
		fptr_glDeleteProgramsARB( 1, &program);
	}
	CHECK_GLERROR
	return Qnil;
}

static GLboolean (APIENTRY * fptr_glIsProgramARB)(GLuint);
static VALUE gl_IsProgramARB(VALUE obj,VALUE arg1)
{
	GLboolean ret = 0;
	LOAD_GL_EXT_FUNC(glIsProgramARB,"GL_ARB_vertex_program")
	ret = fptr_glIsProgramARB(NUM2UINT(arg1));
	CHECK_GLERROR
	return INT2NUM(ret);
}

GL_EXT_SIMPLE_FUNC_LOAD(EnableVertexAttribArrayARB,1,GLuint,NUM2UINT,"GL_ARB_vertex_program")
GL_EXT_SIMPLE_FUNC_LOAD(DisableVertexAttribArrayARB,1,GLuint,NUM2UINT,"GL_ARB_vertex_program")

extern VALUE g_VertexAttrib_ptr[];

static void (APIENTRY * fptr_glVertexAttribPointerARB)(GLuint,GLint,GLenum,GLboolean,GLsizei,const GLvoid *);
static VALUE gl_VertexAttribPointerARB(VALUE obj,VALUE arg1,VALUE arg2,VALUE arg3,VALUE arg4,VALUE arg5,VALUE arg6)
{
	GLuint index;
	GLuint size;
	GLenum type;
	GLboolean normalized;
	GLsizei stride;

	LOAD_GL_EXT_FUNC(glVertexAttribPointerARB,"GL_ARB_vertex_program")

	index = (GLuint)NUM2UINT(arg1);
	size = (GLuint)NUM2UINT(arg2);
	type = (GLenum)NUM2INT(arg3);
	normalized = (GLboolean)NUM2INT(arg4);
	stride = (GLsizei)NUM2UINT(arg5);
	if (index>_MAX_VERTEX_ATTRIBS)
		rb_raise(rb_eArgError, "Index too large, maximum allowed value '%i'",_MAX_VERTEX_ATTRIBS);

	if (CheckBufferBinding(GL_ARRAY_BUFFER_BINDING)) {
		g_VertexAttrib_ptr[index] = arg6;
		fptr_glVertexAttribPointerARB(index,size,type,normalized,stride,(GLvoid *)NUM2INT(arg6));
	} else {
		Check_Type(arg6, T_STRING);
		rb_str_freeze(arg6);
		g_VertexAttrib_ptr[index] = arg6;
		fptr_glVertexAttribPointerARB(index,size,type,normalized,stride,(GLvoid *)RSTRING(arg6)->ptr);
	}

	CHECK_GLERROR
	return Qnil;
}


static void (APIENTRY * fptr_glGetVertexAttribPointervARB)(GLuint,GLenum,GLvoid **);
static VALUE
gl_GetVertexAttribPointervARB(obj,arg1)
VALUE obj,arg1;
{
	GLuint index;
	LOAD_GL_EXT_FUNC(glGetVertexAttribPointervARB,"GL_ARB_vertex_program")
	index =(GLuint) NUM2INT(arg1);
	if (index>_MAX_VERTEX_ATTRIBS)
		rb_raise(rb_eArgError, "Index too large, maximum allowed value '%i'",_MAX_VERTEX_ATTRIBS);

	return g_VertexAttrib_ptr[index];
}

#define PROGRAMPARAM_FUNC(_name_,_type_,_conv_,_extension_) \
static void (APIENTRY * fptr_gl##_name_)(GLenum,GLuint,_type_,_type_,_type_,_type_); \
static VALUE \
gl_##_name_(obj,arg1,arg2,arg3,arg4,arg5,arg6) \
VALUE obj,arg1,arg2,arg3,arg4,arg5,arg6; \
{ \
	LOAD_GL_EXT_FUNC(gl##_name_,_extension_) \
	fptr_gl##_name_(NUM2UINT(arg1),NUM2UINT(arg2),_conv_(arg3),_conv_(arg4),_conv_(arg5),_conv_(arg6)); \
	CHECK_GLERROR \
	return Qnil; \
}

PROGRAMPARAM_FUNC(ProgramEnvParameter4dARB,GLdouble,NUM2DBL,"GL_ARB_vertex_program")
PROGRAMPARAM_FUNC(ProgramEnvParameter4fARB,GLfloat,NUM2DBL,"GL_ARB_vertex_program")
PROGRAMPARAM_FUNC(ProgramLocalParameter4dARB,GLdouble,NUM2DBL,"GL_ARB_vertex_program")
PROGRAMPARAM_FUNC(ProgramLocalParameter4fARB,GLfloat,NUM2DBL,"GL_ARB_vertex_program")
#undef PROGRAMPARAM_FUNC


#define PROGRAMPARAM_FUNC_V(_name_,_type_,_conv_,_extension_) \
static void (APIENTRY * fptr_gl##_name_)(GLenum,GLuint,const _type_ *); \
static VALUE \
gl_##_name_(obj,arg1,arg2,arg3) \
VALUE obj,arg1,arg2,arg3; \
{ \
	_type_ cary[4]; \
	LOAD_GL_EXT_FUNC(gl##_name_,_extension_) \
	_conv_(arg3,cary,4); \
	fptr_gl##_name_(NUM2UINT(arg1),NUM2UINT(arg2),cary); \
	CHECK_GLERROR \
	return Qnil; \
}

PROGRAMPARAM_FUNC_V(ProgramEnvParameter4dvARB,GLdouble,ary2cdbl,"GL_ARB_vertex_program")
PROGRAMPARAM_FUNC_V(ProgramEnvParameter4fvARB,GLfloat,ary2cflt,"GL_ARB_vertex_program")
PROGRAMPARAM_FUNC_V(ProgramLocalParameter4dvARB,GLdouble,ary2cdbl,"GL_ARB_vertex_program")
PROGRAMPARAM_FUNC_V(ProgramLocalParameter4fvARB,GLfloat,ary2cflt,"GL_ARB_vertex_program")
#undef PROGRAMPARAM_FUNC_V

#define GETPROGRAMPARAM_FUNC(_name_,_type_,_extension_) \
static void (APIENTRY * fptr_gl##_name_)(GLenum,GLuint,_type_ *); \
static VALUE \
gl_##_name_(obj,arg1,arg2) \
VALUE obj,arg1,arg2; \
{ \
	_type_ cary[4] = {0.0,0.0,0.0,0.0}; \
	VALUE ret; \
	int i; \
	LOAD_GL_EXT_FUNC(gl##_name_,_extension_) \
	fptr_gl##_name_(NUM2UINT(arg1),NUM2UINT(arg2),cary); \
	ret = rb_ary_new2(4); \
	for(i=0;i<4;i++); \
			rb_ary_push(ret, rb_float_new(cary[i])); \
	CHECK_GLERROR \
	return ret; \
}

GETPROGRAMPARAM_FUNC(GetProgramEnvParameterdvARB,GLdouble,"GL_ARB_vertex_program")
GETPROGRAMPARAM_FUNC(GetProgramEnvParameterfvARB,GLfloat,"GL_ARB_vertex_program")
GETPROGRAMPARAM_FUNC(GetProgramLocalParameterdvARB,GLdouble,"GL_ARB_vertex_program")
GETPROGRAMPARAM_FUNC(GetProgramLocalParameterfvARB,GLfloat,"GL_ARB_vertex_program")

#undef GETPROGRAMPARAM_FUNC

#define VERTEXATTRIB_FUNC(_name_,_type_,_conv_,_size_,_extension_) \
static void (APIENTRY * fptr_gl##_name_)(GLuint,TYPELIST##_size_(_type_)); \
static VALUE \
gl_##_name_(obj, index ARGLIST##_size_) \
VALUE obj, index ARGLIST##_size_ ; \
{ \
	LOAD_GL_EXT_FUNC(gl##_name_,_extension_) \
	fptr_gl##_name_(NUM2UINT(index),FUNCPARAMS##_size_(_type_,_conv_)); \
	CHECK_GLERROR \
	return Qnil; \
}

VERTEXATTRIB_FUNC(VertexAttrib1dARB,GLdouble,NUM2DBL,1,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib1fARB,GLfloat,NUM2DBL,1,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib1sARB,GLshort,NUM2INT,1,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib2dARB,GLdouble,NUM2DBL,2,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib2fARB,GLfloat,NUM2DBL,2,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib2sARB,GLshort,NUM2INT,2,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib3dARB,GLdouble,NUM2DBL,3,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib3fARB,GLfloat,NUM2DBL,3,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib3sARB,GLshort,NUM2INT,3,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib4dARB,GLdouble,NUM2DBL,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib4fARB,GLfloat,NUM2DBL,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib4sARB,GLshort,NUM2INT,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC(VertexAttrib4NubARB,GLubyte,NUM2UINT,4,"GL_ARB_vertex_program")
#undef VERTEXATTRIB_FUNC


#define VERTEXATTRIB_FUNC_V(_name_,_type_,_conv_,_size_,_extension_) \
static void (APIENTRY * fptr_gl##_name_)(GLuint,_type_ *); \
static VALUE \
gl_##_name_(obj,arg1,arg2) \
VALUE obj,arg1,arg2; \
{ \
	GLuint index; \
	_type_ v[_size_]; \
	LOAD_GL_EXT_FUNC(gl##_name_,_extension_)  \
	index = (GLuint)NUM2UINT(arg1); \
	_conv_(arg2,v,_size_); \
	fptr_gl##_name_(index,v); \
	CHECK_GLERROR \
	return Qnil; \
}

VERTEXATTRIB_FUNC_V(VertexAttrib4NbvARB,GLbyte,ary2cbyte,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4NivARB,GLint,ary2cint,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4NsvARB,GLshort,ary2cshort,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4NubvARB,GLubyte,ary2cubyte,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4NuivARB,GLuint,ary2cuint,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4NusvARB,GLushort,ary2cushort,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4uivARB,GLuint,ary2cuint,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4ubvARB,GLubyte,ary2cubyte,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4usvARB,GLushort,ary2cushort,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4bvARB,GLbyte,ary2cbyte,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4ivARB,GLint,ary2cint,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4dvARB,GLdouble,ary2cdbl,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4fvARB,GLfloat,ary2cflt,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib4svARB,GLshort,ary2cshort,4,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib3dvARB,GLdouble,ary2cdbl,3,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib3fvARB,GLfloat,ary2cflt,3,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib3svARB,GLshort,ary2cshort,3,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib2dvARB,GLdouble,ary2cdbl,2,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib2fvARB,GLfloat,ary2cflt,2,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib2svARB,GLshort,ary2cshort,2,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib1dvARB,GLdouble,ary2cdbl,1,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib1fvARB,GLfloat,ary2cflt,1,"GL_ARB_vertex_program")
VERTEXATTRIB_FUNC_V(VertexAttrib1svARB,GLshort,ary2cshort,1,"GL_ARB_vertex_program")
#undef VERTEXATTRIB_FUNC_V

#define GETVERTEXATTRIB_FUNC(_name_,_type_,_conv_,_extension_) \
static void (APIENTRY * fptr_gl##_name_)(GLuint,GLenum,_type_ *); \
static VALUE \
gl_##_name_(obj,arg1,arg2) \
VALUE obj,arg1,arg2; \
{ \
	GLuint index; \
	GLenum pname; \
	_type_ params[4] = {0,0,0,0}; \
	GLint size; \
	GLint i; \
	VALUE retary; \
	LOAD_GL_EXT_FUNC(gl##_name_,_extension_) \
	index = (GLuint)NUM2UINT(arg1); \
	pname = (GLenum)NUM2INT(arg2); \
	if (pname==GL_CURRENT_VERTEX_ATTRIB) \
		size = 4; \
	else \
		size = 1; \
	fptr_gl##_name_(index,pname,params); \
	retary = rb_ary_new2(size); \
	for(i=0;i<size;i++) \
		rb_ary_push(retary, _conv_(params[i])); \
	CHECK_GLERROR \
	return retary; \
}

GETVERTEXATTRIB_FUNC(GetVertexAttribdvARB,GLdouble,rb_float_new,"GL_ARB_vertex_program")
GETVERTEXATTRIB_FUNC(GetVertexAttribfvARB,GLfloat,rb_float_new,"GL_ARB_vertex_program")
GETVERTEXATTRIB_FUNC(GetVertexAttribivARB,GLint,INT2NUM,"GL_ARB_vertex_program")
#undef GETVERTEXATTRIB_FUNC

/* #39 GL_ARB_color_buffer_float */
GL_EXT_SIMPLE_FUNC_LOAD(ClampColorARB,2,GLenum,NUM2INT,"GL_ARB_color_buffer_float")

void gl_init_functions_ext_arb(VALUE module)
{
/* #3 GL_ARB_transpose_matrix */
	rb_define_module_function(module, "glLoadTransposeMatrixfARB", gl_LoadTransposeMatrixfARB, 1);
	rb_define_module_function(module, "glLoadTransposeMatrixdARB", gl_LoadTransposeMatrixdARB, 1);
	rb_define_module_function(module, "glMultTransposeMatrixfARB", gl_MultTransposeMatrixfARB, 1);
	rb_define_module_function(module, "glMultTransposeMatrixdARB", gl_MultTransposeMatrixdARB, 1);

/* #5 GL_ARB_multisample */
	rb_define_module_function(module, "glSampleCoverageARB", gl_SampleCoverageARB, 2);

/* #26 GL_ARB_vertex_program */
	rb_define_module_function(module, "glProgramStringARB", gl_ProgramStringARB, 3);
	rb_define_module_function(module, "glGetProgramStringARB", gl_GetProgramStringARB, 2);
	rb_define_module_function(module, "glGetProgramivARB", gl_GetProgramivARB, 2);
	rb_define_module_function(module, "glBindProgramARB", gl_BindProgramARB, 2);
	rb_define_module_function(module, "glGenProgramsARB", gl_GenProgramsARB, 1);
	rb_define_module_function(module, "glDeleteProgramsARB", gl_DeleteProgramsARB, 1);
	rb_define_module_function(module, "glIsProgramARB", gl_IsProgramARB, 1);
	rb_define_module_function(module, "glEnableVertexAttribArrayARB", gl_EnableVertexAttribArrayARB, 1);
	rb_define_module_function(module, "glDisableVertexAttribArrayARB", gl_DisableVertexAttribArrayARB, 1);
	rb_define_module_function(module, "glVertexAttribPointerARB", gl_VertexAttribPointerARB, 6);
	rb_define_module_function(module, "glGetVertexAttribPointervARB", gl_GetVertexAttribPointervARB, 1);
	rb_define_module_function(module, "glProgramEnvParameter4dARB", gl_ProgramEnvParameter4dARB, 6);
	rb_define_module_function(module, "glProgramEnvParameter4fARB", gl_ProgramEnvParameter4fARB, 6);
	rb_define_module_function(module, "glProgramLocalParameter4dARB", gl_ProgramLocalParameter4dARB, 6);
	rb_define_module_function(module, "glProgramLocalParameter4fARB", gl_ProgramLocalParameter4fARB, 6);
	rb_define_module_function(module, "glProgramEnvParameter4dvARB", gl_ProgramEnvParameter4dvARB, 3);
	rb_define_module_function(module, "glProgramEnvParameter4fvARB", gl_ProgramEnvParameter4fvARB, 3);
	rb_define_module_function(module, "glProgramLocalParameter4dvARB", gl_ProgramLocalParameter4dvARB, 3);
	rb_define_module_function(module, "glProgramLocalParameter4fvARB", gl_ProgramLocalParameter4fvARB, 3);
	rb_define_module_function(module, "glGetProgramEnvParameterdvARB", gl_GetProgramEnvParameterdvARB, 2);
	rb_define_module_function(module, "glGetProgramEnvParameterfvARB", gl_GetProgramEnvParameterfvARB, 2);
	rb_define_module_function(module, "glGetProgramLocalParameterdvARB", gl_GetProgramLocalParameterdvARB, 2);
	rb_define_module_function(module, "glGetProgramLocalParameterfvARB", gl_GetProgramLocalParameterfvARB, 2);
	rb_define_module_function(module, "glVertexAttrib1dARB", gl_VertexAttrib1dARB, 2);
	rb_define_module_function(module, "glVertexAttrib1fARB", gl_VertexAttrib1fARB, 2);
	rb_define_module_function(module, "glVertexAttrib1sARB", gl_VertexAttrib1sARB, 2);
	rb_define_module_function(module, "glVertexAttrib2dARB", gl_VertexAttrib2dARB, 3);
	rb_define_module_function(module, "glVertexAttrib2fARB", gl_VertexAttrib2fARB, 3);
	rb_define_module_function(module, "glVertexAttrib2sARB", gl_VertexAttrib2sARB, 3);
	rb_define_module_function(module, "glVertexAttrib3dARB", gl_VertexAttrib3dARB, 4);
	rb_define_module_function(module, "glVertexAttrib3fARB", gl_VertexAttrib3fARB, 4);
	rb_define_module_function(module, "glVertexAttrib3sARB", gl_VertexAttrib3sARB, 4);
	rb_define_module_function(module, "glVertexAttrib4NbvARB", gl_VertexAttrib4NbvARB, 2);
	rb_define_module_function(module, "glVertexAttrib4NivARB", gl_VertexAttrib4NivARB, 2);
	rb_define_module_function(module, "glVertexAttrib4NsvARB", gl_VertexAttrib4NsvARB, 2);
	rb_define_module_function(module, "glVertexAttrib4NubARB", gl_VertexAttrib4NubARB, 5);
	rb_define_module_function(module, "glVertexAttrib4NubvARB", gl_VertexAttrib4NubvARB, 2);
	rb_define_module_function(module, "glVertexAttrib4NuivARB", gl_VertexAttrib4NuivARB, 2);
	rb_define_module_function(module, "glVertexAttrib4NusvARB", gl_VertexAttrib4NusvARB, 2);
	rb_define_module_function(module, "glVertexAttrib4bvARB", gl_VertexAttrib4bvARB, 2);
	rb_define_module_function(module, "glVertexAttrib4dARB", gl_VertexAttrib4dARB, 5);
	rb_define_module_function(module, "glVertexAttrib4fARB", gl_VertexAttrib4fARB, 5);
	rb_define_module_function(module, "glVertexAttrib4ivARB", gl_VertexAttrib4ivARB, 2);
	rb_define_module_function(module, "glVertexAttrib4sARB", gl_VertexAttrib4sARB, 5);
	rb_define_module_function(module, "glVertexAttrib4ubvARB", gl_VertexAttrib4ubvARB, 2);
	rb_define_module_function(module, "glVertexAttrib4uivARB", gl_VertexAttrib4uivARB, 2);
	rb_define_module_function(module, "glVertexAttrib4usvARB", gl_VertexAttrib4usvARB, 2);
	rb_define_module_function(module, "glVertexAttrib1dvARB", gl_VertexAttrib1dvARB, 2);
	rb_define_module_function(module, "glVertexAttrib1fvARB", gl_VertexAttrib1fvARB, 2);
	rb_define_module_function(module, "glVertexAttrib1svARB", gl_VertexAttrib1svARB, 2);
	rb_define_module_function(module, "glVertexAttrib2dvARB", gl_VertexAttrib2dvARB, 2);
	rb_define_module_function(module, "glVertexAttrib2fvARB", gl_VertexAttrib2fvARB, 2);
	rb_define_module_function(module, "glVertexAttrib2svARB", gl_VertexAttrib2svARB, 2);
	rb_define_module_function(module, "glVertexAttrib3dvARB", gl_VertexAttrib3dvARB, 2);
	rb_define_module_function(module, "glVertexAttrib3fvARB", gl_VertexAttrib3fvARB, 2);
	rb_define_module_function(module, "glVertexAttrib3svARB", gl_VertexAttrib3svARB, 2);
	rb_define_module_function(module, "glVertexAttrib4dvARB", gl_VertexAttrib4dvARB, 2);
	rb_define_module_function(module, "glVertexAttrib4fvARB", gl_VertexAttrib4fvARB, 2);
	rb_define_module_function(module, "glVertexAttrib4svARB", gl_VertexAttrib4svARB, 2);
	rb_define_module_function(module, "glGetVertexAttribdvARB", gl_GetVertexAttribdvARB, 2);
	rb_define_module_function(module, "glGetVertexAttribfvARB", gl_GetVertexAttribfvARB, 2);
	rb_define_module_function(module, "glGetVertexAttribivARB", gl_GetVertexAttribivARB, 2);

/* #39 GL_ARB_color_buffer_float */
	rb_define_module_function(module, "glClampColorARB", gl_ClampColorARB, 2);
}
