#!/usr/bin/env ruby
#
# Copyright (C) 2006 Vo Minh Thu <noteed@gmail.com>
# Copyright (C) 2006 Peter McLain
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

# This script generates glut_wrapper.c from GL/freeglut_std.h.
# It is part of the ruby-opengl developer toolbelt.

# This script assumes each C declaration is written in one line.

# an idea : write some #define, for example
# #define VAL_INT VALUE or VAL_NUM VALUE
# #define VAL_FLT VALUE
# so we know what's behind a VALUE.

# NOTES from pbm:
#
#  * Moved try? and parse into class HFunction
#  * Added wrapper to create an object for each file we're parsing
#  * Reduced globals by moving them into the proper classes
#

# TODO rb_intern("call") could be done only once as in Yoshi's code.

$debug = nil

# Parser
class Parser
    def initialize( string )
        puts "string received : |#@string|" if $debug
        @increment = 0 # value used to generate variable name, e.g. _a1, _a2
        @string  = string.strip # string representation; will be consumed
                                # in-place
        @current = []           # Arg array representation;
                                # it will grow as the string is consumed
    end

    # Try to parse the beginning of the string.  symbol is the symbol that
    # will be pushed on the Arg array representation if the original string
    # matches the regexp_as_string (which is slightly expanded to account
    # for comma in the origianl string).  Warning : the
    # @string variable is used with side-effect : it is initialized by the
    # 'parse' method (see just below).
    def try?( symbol, regexp_as_string )
        regexp = Regexp.new( '^' + regexp_as_string + '\s*,?\s*' )
        if @string.sub!( regexp, '' )
            puts "parsing #{symbol}" if $debug

            # handle callback; $2 has the string arguments
            args = []
            if symbol == :callback && $2 != ""
                parser = Parser.new( $2 )
                args = parser.parse
            end
            if symbol != :void
                @current << arg( symbol, $1 == "" ? "_a#{@increment += 1}" : $1, args )
            end
        end
    end

    # Try repeatedly to consume a bit of the original string, until
    # the whole string is consumed.
    def parse
        continue = true
        # Repeat until the string is completly consumed or
        # nothing matches.
        while @string != "" && continue
            if    try? :callback      , 'void\s*\(\s*\*\s*(\w*)\)\s*\((.*)\)'

            elsif try? :glenum        , 'GLenum\s*(\w*)'
            elsif try? :gldouble      , 'GLdouble\s*(\w*)'
            elsif try? :glfloat       , 'GLfloat\s*(\w*)'
            elsif try? :gluint        , 'GLuint\s*(\w*)'
            elsif try? :glint_p       , 'GLint\s*\*\s*(\w*)'
            elsif try? :glint         , 'GLint\s*(\w*)'
            elsif try? :glshort       , 'GLshort\s*(\w*)'
            elsif try? :glsizei       , 'GLsizei\s*(\w*)'

            elsif try? :char_pp       , 'char\s*\*\s*\*\s*(\w*)'
            elsif try? :const_uchar_p , 'const\s+unsigned\s+char\s*\*\s*(\w*)'
            elsif try? :const_char_p  , 'const\s+char\s*\*\s*(\w*)'
            elsif try? :char_p        , 'char\s*\*\s*(\w*)'
            elsif try? :uchar         , 'unsigned\s+char\s*(\w*)'
            elsif try? :char          , 'char\s*(\w*)'
            elsif try? :uint          , 'unsigned\s+int\s*(\w*)'
            elsif try? :int_p         , 'int\s*\*\s*(\w*)'
            elsif try? :int           , 'int\s*(\w*)'
            elsif try? :void_p        , 'void\s*\*\s*(\w*)'
            elsif try? :void          , 'void'
            else
                # nothing matches; abort (the string isn't completely consumed)
                continue = nil
            end
            puts "remains : |#@string|" if $debug
        end
        # Show an error if the string is not completely consumed.
        puts "ERR : parse failed on |#@string|" if @string != ""

        @current
    end
end

