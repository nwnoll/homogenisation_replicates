require 'pathname'
require 'optparse'
require 'set'


options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"


  opts.on("-d DIRECTORY", "--directory", "folder with files") do |opt|
  	Pathname.new(opt)
  end


  opts.on("-s SAMPLES", "--samples", "sample names for files")
  opts.on("-t TYPE", "--type", "type: otus or esvs")
end.parse!(into: options)


blast6_file_paths   = options[:directory].glob('*.b6')
blast6_file_paths   = options[:directory].glob("#{options[:samples]}*#{options[:type]}*.b6") if options[:samples] && options[:type]
results_for         = Hash.new { |h,k| h[k] = [] }


best_hit_for = Hash.new { |h, k| h[k] = [] }
blast6_file_paths.each do |file_path|
	file = File.open(file_path, 'r')


    file.each do |line|
        contents    = line.split("\t")
        query       = contents[0]
        best_hit_for[query].push(line)
    end
end


if options[:samples] && options[:type]
    count = 0
    file_name = nil
    loop do
        count_str = count == 0 ? "" : count.to_s
        file_name = "taxonomic_assignments/#{options[:samples]}_pooled_#{options[:type]}_085_combined#{count_str}.b6"
        File.file?(file_name) ? count += 1 : break
    end   
    file_out = File.open(file_name, 'w')
end


best_hit_for.each do |key, value|
    value.each do |line|
        if options[:samples] && options[:type]
            file_out.puts line
        else
            puts line
        end
    end
end