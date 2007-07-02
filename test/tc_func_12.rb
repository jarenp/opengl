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

if __FILE__ == $0
    # If we are being called from the command line, e.g., ruby foo.rb, then
    # fixup the load path so we can find the OpenGL extension libs
    $: << File.join(File.dirname(__FILE__), '..', 'ext')
end

require 'test/unit'
require 'gl'
require 'glut'
include Gl
include Glut

def supported?(funcs)
	funcs.each do |name|
		if !Gl.is_available?(name)
				puts "Function #{name} not supported, test skipped"
				return false
		end
	end
	return true
end

class Test_12 < Test::Unit::TestCase
	def setup
		if $glut_initialized == nil
			glut_init()
			$glut_initialized = true
		end

		glPushAttrib(GL_ALL_ATTRIB_BITS)
		glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS)
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity()
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()

		glClearColor(0,0,0,0)
		glClear(GL_COLOR_BUFFER_BIT)
	end

	def teardown
		glPopAttrib()
		glPopClientAttrib()
		assert_equal(glGetError(),0) # all expected GL errors must be handled by the method itself
	end
	
	def test_glblend
		return if not supported?(["glBlendColor","glBlendEquation"])
		glBlendColor(0.0,1.0,0.0,1.0)
		assert_equal(glGetDoublev(GL_BLEND_COLOR),[0,1,0,1])

		glBlendEquation(GL_MIN)
		assert_equal(glGetIntegerv(GL_BLEND_EQUATION),GL_MIN)
		glBlendEquation(GL_MAX)
		assert_equal(glGetIntegerv(GL_BLEND_EQUATION),GL_MAX)
	end
	
	def test_gldrawrangeelements
		return if not supported?(["glDrawRangeElements"])
		va = [0,0, 0,1, 1,1].pack("f*")
		glVertexPointer(2,GL_FLOAT,0,va)

		buf = glFeedbackBuffer(256,GL_3D)
		glRenderMode(GL_FEEDBACK)

		glEnable(GL_VERTEX_ARRAY)

		glDrawRangeElements(GL_POINTS,0,2,3,GL_UNSIGNED_BYTE,[0,1,2].pack("C*"))
		count = glRenderMode(GL_RENDER)
		assert_equal(count,12)

		glDisable(GL_VERTEX_ARRAY)
	end
	
	def test_colortable
		return if not supported?(["glColorTable","glGetColorTable","glColorSubTable","glCopyColorTable","glCopyColorSubTable","glColorTableParameterfv","glColorTableParameteriv","glGetColorTableParameterfv","glGetColorTableParameteriv"])

		ct = ([0]*3+[1]*3+[0]*3+[1]*3).pack("f*")
		ct2 = ([1]*3+[0]*3+[1]*3+[0]*3).pack("f*")
		glColorTable(GL_COLOR_TABLE,GL_RGB8,4,GL_RGB,GL_FLOAT,ct)
		assert_equal(glGetColorTable(GL_COLOR_TABLE,GL_RGB,GL_FLOAT),ct)

		glColorSubTable(GL_COLOR_TABLE,0,4,GL_RGB,GL_FLOAT,ct2)
		assert_equal(glGetColorTable(GL_COLOR_TABLE,GL_RGB,GL_FLOAT),ct2)

		glDrawPixels(4,1,GL_RGB,GL_FLOAT,ct)
		glCopyColorTable(GL_COLOR_TABLE,GL_RGB8,0,0,4)
		assert_equal(glGetColorTable(GL_COLOR_TABLE,GL_RGB,GL_FLOAT),ct)

		glDrawPixels(4,1,GL_RGB,GL_FLOAT,ct2)
		glCopyColorSubTable(GL_COLOR_TABLE,0,0,0,4)
		assert_equal(glGetColorTable(GL_COLOR_TABLE,GL_RGB,GL_FLOAT),ct2)

		glColorTableParameterfv(GL_COLOR_TABLE,GL_COLOR_TABLE_BIAS,[0,1,0,1])
		assert_equal(glGetColorTableParameterfv(GL_COLOR_TABLE,GL_COLOR_TABLE_BIAS),[0,1,0,1])

		glColorTableParameteriv(GL_COLOR_TABLE,GL_COLOR_TABLE_BIAS,[1,0,1,0])
		assert_equal(glGetColorTableParameteriv(GL_COLOR_TABLE,GL_COLOR_TABLE_BIAS),[1,0,1,0])
	end

	def test_convolutionfilter
		return if not supported?(["glConvolutionFilter1D","glConvolutionFilter2D","glGetConvolutionFilter","glCopyConvolutionFilter1D","glCopyConvolutionFilter2D","glConvolutionParameterf","glConvolutionParameterfv","glConvolutionParameteri","glConvolutionParameteriv","glGetConvolutionParameterfv","glGetConvolutionParameteriv"])

		cf = ([0]*3+[1]*3+[0]*3+[1]*3).pack("f*")
		cf2 = ([1]*3+[0]*3+[1]*3+[0]*3).pack("f*")
		glConvolutionFilter1D(GL_CONVOLUTION_1D, GL_RGB8, 4, GL_RGB, GL_FLOAT,cf)
		assert_equal(glGetConvolutionFilter(GL_CONVOLUTION_1D, GL_RGB, GL_FLOAT),cf)

		glConvolutionFilter2D(GL_CONVOLUTION_2D, GL_RGB8, 2,2, GL_RGB, GL_FLOAT,cf2)
		assert_equal(glGetConvolutionFilter(GL_CONVOLUTION_2D, GL_RGB, GL_FLOAT),cf2)

		glDrawPixels(4,1,GL_RGB,GL_FLOAT,cf2)
		glCopyConvolutionFilter1D(GL_CONVOLUTION_1D,GL_RGB8,0,0,4)
		assert_equal(glGetConvolutionFilter(GL_CONVOLUTION_1D, GL_RGB, GL_FLOAT),cf2)

		glDrawPixels(2,2,GL_RGB,GL_FLOAT,cf)
		glCopyConvolutionFilter2D(GL_CONVOLUTION_2D,GL_RGB8,0,0,2,2)
		assert_equal(glGetConvolutionFilter(GL_CONVOLUTION_2D, GL_RGB, GL_FLOAT),cf)

		glConvolutionParameterf(GL_CONVOLUTION_1D,GL_CONVOLUTION_BORDER_MODE,GL_CONSTANT_BORDER)
		assert_equal(glGetConvolutionParameterfv(GL_CONVOLUTION_1D,GL_CONVOLUTION_BORDER_MODE),[GL_CONSTANT_BORDER])

		glConvolutionParameterf(GL_CONVOLUTION_1D,GL_CONVOLUTION_BORDER_MODE,GL_REPLICATE_BORDER)
		assert_equal(glGetConvolutionParameterfv(GL_CONVOLUTION_1D,GL_CONVOLUTION_BORDER_MODE),[GL_REPLICATE_BORDER])

		glConvolutionParameterfv(GL_CONVOLUTION_1D,GL_CONVOLUTION_BORDER_MODE,[GL_CONSTANT_BORDER])
		assert_equal(glGetConvolutionParameterfv(GL_CONVOLUTION_1D,GL_CONVOLUTION_BORDER_MODE),[GL_CONSTANT_BORDER])

		glConvolutionParameteri(GL_CONVOLUTION_1D,GL_CONVOLUTION_BORDER_MODE,GL_REPLICATE_BORDER)
		assert_equal(glGetConvolutionParameteriv(GL_CONVOLUTION_1D,GL_CONVOLUTION_BORDER_MODE),[GL_REPLICATE_BORDER])

		glConvolutionParameteriv(GL_CONVOLUTION_1D,GL_CONVOLUTION_BORDER_MODE,[GL_CONSTANT_BORDER])
		assert_equal(glGetConvolutionParameteriv(GL_CONVOLUTION_1D,GL_CONVOLUTION_BORDER_MODE),[GL_CONSTANT_BORDER])
	end

	def test_separablefilter
		return if not supported?(["glSeparableFilter2D","glGetSeparableFilter"])
		sf_a = ([0]*3+[1]*3).pack("f*")
		sf_b = ([1]*3+[0]*3).pack("f*")
		
		glSeparableFilter2D(GL_SEPARABLE_2D,GL_RGB8, 2,2,GL_RGB,GL_FLOAT,sf_a,sf_b)
		assert_equal(glGetSeparableFilter(GL_SEPARABLE_2D,GL_RGB,GL_FLOAT), [sf_a,sf_b])
	end

	def test_histogram
		return if not supported?(["glHistogram","glGetHistogram","glResetHistogram","glGetHistogramParameterfv","glGetHistogramParameteriv"])

		glEnable(GL_HISTOGRAM)

		glHistogram(GL_HISTOGRAM,1,GL_RGB8,GL_FALSE)
		assert_equal(glGetHistogramParameterfv(GL_HISTOGRAM,GL_HISTOGRAM_WIDTH),[1])
		assert_equal(glGetHistogramParameteriv(GL_HISTOGRAM,GL_HISTOGRAM_FORMAT),[GL_RGB8])
		assert_equal(glGetHistogramParameteriv(GL_HISTOGRAM,GL_HISTOGRAM_SINK),[GL_FALSE])

		glDrawPixels(2,1,GL_RGB,GL_FLOAT,[1,1,1,1,1,1].pack("f*"))
		h = glGetHistogram(GL_HISTOGRAM,GL_FALSE,GL_RGB,GL_FLOAT)
		assert_equal(h.unpack("f*"),[2,2,2])
		glResetHistogram(GL_HISTOGRAM)
		h = glGetHistogram(GL_HISTOGRAM,GL_FALSE,GL_RGB,GL_FLOAT)
		assert_equal(h.unpack("f*"),[0,0,0])

		glDisable(GL_HISTOGRAM)
	end

	def test_minmax
		return if not supported?(["glMinmax","glGetMinmax","glResetMinmax","glGetMinmaxParameterfv","glGetMinmaxParameteriv"])

		glEnable(GL_MINMAX)		

		glMinmax(GL_MINMAX,GL_RGB8,GL_FALSE)
		assert_equal(glGetMinmaxParameteriv(GL_MINMAX,GL_MINMAX_FORMAT),[GL_RGB8])
		assert_equal(glGetMinmaxParameterfv(GL_MINMAX,GL_MINMAX_FORMAT),[GL_RGB8])
		assert_equal(glGetMinmaxParameterfv(GL_MINMAX,GL_MINMAX_SINK),[GL_FALSE])

		glDrawPixels(2,1,GL_RGB,GL_FLOAT,[0,0,0,1,1,1].pack("f*"))
		mm = glGetMinmax(GL_MINMAX,GL_FALSE,GL_RGB,GL_FLOAT)
		assert_equal(mm.unpack("f*"),[0,0,0,1,1,1])
		glResetMinmax(GL_MINMAX)
		mm = glGetMinmax(GL_MINMAX,GL_FALSE,GL_RGB,GL_UNSIGNED_BYTE)
		assert(approx_equal(mm.unpack("f*"),[0,0,0,0,0,0]))

		glDisable(GL_MINMAX)
	end

	def test_texture_3D
		return if not supported?(["glTexImage3D","glTexSubImage3D","glCopyTexSubImage3D"])
		image = ([0,0,0,1,1,1] * 2 * 2).pack("f*")
		image2 = ([1,1,1,0,0,0] * 2 * 2).pack("f*")

		textures = glGenTextures(1)
		glBindTexture(GL_TEXTURE_3D,textures[0])

		glTexImage3D(GL_TEXTURE_3D,0,GL_RGB8,2,2,2,0,GL_RGB,GL_FLOAT,image)
		assert_equal(glGetTexImage(GL_TEXTURE_3D,0,GL_RGB,GL_FLOAT),image)

		glTexSubImage3D(GL_TEXTURE_3D,0, 0,0,0, 2,2,2,GL_RGB,GL_FLOAT,image2)
		assert_equal(glGetTexImage(GL_TEXTURE_3D,0,GL_RGB,GL_FLOAT),image2)

		glDrawPixels(2,2,GL_RGB,GL_FLOAT,image)
		glCopyTexSubImage3D(GL_TEXTURE_3D,0,0,0,0,0,0,2,2)
		ti = glGetTexImage(GL_TEXTURE_3D,0,GL_RGB,GL_FLOAT).unpack("f*")
		assert_equal(ti,([0]*3 + [1]*3) * 2 + ([1]*3 + [0]*3) * 2)
	end
end