# Arg is a pair representing the name and type from an argument in a C
# function declaration.  It knows how to convert the C type into a ruby
# type. When the :type is callback, has also its arguments
class Arg
    attr_accessor :type, :name, :args

    def initialize( type, name, args )
        @type = type
        @name = name
        @args = args
    end

    def count
        return type == "void" ? 0 : 1
    end

    def to_conversion_str
        case type
        when :callback      then "callback"
        when :glenum        then "(GLenum)NUM2INT(#@name)"
        when :gldouble      then "(GLdouble)NUM2DBL(#@name)"
        when :glfloat       then "(GLfloat)NUM2DBL(#@name)"
        when :gluint        then "(GLuint)NUM2UINT(#@name)"
        when :glint_p       then "TODO"
        when :glint         then "(GLint)NUM2INT(#@name)"
        when :glshort       then "(GLshort)NUM2INT(#@name)"
        when :glsizei       then "(GLsizei)NUM2INT(#@name)"
        when :const_uchar_p then "(unsigned char *)StringValuePtr(#@name)"
        when :const_char_p  then "StringValuePtr(#@name)"
        when :uint          then "NUM2UINT(#@name)"
        when :int           then "NUM2INT(#@name)"
        when :void_p        then "(void*)NUM2INT(#@name)"
        else
            puts "ERR : Arg.to_conversion_str can't handle |#{type}|"
            "TODO #{type}"
        end
    end
    def to_conversion_str2 # TODO rename
        case type
        when :uchar         then "INT2NUM(#@name)" # or INT2FIX ?
        when :uint          then "INT2NUM(#@name)"
        when :int           then "INT2NUM(#@name)"
        else
            puts "ERR : Arg.to_conversion_str2 can't handle |#{type}|"
            "TODO #{type}"
        end
    end
    def type_str
        case type
        when :callback      then "callback_type"
        when :glenum        then "GLenum "
        when :gldouble      then "GLdouble "
        when :glfloat       then "GLfloat "
        when :gluint        then "GLuint "
        when :glint         then "GLint "
        when :glshort       then "GLshort "
        when :glsizei       then "GLsizei "
        when :const_uchar_p then "const unsigned char * "
        when :const_char_p  then "const cahr * "
        when :uint          then "unsigned int "
        when :int           then "int "
        when :uchar         then "unsigned char "
        when :char          then "char "
        when :void_p        then "void * "
        end
    end
    def to_s
        "type: #{@type}, name:#{@name}, args:#@args"
    end
end

# Convenience Arg constructor.
def arg( type, name, args )
    Arg.new type, name, args
end

