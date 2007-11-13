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

/* OpenGL EXT extensions */
/* Those are extensions that are not blessed by ARB committee but were
   created or agreed upon by multiple vendors */

/* #310 - GL_EXT_framebuffer_object */
static GLboolean (APIENTRY * fptr_glIsRenderbufferEXT)(GLuint);
static VALUE gl_IsRenderbufferEXT(VALUE obj,VALUE arg1)
{
	GLboolean ret;
	LOAD_GL_EXT_FUNC(glIsRenderbufferEXT,"GL_EXT_framebuffer_object")
	ret = fptr_glIsRenderbufferEXT((GLuint)NUM2UINT(arg1));
	CHECK_GLERROR
	return INT2NUM(ret);
}

static void (APIENTRY * fptr_glBindRenderbufferEXT)(GLenum,GLuint);
static VALUE gl_BindRenderbufferEXT(VALUE obj,VALUE arg1,VALUE arg2)
{
	LOAD_GL_EXT_FUNC(glBindRenderbufferEXT,"GL_EXT_framebuffer_object")
	fptr_glBindRenderbufferEXT((GLenum)NUM2INT(arg1),(GLuint)NUM2UINT(arg2));
	CHECK_GLERROR
	return Qnil;
}

static void (APIENTRY * fptr_glDeleteRenderbuffersEXT)(GLsizei,const GLuint *);
static VALUE gl_DeleteRenderbuffersEXT(VALUE obj,VALUE arg1)
{
	GLsizei n;
	LOAD_GL_EXT_FUNC(glDeleteRenderbuffersEXT,"GL_EXT_framebuffer_object")
	if (TYPE(arg1)==T_ARRAY) {
		GLuint *renderbuffers;
		n = RARRAY(arg1)->len;
		renderbuffers = ALLOC_N(GLuint,n);
		ary2cuint(arg1,renderbuffers,n); 
		fptr_glDeleteRenderbuffersEXT(n,renderbuffers);
		xfree(renderbuffers);
	} else {
		GLuint renderbuffer;
		renderbuffer = NUM2UINT(arg1);
		fptr_glDeleteRenderbuffersEXT(1,&renderbuffer);
	}
	CHECK_GLERROR
	return Qnil;
}

static void (APIENTRY * fptr_glGenRenderbuffersEXT)(GLsizei,GLuint *);
static VALUE gl_GenRenderbuffersEXT(VALUE obj,VALUE arg1)
{
	GLsizei n;
	GLuint *renderbuffers;
	VALUE ret;
	int i;
	LOAD_GL_EXT_FUNC(glGenRenderbuffersEXT,"GL_EXT_framebuffer_object")
	n = (GLsizei)NUM2UINT(arg1);
	renderbuffers = ALLOC_N(GLuint, n);
	fptr_glGenRenderbuffersEXT(n,renderbuffers);
	ret = rb_ary_new2(n);
	for (i = 0; i < n; i++)
		rb_ary_push(ret, INT2NUM(renderbuffers[i]));
	xfree(renderbuffers);
	CHECK_GLERROR
	return ret;
}

static void (APIENTRY * fptr_glRenderbufferStorageEXT)(GLenum,GLenum,GLsizei,GLsizei);
static VALUE gl_RenderbufferStorageEXT(VALUE obj,VALUE arg1,VALUE arg2,VALUE arg3,VALUE arg4)
{
	LOAD_GL_EXT_FUNC(glRenderbufferStorageEXT,"GL_EXT_framebuffer_object")
	fptr_glRenderbufferStorageEXT(NUM2UINT(arg1),NUM2UINT(arg2),NUM2INT(arg3),NUM2INT(arg4));
	CHECK_GLERROR
	return Qnil;
}

static void (APIENTRY * fptr_glGetRenderbufferParameterivEXT)(GLenum,GLenum,GLint *);
static VALUE gl_GetRenderbufferParameterivEXT(VALUE obj,VALUE arg1,VALUE arg2)
{
	GLint param = 0;
	LOAD_GL_EXT_FUNC(glGetRenderbufferParameterivEXT,"GL_EXT_framebuffer_object")
	fptr_glGetRenderbufferParameterivEXT(NUM2UINT(arg1),NUM2UINT(arg2),&param);
	CHECK_GLERROR
	return INT2NUM(param);
}

