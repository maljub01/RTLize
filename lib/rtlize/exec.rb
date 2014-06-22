require 'optparse'

module Rtlize
  class Exec
    def initialize(args)
      @args   = args
      @input  = $stdin
      @output = $stdout
    end

    def setup_option_parser
      @option_parser = OptionParser.new do |opts|
        opts.banner = <<-END
Usage: rtlize [options | source_file [target_file]]

Description:

The rtlize utility reads CSS from the source_file, or the standard input (stdin) if no source_file is specified,
and transforms it to target right-to-left (RTL) layouts instead of left-to-right (LTR) layouts, or vice versa.

The transformed CSS will then be written to the target_file, or the standard output (stdout) if no target_file is specified.

Options:
END

        opts.on_tail("-h", "-?", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("-v", "--version", "Print version") do
          puts("RTLize #{Rtlize::VERSION}")
          exit
        end
      end
    end

    def parse_options
      setup_option_parser
      @option_parser.parse!(@args)

      if @args.length > 2
        puts @option_parser
        exit 1
      end

      @input  = File.open(@args[0], 'r') if @args.length > 0
      @output = File.open(@args[1], 'w') if @args.length > 1
    end

    def parse!
      parse_options
      rtlize_input
      exit 0
    end

    def rtlize_input
      if @input.tty?
        puts "Warning: Reading from standard input. Use Ctrl-D to indicate EOF."
      end
      input = @input.read
      @input.close

      output = Rtlize::RTLizer.transform(input)

      @output.write(output)
      @output.close
    end
  end
end
