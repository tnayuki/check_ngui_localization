# encoding: utf-8

require "ttfunk"

ttf = TTFunk::File.open(ARGV[1])

localization = Hash.new

File::open(ARGV[0]) { |f|
  f.each_line { |line|
    next if line.empty? || line.start_with?('//')

    s = line.split('=', 2)
    localization[s[0].strip] = s[1].strip.gsub(/\\n/, "\n") if s.length == 2
  }
}

errors = 0
localization.each do |k, v|
  v.each_char do |c|
    next if c == "\n"

    l = 0
    ttf.cmap.unicode.each do |u|
      begin
        l = u[c.unpack("U*").first]
        break unless l == 0
      rescue NotImplementedError
      end
    end

    if l == 0 then
      STDERR.puts "The key '#{k}' is not displayable by the specified font"

      errors += 1
      break;
    end
  end
end

exit 1 if errors > 0