static GLboolean (APIENTRY * fptr_glIsFramebufferEXT)(GLuint);
static VALUE gl_IsFramebufferEXT(VALUE obj,VALUE arg1)
{
	GLboolean ret;
	LOAD_GL_EXT_FUNC(glIsFramebufferEXT,"GL_EXT_framebuffer_object")
	ret = fptr_glIsFramebufferEXT(NUM2UINT(arg1));
	CHECK_GLERROR
	return INT2NUM(ret);
}

static void (APIENTRY * fptr_glBindFramebufferEXT)(GLenum,GLuint);
static VALUE gl_BindFramebufferEXT(VALUE obj,VALUE arg1,VALUE arg2)
{
	LOAD_GL_EXT_FUNC(glBindFramebufferEXT,"GL_EXT_framebuffer_object")
	fptr_glBindFramebufferEXT((GLenum)NUM2INT(arg1),(GLuint)NUM2UINT(arg2));
	CHECK_GLERROR
	return Qnil;
}

static void (APIENTRY * fptr_glDeleteFramebuffersEXT)(GLsizei,const GLuint *);
static VALUE gl_DeleteFramebuffersEXT(VALUE obj,VALUE arg1)
{
	GLsizei n;
	LOAD_GL_EXT_FUNC(glDeleteFramebuffersEXT,"GL_EXT_framebuffer_object")
	if (TYPE(arg1)==T_ARRAY) {
		GLuint *framebuffers;
		n = RARRAY(arg1)->len;
		framebuffers = ALLOC_N(GLuint,n);
		ary2cuint(arg1,framebuffers,n); 
		fptr_glDeleteFramebuffersEXT(n,framebuffers);
		xfree(framebuffers);
	} else {
		GLuint framebuffer;
		framebuffer = NUM2UINT(arg1);
		fptr_glDeleteFramebuffersEXT(1,&framebuffer);
	}
	CHECK_GLERROR
	return Qnil;
}

static void (APIENTRY * fptr_glGenFramebuffersEXT)(GLsizei,GLuint *);
static VALUE gl_GenFramebuffersEXT(VALUE obj,VALUE arg1)
{
	GLsizei n;
	GLuint *framebuffers;
	VALUE ret;
	int i;
	LOAD_GL_EXT_FUNC(glGenFramebuffersEXT,"GL_EXT_framebuffer_object")
	n = (GLsizei)NUM2UINT(arg1);
	framebuffers = ALLOC_N(GLuint, n);
	fptr_glGenFramebuffersEXT(n,framebuffers);
	ret = rb_ary_new2(n);
	for (i = 0; i < n; i++)
		rb_ary_push(ret, INT2NUM(framebuffers[i]));
	xfree(framebuffers);
	CHECK_GLERROR
	return ret;
}

static GLenum (APIENTRY * fptr_glCheckFramebufferStatusEXT)(GLenum);
static VALUE gl_CheckFramebufferStatusEXT(VALUE obj,VALUE arg1)
{
	GLenum ret;
	LOAD_GL_EXT_FUNC(glCheckFramebufferStatusEXT,"GL_EXT_framebuffer_object")
	ret = fptr_glCheckFramebufferStatusEXT(NUM2UINT(arg1));
	CHECK_GLERROR
	return INT2NUM(ret);
}

static void (APIENTRY * fptr_glFramebufferTexture1DEXT)(GLenum,GLenum,GLenum,GLuint,GLint);
static VALUE gl_FramebufferTexture1DEXT(VALUE obj,VALUE arg1,VALUE arg2,VALUE arg3,VALUE arg4,VALUE arg5)
{
	LOAD_GL_EXT_FUNC(glFramebufferTexture1DEXT,"GL_EXT_framebuffer_object")
	fptr_glFramebufferTexture1DEXT(NUM2UINT(arg1),NUM2UINT(arg2),NUM2UINT(arg3),NUM2UINT(arg4),NUM2INT(arg5));
	CHECK_GLERROR
	return Qnil;
}

static void (APIENTRY * fptr_glFramebufferTexture2DEXT)(GLenum,GLenum,GLenum,GLuint,GLint);
static VALUE gl_FramebufferTexture2DEXT(VALUE obj,VALUE arg1,VALUE arg2,VALUE arg3,VALUE arg4,VALUE arg5)
{
	LOAD_GL_EXT_FUNC(glFramebufferTexture2DEXT,"GL_EXT_framebuffer_object")
	fptr_glFramebufferTexture2DEXT(NUM2UINT(arg1),NUM2UINT(arg2),NUM2UINT(arg3),NUM2UINT(arg4),NUM2INT(arg5));
	CHECK_GLERROR
	return Qnil;
}

