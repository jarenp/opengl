/*
 * Copyright (C) 1999 - 2005 Yoshi <yoshi@giganet.net>
 * Copyright (C) 2006 John M. Gabriele <jmg3000@gmail.com>
 * Copyright (C) 2006 Peter McLain
 * All rights reserved.
 * See MIT-LICENSE for permissions.
 */
%wrapper %{

static VALUE g_arg_array;

/*
 * This is the function that will be registered in the Ruby module as
 * "glutInit".  Its job is to mess with the Ruby ARGV and pass it on to
 * the real glutInit(int *, char **) in the glut library.
 */
static VALUE _wrap_glutInit( int argc, VALUE *argv, VALUE obj )
{
    /* Code from Yoshi's 2000 port */
    int largc;
    char** largv;
    int i, j;
    int find;
    VALUE new_argv;
    VALUE arg1;
    VALUE ptr;
    if (rb_scan_args(argc, argv, "01", &arg1) == 0)
    {
        arg1 = rb_eval_string("ARGV");
    }
    Check_Type(arg1, T_ARRAY);
    largc = RARRAY(arg1)->len+1;
    largv = ALLOCA_N(char*, largc+2);
    largv[0] = STR2CSTR(rb_eval_string("$0"));
    for (i = 1; i < largc; i++)
    {
        largv[i] = STR2CSTR(RARRAY(arg1)->ptr[i-1]);
    }
    largv[i] = NULL;
    glutInit(&largc, largv);
    new_argv = rb_ary_new2(largc-1);
    g_arg_array = rb_ary_new();
    for (i = 0; i < RARRAY(arg1)->len; i++) {
        ptr = RARRAY(arg1)->ptr[i];
        find = 0;
        for (j = 1; largv[j]; j++)
        {
            if (STR2CSTR(ptr) == largv[j])
            {
                rb_ary_push(new_argv, ptr);
                find = 1;
                break;
            }
        }
        if (!find)
        {
            rb_ary_push(g_arg_array, ptr);
        }
    }
    return new_argv;
}
%}

%init %{
  /*
   * We need to register our hand-written glut init function so that a Ruby
   * program can call Glut.glutInit()
   */
  rb_define_module_function(mGLUT, "glutInit", _wrap_glutInit, -1);
  rb_global_variable( &g_arg_array );
%}

/*
 * We don't want SWIG to emit anything for the glutInit(int *, char **)
 * function it finds in glut.h, since we deal with that above.
 */
%ignore glutInit;
