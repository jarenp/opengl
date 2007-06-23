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

def glut_init()
		glutInit
    glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGB | GLUT_STENCIL)
	  glutInitWindowPosition(1, 1)
	  glutInitWindowSize(512, 512)
	  glutCreateWindow("test")
end

class Test_10_11 < Test::Unit::TestCase
	def setup
		if $glut_initialized == true
			glPushAttrib(GL_ALL_ATTRIB_BITS)
			glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS)
			return
		end
		
		glut_init()
		$glut_initialized = true

		glPushAttrib(GL_ALL_ATTRIB_BITS)
		glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS)
	end

	def teardown
		glPopAttrib()
		glPopClientAttrib()
	end

	def test_glhint
		glHint(GL_FOG_HINT,GL_NICEST)
		assert_equal(glGetIntegerv(GL_FOG_HINT), GL_NICEST)
		glHint(GL_FOG_HINT,GL_FASTEST)
		assert_equal(glGetIntegerv(GL_FOG_HINT), GL_FASTEST)
	end

	def test_glindex
		glIndexd(2.0)
		assert_equal(glGetDoublev(GL_CURRENT_INDEX),2.0)
		glIndexdv([3.0])
		assert_equal(glGetDoublev(GL_CURRENT_INDEX),3.0)

		glIndexf(4.0)
		assert_equal(glGetFloatv(GL_CURRENT_INDEX),4.0)
		glIndexfv([5.0])
		assert_equal(glGetFloatv(GL_CURRENT_INDEX),5.0)

		glIndexi(6)
		assert_equal(glGetIntegerv(GL_CURRENT_INDEX),6)
		glIndexiv([7])
		assert_equal(glGetIntegerv(GL_CURRENT_INDEX),7)

		glIndexs(8)
		assert_equal(glGetIntegerv(GL_CURRENT_INDEX),8)
		glIndexsv([9])
		assert_equal(glGetIntegerv(GL_CURRENT_INDEX),9)

		glIndexub(10)
		assert_equal(glGetIntegerv(GL_CURRENT_INDEX),10)
		glIndexubv([11])
		assert_equal(glGetIntegerv(GL_CURRENT_INDEX),11)

		# index pointer
		glIndexPointer(GL_INT,2,"")
		assert_equal(glGetIntegerv(GL_INDEX_ARRAY_STRIDE),2)
		assert_equal(glGetIntegerv(GL_INDEX_ARRAY_TYPE),GL_INT)
	end

	def test_glclear
		glClearColor(1,0,1,0)
		assert_equal(glGetDoublev(GL_COLOR_CLEAR_VALUE),[1,0,1,0])

		glClearIndex(2)
		assert_equal(glGetDoublev(GL_INDEX_CLEAR_VALUE),2)

		glClearAccum(0.5,0.5,0.5,0.5)
		assert_equal(glGetDoublev(GL_ACCUM_CLEAR_VALUE),[0.5,0.5,0.5,0.5])

		glClearStencil(1)
		assert_equal(glGetIntegerv(GL_STENCIL_CLEAR_VALUE),1)

		glClearDepth(0.5)
		assert_equal(glGetDoublev(GL_DEPTH_CLEAR_VALUE),0.5)
	end
	
	def test_glclientattrib
		glPixelStorei(GL_PACK_ALIGNMENT,2)
		glPushClientAttrib(GL_CLIENT_PIXEL_STORE_BIT)
		glPixelStorei(GL_PACK_ALIGNMENT,4)
		assert_equal(glGetIntegerv(GL_PACK_ALIGNMENT),4)
		glPopClientAttrib()
		assert_equal(glGetIntegerv(GL_PACK_ALIGNMENT),2)
	end

	def test_matrix
		m_a = [[2.0,0.0,0.0,0.0],
					 [0.0,2.0,0.0,0.0],
					 [0.0,0.0,2.0,0.0],
					 [0.0,0.0,0.0,2.0]]

		m_b = [[3.0,0.0,0.0,0.0],
					 [0.0,3.0,0.0,0.0],
					 [0.0,0.0,3.0,0.0],
					 [0.0,0.0,0.0,3.0]]
					 
		glMatrixMode(GL_MODELVIEW)
		glLoadMatrixf(m_a)
		assert_equal(glGetDoublev(GL_MODELVIEW_MATRIX), m_a)
		glLoadMatrixd(m_b)
		assert_equal(glGetDoublev(GL_MODELVIEW_MATRIX), m_b)

		glLoadIdentity()
		glMultMatrixf(m_a)
		assert_equal(glGetDoublev(GL_MODELVIEW_MATRIX), m_a)
		glLoadIdentity()
		glMultMatrixd(m_b)
		assert_equal(glGetDoublev(GL_MODELVIEW_MATRIX), m_b)
	end

	def test_gledge
		glEdgeFlag(GL_FALSE)
		assert_equal(glGetBooleanv(GL_EDGE_FLAG),GL_FALSE)
		glEdgeFlag(GL_TRUE)
		assert_equal(glGetBooleanv(GL_EDGE_FLAG),GL_TRUE)
		glEdgeFlagv([GL_FALSE])
		assert_equal(glGetBooleanv(GL_EDGE_FLAG),GL_FALSE)
	end

	def test_clientstate
		glEnableClientState(GL_COLOR_ARRAY)
		assert_equal(glIsEnabled(GL_COLOR_ARRAY),GL_TRUE)
		glDisableClientState(GL_COLOR_ARRAY)
		assert_equal(glIsEnabled(GL_COLOR_ARRAY),GL_FALSE)
	end

	def test_glshademodel
		glShadeModel(GL_FLAT)
		assert_equal(glGetIntegerv(GL_SHADE_MODEL),GL_FLAT)
		glShadeModel(GL_SMOOTH)
		assert_equal(glGetIntegerv(GL_SHADE_MODEL),GL_SMOOTH)
	end

	def test_glclipplane
		glClipPlane(GL_CLIP_PLANE0,[1,2,3,4])
		assert_equal(glGetClipPlane(GL_CLIP_PLANE0),[1,2,3,4])
	end

	def test_polygonoffset
		glPolygonOffset(2.0,3.0)
		assert_equal(glGetDoublev(GL_POLYGON_OFFSET_FACTOR),2.0)
		assert_equal(glGetDoublev(GL_POLYGON_OFFSET_UNITS),3.0)
	end

	def test_glviewport
		glViewport(1,2,3,4)
		assert_equal(glGetIntegerv(GL_VIEWPORT), [1,2,3,4])
	end

	def test_mask
		glStencilMask(2)
		assert_equal(glGetIntegerv(GL_STENCIL_WRITEMASK), 2)
		glStencilMask(1)
		assert_equal(glGetIntegerv(GL_STENCIL_BACK_WRITEMASK), 1)

		glColorMask(GL_TRUE,GL_FALSE,GL_TRUE,GL_FALSE)
		assert_equal(glGetBooleanv(GL_COLOR_WRITEMASK),[GL_TRUE,GL_FALSE,GL_TRUE,GL_FALSE])

		glDepthMask(GL_TRUE)
		assert_equal(glGetBooleanv(GL_DEPTH_WRITEMASK),GL_TRUE)
		glDepthMask(GL_FALSE)
		assert_equal(glGetBooleanv(GL_DEPTH_WRITEMASK),GL_FALSE)

		glIndexMask(2)
		assert_equal(glGetIntegerv(GL_INDEX_WRITEMASK), 2)
		glIndexMask(1)
		assert_equal(glGetIntegerv(GL_INDEX_WRITEMASK), 1)
	end

	def test_glflush
		glBegin(GL_POINTS)
		glFlush()
		glEnd
		assert_equal(glGetError(),GL_INVALID_OPERATION)
	end

	def test_glfinish
		glBegin(GL_POINTS)
		glFinish()
		glEnd
		assert_equal(glGetError(),GL_INVALID_OPERATION)
	end

	def test_glgetstring
		assert(glGetString(GL_VERSION).size > 0)
	end

	def test_glscissor
		glScissor(1,2,3,4)
		assert_equal(glGetIntegerv(GL_SCISSOR_BOX),[1,2,3,4])
	end

	def test_glstencilfunc
		glStencilFunc(GL_LEQUAL,2,3)
		assert_equal(glGetIntegerv(GL_STENCIL_FUNC),GL_LEQUAL)
		assert_equal(glGetIntegerv(GL_STENCIL_REF),2)
		assert_equal(glGetIntegerv(GL_STENCIL_VALUE_MASK),3)
	end

	def test_glstencilop
		glStencilOp(GL_ZERO,GL_REPLACE,GL_INCR)
		assert_equal(glGetIntegerv(GL_STENCIL_FAIL),GL_ZERO)
		assert_equal(glGetIntegerv(GL_STENCIL_PASS_DEPTH_FAIL),GL_REPLACE)
		assert_equal(glGetIntegerv(GL_STENCIL_PASS_DEPTH_PASS),GL_INCR)
	end

	def test_gllogicop
		glLogicOp(GL_NAND)
		assert_equal(glGetIntegerv(GL_LOGIC_OP_MODE),GL_NAND)
	end

	def test_glfrustum
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		
		glFrustum(1,2,3,4,5,6)
		assert_equal(glGetDoublev(GL_PROJECTION_MATRIX),[[10.0, 0.0, 0.0, 0.0], [0.0, 10.0, 0.0, 0.0], [3.0, 7.0, -11.0, -1.0], [0.0, 0.0, -60.0, 0.0]])
	end

	def test_gldepthrange
		glDepthRange(0.5,0.5)
		assert_equal(glGetDoublev(GL_DEPTH_RANGE),[0.5,0.5])
	end

	def test_func
		glAlphaFunc(GL_GREATER,0.5)
		assert_equal(glGetIntegerv(GL_ALPHA_TEST_FUNC),GL_GREATER)
		assert_equal(glGetDoublev(GL_ALPHA_TEST_REF),0.5)

		glBlendFunc(GL_CONSTANT_ALPHA, GL_ONE_MINUS_DST_COLOR)
		assert_equal(glGetIntegerv(GL_BLEND_SRC),GL_CONSTANT_ALPHA)
		assert_equal(glGetIntegerv(GL_BLEND_DST),GL_ONE_MINUS_DST_COLOR)

		glDepthFunc(GL_LEQUAL)
		assert_equal(glGetIntegerv(GL_DEPTH_FUNC),GL_LEQUAL)
	end

	def test_glpixelzoom
		glPixelZoom(0.5,0.5)
		assert_equal(glGetDoublev(GL_ZOOM_X),0.5)
		assert_equal(glGetDoublev(GL_ZOOM_Y),0.5)
	end

	def test_glpixelstore
		glPixelStoref(GL_PACK_IMAGE_HEIGHT,5)
		assert_equal(glGetIntegerv(GL_PACK_IMAGE_HEIGHT),5)
		glPixelStorei(GL_PACK_IMAGE_HEIGHT,6)
		assert_equal(glGetIntegerv(GL_PACK_IMAGE_HEIGHT),6)
	end

	def test_glpixeltransfer
		glPixelTransferf(GL_RED_SCALE,2)
		assert_equal(glGetIntegerv(GL_RED_SCALE),2)
		glPixelTransferi(GL_RED_SCALE,3)
		assert_equal(glGetIntegerv(GL_RED_SCALE),3)
	end

	def test_pixelmap
		glPixelMapfv(GL_PIXEL_MAP_I_TO_I,[1,2,3,4])
		assert_equal(glGetPixelMapfv(GL_PIXEL_MAP_I_TO_I), [1,2,3,4])

		glPixelMapuiv(GL_PIXEL_MAP_I_TO_I,[5,6,7,8])
		assert_equal(glGetPixelMapuiv(GL_PIXEL_MAP_I_TO_I),[5,6,7,8])

		glPixelMapusv(GL_PIXEL_MAP_I_TO_I,[9,10,11,12])
		assert_equal(glGetPixelMapusv(GL_PIXEL_MAP_I_TO_I),[9,10,11,12])
	end

	def test_buffers
		glDrawBuffer(GL_FRONT)
		assert_equal(glGetIntegerv(GL_DRAW_BUFFER),GL_FRONT)
		glDrawBuffer(GL_BACK)
		assert_equal(glGetIntegerv(GL_DRAW_BUFFER),GL_BACK)

		glReadBuffer(GL_FRONT)
		assert_equal(glGetIntegerv(GL_READ_BUFFER),GL_FRONT)
		glReadBuffer(GL_BACK)
		assert_equal(glGetIntegerv(GL_READ_BUFFER),GL_BACK)
	end

	def test__selection_buffer
		buf = glSelectBuffer(32)

		glRenderMode(GL_SELECT)
		glInitNames()
		glPushName(6)
		glPushName(3)
		glLoadName(5)
		glPopName()

		glBegin(GL_QUADS)
		glVertex2i(-1,-1)
		glVertex2i( 1,-1)
		glVertex2i( 1, 1)
		glVertex2i(-1, 1)
		glEnd()
		
		count = glRenderMode(GL_RENDER)
		data = buf.unpack("i*")
		assert(count==1) # number of records
		assert(data[0]==1) # number of hits in this record
		assert(data[1]>0) # zbuffer near
		assert(data[2]>0) # zbuffer far
		assert(data[3]==6) # name of hit
	end

	def test__feedback_buffer
		buf = glFeedbackBuffer(32,GL_2D)
		
		glRenderMode(GL_FEEDBACK)

		glBegin(GL_TRIANGLES)
		glVertex2i(-1,-1)
		glVertex2i( 1,-1)
		glVertex2i( 1, 1)
		glEnd()
	
		glPassThrough(2.0)
		
		count = glRenderMode(GL_RENDER)
		data = buf.unpack("f*")
		assert_equal(count,10) # (1 + 1 + 3x2) + (1 + 1)
		assert_equal(data[0],GL_POLYGON_TOKEN)
		assert_equal(data[1],3) # 3 vertices
		# skip rasterized vertex data
		assert_equal(data[8],GL_PASS_THROUGH_TOKEN)
		assert_equal(data[9],2.0)
	end
end
