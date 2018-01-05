require "cli"
require "colorize"

module Cry
  class Command < ::Cli::Command
    @filename : String
    @result_filename : String
    @filename = new_file
    @result_filename = new_result_file

    class Options
      arg "code", desc: "Crystal code or .cr file to execute within the application scope", default: ""
      bool ["-l", "--log"], desc: "Prints results of previous runs"
      string ["-e", "--editor"], desc: "Prefered editor: [vim, nano, pico, etc], only used when no code or .cr file is specified", default: ENV["EDITOR"]? || "vim"
      string ["-b", "--back"], desc: "Runs previous command files: 'amber exec -b [times_ago]'", default: "0"
      bool ["-o", "--loop"], desc: "Runs editor in a loop (can be combined with e.g. -b 1)"
    end

    class Help
      caption "# It runs Crystal code within the application scope"
    end

    def prepare_file
      back_i = options.back.to_i(strict: false)
      _filename = if File.exists?(args.code)
                    args.code
                  elsif back_i == 0
                    @filename = new_file
                  elsif back_i > 0
                    Dir.glob("./tmp/*_console.cr").sort.reverse[back_i - 1]?
                  end

      system("cp #{_filename} #{@filename}") if _filename && File.exists?(_filename)
    end

    def new_file
      "./tmp/#{Time.now.epoch_ms}_console.cr"
    end
    def new_result_file
      @filename.sub("console.cr", "console_result.log")
    end

    def run
      if args.log?
        logs = Dir.glob("./tmp/*_console_result.log")
        str = String.build do |s|
          logs.sort.reverse.each_with_index do |f, i|
            s.puts "cry --back #{i + 1}".colorize(:yellow).mode(:underline)
            s.puts "\n# Code:".colorize.colorize(:dark_gray)
            s.puts File.read(f.gsub("_result.log", ".cr")).colorize(:light_gray)
            s.puts "\n# Results:".colorize(:dark_gray)
            s.puts File.read(f).colorize(:light_gray)
            s.puts "\n"
          end
        end
        system("echo '#{str}' | less -r")
      else
        Dir.mkdir("tmp") unless Dir.exists?("tmp")

        loop do
          unless args.code.blank? || File.exists?(args.code)
            File.write(@filename, "puts (#{args.code}).inspect")
          else
            prepare_file
            system("#{options.editor} #{@filename}")
          end

          break unless File.exists?(@filename)

          result = ""
          result = `crystal eval 'require "#{@filename}";'`

          File.write(@result_filename, result) unless result.nil?
          puts result

          break unless args.loop?
          puts "\nENTER to edit, q to quit"
          input = gets
          break if input=~ /^q/i
          @filename = new_file
          @result_filename = new_result_file
        end
      end
    end
  end
end
