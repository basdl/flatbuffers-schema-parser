require 'erb'
load 'parse.rb'

idl = nil
begin
  mini = Mini.new
  idl = mini.parse(File.readlines("../test.idl").join(""))
rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end

pp idl

# Extract most common datastructures
tables = idl.select{|t| t[:type].is_a?(Hash) and t[:type][:type] == "table"}.collect{|t| t[:type]}
structs = idl.select{|t| t[:type].is_a?(Hash) and t[:type][:type] == "struct"}.collect{|t| t[:type]}
enums = idl.select{|t| t[:type].is_a?(Hash) and t[:type][:type] == "enum"}.collect{|t| t[:type]}
unions = idl.select{|t| t[:type].is_a?(Hash) and t[:type][:type] == "union"}.collect{|t| t[:type]}
namespace = idl.select{|t| t.has_key?(:namespace)}.first[:namespace]

# Generate some helper things
[tables,structs].each do |e|
  e.each do |t|
    t[:fullname] = namespace[:name].to_s + "." + t[:name]
    t[:fields].each do |f|
      if f[:type].is_a?(Hash)
        f[:dtype] = :array
      else
        f[:dtype] = :scalar
      end
    end
  end
end

def isClass(name)
  [tables,structs].each do |e|
    e.each do |t|
      if t[:name].to_s == name
        return true
      end
    end
  end
  return false
end



Dir.glob("*.erb").each do |template|
    e = ERB.new(File.readlines(template).join("\n"), 0, "%<>")
    puts e.result.gsub("\n\n", "\n").gsub(/\n\s*\n/, "\n").gsub(/\n\w*\n/, "\n")
end
