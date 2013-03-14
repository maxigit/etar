#!/usr/bin/ruby

IGNORES= [/\.{1,2}$/ , /\A\.git$/, /\A.+\.e?tar$/]
IGNORES << /^\./  # ignore hidden files

def etar(paths) 
  paths = Array(paths)
  paths.each do |path|
    Dir.entries(path).each do |entry|
      fullname = File.join(path, entry)

      next if IGNORES.inject(false) { |v, ig| v || entry =~ ig }
      case
      when File.symlink?(fullname)
        next
      when File.directory?(fullname)
        etar(fullname)
      when File.file?(fullname)
        key = "__END_OF_#{entry}__"
        puts "filename='#{fullname}'"
        puts "mkdir -p \$(dirname $filename)"
        puts "cat <<#{key} > $filename"
        File.open(fullname).each_line do |line|
          puts line.gsub(/([$\\`])/, '\\\\\1')
        end
        puts "#{key}"
      end
    end
  end
end

etar(ARGV.size>0 ? ARGV : '.')
