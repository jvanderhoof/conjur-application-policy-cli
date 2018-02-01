require 'bundler'

Bundler.require

def get_file_as_string(filename)
  data = ''
  File.open(filename, 'r') .each_line do |line|
    data += line
  end
  data
end

task :test do
  # p = Psych.load_file('secrets.yml')
  p = Psych.parser.parse(get_file_as_string('secrets.yml'))
  binding.pry

end
