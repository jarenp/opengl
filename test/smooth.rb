require "../ext/gl/GL"
require "../ext/glut/GLUT"

STDOUT.sync=TRUE
disp = Proc.new {
  GL.glClear(GL::GL_COLOR_BUFFER_BIT)
  GL.glBegin(GL::GL_TRIANGLES)
    GL.glColor(0.0, 0.0, 1.0)
    GL.glVertex(0, 0)
    GL.glColor(0.0, 1.0, 0.0)
    GL.glVertex(200, 200)
    GL.glColor(1.0, 0.0, 0.0)
    GL.glVertex(20, 200)
  GL.glEnd
  GL.glFlush
}

reshape = Proc.new {|w, h|
  GL.glViewport(0, 0, w, h)
  GL.glMatrixMode(GL::GL_PROJECTION)
  GL.glLoadIdentity
  GL.glOrtho(0, w, 0, h, -1, 1)
  GL.glScale(1, -1, 1)
  GL.glTranslate(0, -h, 0)
}

GLUT.glutInit
a =  GLUT.glutCreateWindow("single triangle");
GLUT.glutDisplayFunc(disp);
GLUT.glutReshapeFunc(reshape);
GLUT.glutMainLoop;
