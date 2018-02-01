require 'bundler'
require 'yaml'

Bundler.require

class MyCLI < Thor
  option :hostfactory

  desc 'create POLICYNAME', 'variable1 variable2 ...'
  def create(policy, *args)
    # puts "args: #{args.inspect}"

    if options.key?(:hostfactory)
      variables = strip_flags(args)
    else
      variables = args
    end
    # puts "policy #{policy}"
    # puts "args: #{variables.inspect}"
    # puts "hostfactory: #{options.key?(:hostfactory)}"

    to_file(
      "#{policy}.yml",
      base_policy(policy) +
      variables(args) +
      groups_and_grants(options.key?(:hostfactory))
    )
  end

  def strip_flags(args)
    args.delete_if { |i| i.match?(/^--/) }
  end

  def variables(var_array)
    rtn = [
      new_line('- &variables', 2),
    ]
    var_array.each do |variable|
      variable, *parts = variable.split(',')
      # puts "variable: #{variable}, parts: #{parts.inspect}"
      rtn << new_line('- !variable', 4)
      rtn << new_line("id: #{variable}", 6)
      if parts.length > 1
        rtn << new_line('annotations:', 6)
        parts.each do |item|
          case item.split(':').first
          when 'rotator'
            rtn << new_line("rotation/rotator: #{item.split(':').last}", 8)
          when 'ttl'
            rtn << new_line("rotation/ttl: #{item.split(':').last}", 8)
          end
        end
      end
    end
    rtn << new_line
    rtn
  end

  def groups_and_grants(host_factory)
    [].tap do |arr|
      arr << new_line('- !layer', 2)
      arr << new_line
      if host_factory
        arr << new_line('- !host-factory', 2)
        arr << new_line('layer: [ !layer ]', 4)
        arr << new_line
      end
      arr << new_line('- !group secrets-users', 2)
      arr << new_line('- !group secrets-managers', 2)
      arr << new_line
      arr << new_line('# secrets-users can read and execute', 2)
      arr << new_line('- !permit', 2)
      arr << new_line('resource: *variables', 4)
      arr << new_line('privileges: [ read, execute ]', 4)
      arr << new_line('role: !group secrets-users', 4)
      arr << new_line
      arr << new_line('# secrets-managers can update (and read and execute, via role grant)', 2)
      arr << new_line('- !permit', 2)
      arr << new_line('resource: *variables', 4)
      arr << new_line('privileges: [ update ]', 4)
      arr << new_line('role: !group secrets-managers', 4)
      arr << new_line
      arr << new_line('# secrets-managers has role secrets-users', 2)
      arr << new_line('- !grant', 2)
      arr << new_line('member: !group secrets-managers', 4)
      arr << new_line('role: !group secrets-users', 4)
      arr << new_line
      arr << new_line('# Application layer has the secrets-users role')
      arr << new_line('- !grant', 2)
      arr << new_line('member: !layer', 4)
      arr << new_line('role: !group secrets-users', 4)
    end
  end

  def base_policy(name)
    [
      new_line('- !policy', 0),
      new_line("id: #{name}", 2),
      new_line('body:', 2)
    ]
  end

  def to_file(filename, body)
    File.open(filename, 'w') do |file|
      [*body].each do |line|
        file.write(line)
      end
    end
  end

  def new_line(content = '', spaces = 0)
    ' ' * spaces + "#{content}\n"
  end
end

MyCLI.start(ARGV)