static void (APIENTRY * fptr_glFramebufferTexture3DEXT)(GLenum,GLenum,GLenum,GLuint,GLint,GLint);
static VALUE gl_FramebufferTexture3DEXT(VALUE obj,VALUE arg1,VALUE arg2,VALUE arg3,VALUE arg4,VALUE arg5,VALUE arg6)
{
	LOAD_GL_EXT_FUNC(glFramebufferTexture3DEXT,"GL_EXT_framebuffer_object")
	fptr_glFramebufferTexture3DEXT(NUM2UINT(arg1),NUM2UINT(arg2),NUM2UINT(arg3),NUM2UINT(arg4),NUM2INT(arg5),NUM2INT(arg6));
	CHECK_GLERROR
	return Qnil;
}

GL_EXT_SIMPLE_FUNC_LOAD(FramebufferRenderbufferEXT,4,GLuint,NUM2UINT,"GL_EXT_framebuffer_object")


static void (APIENTRY * fptr_glGetFramebufferAttachmentParameterivEXT)(GLenum,GLenum,GLenum,GLint *);
static VALUE gl_GetFramebufferAttachmentParameterivEXT(VALUE obj,VALUE arg1, VALUE arg2, VALUE arg3)
{
	GLint ret = 0;
	LOAD_GL_EXT_FUNC(glGetFramebufferAttachmentParameterivEXT,"GL_EXT_framebuffer_object")
	fptr_glGetFramebufferAttachmentParameterivEXT(NUM2UINT(arg1),NUM2UINT(arg2),NUM2UINT(arg3),&ret);
	CHECK_GLERROR
	return INT2NUM(ret);
}

GL_EXT_SIMPLE_FUNC_LOAD(GenerateMipmapEXT,1,GLenum,NUM2UINT,"GL_EXT_framebuffer_object")

void gl_init_functions_ext_ext(VALUE module)
{
/* #310 - GL_EXT_framebuffer_object */
	rb_define_module_function(module, "glIsRenderbufferEXT", gl_IsRenderbufferEXT, 1);
	rb_define_module_function(module, "glBindRenderbufferEXT", gl_BindRenderbufferEXT, 2);
	rb_define_module_function(module, "glDeleteRenderbuffersEXT", gl_DeleteRenderbuffersEXT, 1);
	rb_define_module_function(module, "glGenRenderbuffersEXT", gl_GenRenderbuffersEXT, 1);
	rb_define_module_function(module, "glRenderbufferStorageEXT", gl_RenderbufferStorageEXT, 4);
	rb_define_module_function(module, "glGetRenderbufferParameterivEXT", gl_GetRenderbufferParameterivEXT, 2);
	rb_define_module_function(module, "glIsFramebufferEXT", gl_IsFramebufferEXT, 1);
	rb_define_module_function(module, "glBindFramebufferEXT", gl_BindFramebufferEXT, 2);
	rb_define_module_function(module, "glDeleteFramebuffersEXT", gl_DeleteFramebuffersEXT, 1);
	rb_define_module_function(module, "glGenFramebuffersEXT", gl_GenFramebuffersEXT, 1);
	rb_define_module_function(module, "glCheckFramebufferStatusEXT", gl_CheckFramebufferStatusEXT, 1);
	rb_define_module_function(module, "glFramebufferTexture1DEXT", gl_FramebufferTexture1DEXT, 5);
	rb_define_module_function(module, "glFramebufferTexture2DEXT", gl_FramebufferTexture2DEXT, 5);
	rb_define_module_function(module, "glFramebufferTexture3DEXT", gl_FramebufferTexture3DEXT, 6);
	rb_define_module_function(module, "glFramebufferRenderbufferEXT", gl_FramebufferRenderbufferEXT, 4);
	rb_define_module_function(module, "glGetFramebufferAttachmentParameterivEXT", gl_GetFramebufferAttachmentParameterivEXT, 3);
	rb_define_module_function(module, "glGenerateMipmapEXT", gl_GenerateMipmapEXT, 1);

}
