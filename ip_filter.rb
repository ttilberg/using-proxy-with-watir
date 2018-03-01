ARGF.each_line do |line|
  puts line.gsub(/\d+\.\d+\.\d+\.\d+/, '***.***.***.***')
end
