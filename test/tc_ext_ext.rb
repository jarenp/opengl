#
# Copyright (C) 2007 Jan Dvorak <jan.dvorak@kraxnet.cz>
#
# This program is distributed under the terms of the MIT license.
# See the included MIT-LICENSE file for the terms of this license.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require 'test/unit'

class Test_EXT_EXT < Test::Unit::TestCase
	def setup
		common_setup()
	end

	def teardown
		if supported?("GL_EXT_framebuffer_object")
			glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, 0)
			glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, 0)
		end
		common_teardown()
	end

	def test_gl_ext_framebuffer_object
		return if not supported?("GL_EXT_framebuffer_object")
		t = glGenTextures(3)
		glBindTexture(GL_TEXTURE_2D, t[0])
		glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,$window_size,$window_size,0,GL_RGBA,GL_UNSIGNED_BYTE,nil)

		glBindTexture(GL_TEXTURE_1D, t[1])
		glTexImage1D(GL_TEXTURE_1D,0,GL_RGBA8,$window_size,0,GL_RGBA,GL_UNSIGNED_BYTE,nil)

		glBindTexture(GL_TEXTURE_3D, t[2])
		glTexImage3D(GL_TEXTURE_3D,0,GL_RGBA8,$window_size,$window_size,1,0,GL_RGBA,GL_UNSIGNED_BYTE,nil)

		fb = glGenFramebuffersEXT(1)
		assert(fb.size==1)
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT,fb[0])
		assert_equal(glIsFramebufferEXT(fb[0]),GL_TRUE)

		rb = glGenRenderbuffersEXT(1)
		assert(rb.size==1)
		glBindRenderbufferEXT(GL_RENDERBUFFER_EXT,rb[0])
		assert_equal(glIsRenderbufferEXT(rb[0]),GL_TRUE)

		glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT, $window_size, $window_size)

		assert_equal(glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT,GL_RENDERBUFFER_WIDTH_EXT),$window_size)
		assert_equal(glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT,GL_RENDERBUFFER_HEIGHT_EXT),$window_size)
		assert_equal(glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT,GL_RENDERBUFFER_INTERNAL_FORMAT_EXT),GL_DEPTH_COMPONENT)


		glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, rb[0]);
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, t[0], 0)

		status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT)
		assert(status == GL_FRAMEBUFFER_COMPLETE_EXT || status == GL_FRAMEBUFFER_UNSUPPORTED_EXT)

		assert_equal(glGetFramebufferAttachmentParameterivEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE_EXT),GL_TEXTURE)

		glGenerateMipmapEXT(GL_TEXTURE_2D)

		glFramebufferTexture1DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_1D, t[1], 0)
		glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_3D, t[2], 0, 0)
	
		glDeleteRenderbuffersEXT(rb)
		glDeleteFramebuffersEXT(fb)
		glDeleteTextures(t)
	end

	def test_gl_ext_gpu_program_parameters		
		return if not supported?("GL_EXT_gpu_program_parameters")

		glProgramEnvParameters4fvEXT(GL_VERTEX_PROGRAM_ARB,1, [1,2,3,4,5,6,7,8])
		assert_equal(glGetProgramEnvParameterdvARB(GL_VERTEX_PROGRAM_ARB,1),[1,2,3,4])
		assert_equal(glGetProgramEnvParameterdvARB(GL_VERTEX_PROGRAM_ARB,2),[5,6,7,8])
	end

	def test_gl_ext_framebuffer_blit
		return if not supported?("GL_EXT_framebuffer_blit")
		fbo = glGenFramebuffersEXT(2)
		texture = glGenTextures(2)
		data = [1,1,1,1, 0,0,0,0, 1,1,1,1, 0,0,0,0]

		glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, fbo[0])
		glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, fbo[1])

		glBindTexture(GL_TEXTURE_2D, texture[0])
		glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,2,2,0,GL_RGBA,GL_UNSIGNED_BYTE,data.pack("C*"))
		glGenerateMipmapEXT(GL_TEXTURE_2D);

		glBindTexture(GL_TEXTURE_2D, texture[1])
		glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,2,2,0,GL_RGBA,GL_UNSIGNED_BYTE,nil)
		glGenerateMipmapEXT(GL_TEXTURE_2D);

		glFramebufferTexture2DEXT(GL_READ_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, texture[0], 0)
		glFramebufferTexture2DEXT(GL_DRAW_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, texture[1], 0)

		status = glCheckFramebufferStatusEXT(GL_READ_FRAMEBUFFER_EXT)
		assert_equal(status,GL_FRAMEBUFFER_COMPLETE_EXT)
		status = glCheckFramebufferStatusEXT(GL_DRAW_FRAMEBUFFER_EXT)
		assert_equal(status,GL_FRAMEBUFFER_COMPLETE_EXT)

		glBlitFramebufferEXT(0, 0, 2, 2,
											   0, 0, 2, 2,
											   GL_COLOR_BUFFER_BIT,
											   GL_NEAREST)

		glBindTexture(GL_TEXTURE_2D, texture[1])
		tex = glGetTexImage(GL_TEXTURE_2D,0,GL_RGBA,GL_UNSIGNED_BYTE).unpack("C*")
		assert_equal(tex,data)
		
		glDeleteTextures(texture)
		glDeleteFramebuffersEXT(fbo)
	end

	def test_gl_ext_framebuffer_multisample
		return if not supported?("GL_EXT_framebuffer_multisample")
		rb = glGenRenderbuffersEXT(1)[0]

		glBindRenderbufferEXT(GL_RENDERBUFFER_EXT,rb)
		glRenderbufferStorageMultisampleEXT(GL_RENDERBUFFER_EXT,4,GL_RGBA,2,2)
		samples = glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT,GL_RENDERBUFFER_SAMPLES_EXT)
		assert_equal(samples,4)

		glDeleteRenderbuffersEXT(rb)
	end
	
end
