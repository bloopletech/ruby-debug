require "mkmf"
require "ruby_core_source"

if RUBY_VERSION < "1.9"
  STDERR.print("Ruby version is too old\n")
  exit(1)
end

hdrs = lambda {
  iseqs = %w[vm_core.h iseq.h]
  return false unless begin
    have_struct_member("rb_method_entry_t", "called_id", "method.h") or
    have_struct_member("rb_control_frame_t", "method_id", "method.h")
  end &&
  have_header("vm_core.h") && have_header("iseq.h") && have_header("insns.inc") &&
  have_header("insns_info.inc") && have_header("eval_intern.h")
  return false unless have_type("struct iseq_line_info_entry", iseqs) ||
  have_type("struct iseq_insn_info_entry", iseqs)
  if checking_for(checking_message("if rb_iseq_compile_with_option was added an argument filepath")) do
      try_compile(<<SRC)
#include <ruby.h>
#include "vm_core.h"
extern VALUE rb_iseq_new_main(NODE *node, VALUE filename, VALUE filepath);
SRC
    end
    $defs << '-DRB_ISEQ_COMPILE_5ARGS'
  end
}

dir_config("ruby")
if !Ruby_core_source::create_makefile_with_core(hdrs, "ruby_debug")
  STDERR.print("Makefile creation failed\n")
  STDERR.print("*************************************************************\n\n")
  STDERR.print("  NOTE: For Ruby 1.9 installation instructions, please see:\n\n")
  STDERR.print("     http://wiki.github.com/mark-moseley/ruby-debug\n\n")
  STDERR.print("*************************************************************\n\n")
  exit(1)
end
