require 'net/ssh/proxy/command'

class SSH
  def initialize(host, options, command = nil)
    @host = host
    @options = options
    @command = command
    @args = []

    parse_options
  end

  def args
    return @args
  end

  def remote
    return "#{@host.user}#{@host.hostname}"
  end

  def parse_options
    @args.push("-o ForwardAgent=yes") if @options.fetch(:forward_agent, false)
    @args.push("-o 'ProxyCommand #{@options.fetch(:proxy).command_line_template}'") if @options.fetch(:proxy, false)
    @args.push("-vvv") if @options.fetch(:debug, false) == :debug

    @host.user = @host.user + "@" if !@host.user.nil?
  end

  def to_s
    cmd = "ssh -t #{@args.join(' ')} #{remote}"
    cmd << " '#{@command}'" if !@command.nil?
  end

  private :parse_options
end