# HFunction must have its name rewritten; it's ugly :)
# HFunction is the in-this-script representation of a
# c function we want to generate code for.
class HFunction
    # This is used to match a c function we want to generate code for.
    @@matcher = /.*(void|int).*(glut[A-Z][^(]*)\s*\((.*)\)\s*;/
    @@ignore = []
    def HFunction.matcher=( re )
        @@matcher = re
    end
    def HFunction.ignore( a )
        @@ignore << a
    end


    def initialize( return_type, function_name, arguments )
        @return_type   = return_type
        @function_name = function_name
        @arguments     = arguments
        puts self.to_s if $debug
    end

    def to_s
        "#{@return_type} #{@function_name} (#{@arguments.join(', ')})"
    end

    def num_args
        @arguments.length
    end

    def has_callback?
        # Iterate over the arguments to find if there's a callback.
        # We could instead add an attribute.
        @arguments.detect { |a| a.type == :callback }
    end

    def callback_name
        @function_name.downcase.sub /^glut/, ''
    end

    def callback_num_args
        callback = has_callback?
        callback.args.length
    end

    def callback_args_type
        callback = has_callback?
        s = callback.args.inject('') do |str, arg|
            str += "#{arg.type_str} #{arg.name}, "
        end
        s.chop!.chop! unless s == ''
    end

    def callback_args
        callback = has_callback?
        callback.args.inject('') do |str, arg|
            str += ", #{arg.to_conversion_str2}"
        end
    end

    def args_string
        s = @arguments.inject('') do |str, a|
            str += "#{a.type == :callback ? "call_" + callback_name + "_callback" : a.to_conversion_str}, "
        end
        s.chop!.chop! unless s == ''
    end

    def args_type
            s = @arguments.inject('') do |str, a|
                str += ", VALUE #{a.type == :callback ? 'callback' : a.name}"
            end
    end

    # Try to construct a new HFunction instance by matching
    # against an arbitrary string.
    def HFunction.construct?( string )
        md = @@matcher.match( string )
        return nil if not md

        return_type, function_name, arguments = md.captures
        if $debug
            puts "#{string}"
            puts "return type   : #{return_type}"
            puts "function name : #{function_name}"
            puts "arguments     : #{arguments}"
        end

        return_type = return_type == "int" ? :int : :void

        # convert arguments from string representation to
        # Arg array representation
        parser = Parser.new( arguments )
        arguments = parser.parse

        HFunction.new( return_type, function_name, arguments )
    end

    # Write the c wrapper code in file.
    def write_wrap( file )

        # let write_callback do the job if it has a callback
        if has_callback?
            write_callback file
            return
        end
        
        str = ''
        if @function_name == 'glutInit'
            str = <<END
static VALUE
rbgl_glutInit (VALUE self)
{
    int    argc   = 1;
    char * argv[] = { "dummy_argv" };
    glutInit (&argc, argv);
    return Qtrue;
}

END
        else
            str = "static VALUE\nrbgl_#@function_name (VALUE self#{args_type})\n{\n    "
            str += "return INT2NUM (" if @return_type != :void
            str += "#@function_name (#{args_string})"
            str += ")" if @return_type != :void
            str += ";\n"
            str += "    return Qnil;\n" if @return_type == :void
            str += "}\n\n"
        end

        file << str
    end

    # Write the c initialization code in file.
    def write_init( file )
        string = ''
        if @function_name == 'glutInit'
            string = <<END
    rb_define_module_function (module, "glutInit", rbgl_glutInit, 0);
END
        else
            string = <<END
    rb_define_module_function (module, "#@function_name", rbgl_#@function_name, #{num_args});
END
            callback = has_callback?
            if callback
                # FIXME make it a module global, not a global
                string += <<END
    rb_global_variable(&#{callback_name}_callbacks);
    #{callback_name}_callbacks = rb_ary_new();
END
            end
        end
        file << string
    end

    # Possibly write the c callback wrapper in file.
    def write_callback( file )
        callback = has_callback?
        return unless callback

        string = <<END
static VALUE #{callback_name}_callbacks = Qnil;

static void
call_#{callback_name}_callback (#{callback_args_type})
{
        /* printf ("calling   : call_#{callback_name}_callback\\n"); */
	VALUE callback = rb_ary_entry (#{callback_name}_callbacks, glutGetWindow ());
	if (!NIL_P (callback)) rb_funcall (callback, rb_intern("call"), #{callback_num_args}#{callback_args});
        /* printf ("returning : call_#{callback_name}_name\\n"); */
}

static VALUE
rbgl_#{@function_name} (VALUE self#{args_type})
{
        /* printf ("calling   : rbgl_#{@function_name}\\n"); */
	rb_ary_store ( #{callback_name}_callbacks, glutGetWindow (), callback);
	#{@function_name} (#{args_string});
        /* printf ("returning : rbgl_#{@function_name}\\n"); */
	return Qnil;
}

END
        file << string
    end
end

# HConstant represents a c constant we want to generate code for.
class HConstant
    
    @@matcher = /#define\s+(GLUT.\w+)\s+(.+)/
    @@ignore = []
    def HConstant.matcher=( re )
        @@matcher = re
    end
    def HConstant.ignore( a )
        @@ignore << a
    end

    def initialize(code)
        @code = code
    end
    def write_init(file)
        file << @code
    end

    # FIXME ask Peter why is there a dot between GLUT and \w+ in the regexp.
    def HConstant.construct?( string )
        if string =~ @@matcher && (not @@ignore.include?( $1 ))
            puts "Found Constant: #{$1}  Value: #{$2}" if $debug
            code = "    rb_define_const(module, \"#{$1}\", INT2NUM(#{$2}));\n"
            return HConstant.new( code )
        else
            puts "NO CONSTANT: #{string}" if $debug
            return nil
        end
    end

end

# A Wrapper represents a single .h file that we want to generate ruby code
# for.  The wrapper object will parse the .h file and generate two
# functions, an _wrap.c and an _init.c file.
class Wrapper
    # Create a new Wrapper object, using the +source+ file as input.  Any
    # +headers+ passed in will be #included into the resulting wrapper
    # files.  Output files are named by pre-pending +bar+ to them.
    #
    # E.g., Wrapper.new( "./foo.h", "bar", "<ruby.h>", "<GL/gl.h>" )
    #
    # Will generate wrappers for the functions and constants in foo.h.
    # The bar_wrap.c (but not bar_init.c) file will have the following include
    # directives:
    #    #include <ruby.h>
    #    #include <GL/gl.h>
    #
    def initialize( source, name, *headers )
        @source  = source
        @headers = headers
        @name    = name
        @file_wrap_func_name = name + "_wrap.c"
        @file_init_func_name = name + "_init.c"
        @functions_count, @constants_count, @line_count = 0,0,0
    end

    # Generate the output files into the current directory
    def generate()
        puts "Start processing #{@source} ..."

        # don't forget to close these...
        @file_wrap_func = create_wrap_func
        @file_init_func = create_init_func
        
        File.open( @source ) do |f|
            f.each {|l| process( l )}
        end

        close_wrap_func
        close_init_func

        print_stats
    end

    private

    # Print statistics on the run
    def print_stats
        puts "#@functions_count functions wrapped."
        puts "#@constants_count constants wrapped."
        puts "Source file line count : #@line_count."
    end

    # Create the file to hold the wrapper functions and generate the
    # preamble for it
    def create_wrap_func
        f = File.new( @file_wrap_func_name, 'w' )
        @headers.each {|h| f << "#include #{h}\n"}
        # only for testing :
        f << "#include <stdio.h>\n\n"
        return f
    end

    # Create the file to hold the init functions and generate the
    # preamble for it
    def create_init_func
        f = File.new( @file_init_func_name, 'w' )
        f << "void\nInit_#@name()\n{\n    VALUE module = rb_define_module(\"#{@name.capitalize}\");\n\n"
        return f
    end

    # Close the wrap file after adding any closing code
    def close_wrap_func
        @file_wrap_func.close
    end

    # Close the init file after adding any closing code
    def close_init_func
        @file_init_func << "}\n"
        @file_init_func.close
    end
    
    # process works as follow :
    # * it tries to match against a function or a constant
    # * if it matches, it generates the wrapper code and the
    #   initialization code.
    def process( line )

        if (function = HFunction.construct?( line ))
            @functions_count += 1

            # once the HFunction is constructed, we have two
            # things to do : write the wrapping c code and write
            # the module initialization code.
            function.write_wrap @file_wrap_func
            function.write_init @file_init_func

        elsif (constant = HConstant.construct?( line ))
            @constants_count += 1
            constant.write_init @file_init_func
        end
        @line_count += 1
    end
end

if __FILE__ == $0
    # If run from the command line, then pass all parameters into the
    # wrapper constructor.  The first parameter is the full path to the .h
    # file to process.  The second is the basename of the generated files.
    # The rest of the optional parameters are a list of
    # files to #include in the generated files.
    #
    # E.g., ./mkwrap.rb ./foo.h bar '<ruby.h>' '<GL/gl.h>'
    #
    # Will generate wrappers for the functions and constants in foo.h and
    # the bar_wrap.c (but not bar_init.c) file will have the following include
    # directives:
    #    #include <ruby.h>
    #    #include <GL/gl.h>
    #
    wrapper = Wrapper.new( *ARGV )
    wrapper.generate
end

# Local Variables: ***
# ruby-indent-level: 4 ***
# End: ***
