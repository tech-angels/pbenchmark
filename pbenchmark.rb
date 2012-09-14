require 'bundler/setup'

require 'active_support/json'
require 'eventmachine'
require 'em-websocket-client'
require 'pusher'
#require 'benchmark'
require 'optparse'

module SlangerBenchmark
  @all_latencies = []
  def get_latencies
    @all_latencies
  end

  @options = {
    api_host: '127.0.0.1', 
    api_port: '4567', 
    websocket_host: '127.0.0.1',
    websocket_port: '8080', debug: false,
    nb_clients: 1,
    nb_messages: 10,
    payload_size: 100,
  }
  @opts_app_id = nil
  @opts_app_key = nil
  @opts_secret = nil

  OptionParser.new do |opts|
    opts.on '-c', '--concurrency NUMBER', 'Number of clients' do |k|
      @options[:nb_clients] = k.to_i
    end

    opts.on '-n', '--messages NUMBER', 'Number of messages' do |k|
      @options[:nb_messages] = k.to_i
    end

    opts.on '-i', '--app_id APP_ID', "Pusher application id" do |k|
      @opts_app_id = k
    end

    opts.on '-k', '--app_key APP_KEY', "Pusher application key" do |k|
      @opts_app_key = k
    end

    opts.on '-s', '--secret SECRET', "Pusher application secret" do |k|
      @opts_secret = k
    end

    opts.on '-a', '--api_host HOST', "API service address (Default: 0.0.0.0:4567)" do |p|
      @options[:api_host], @options[:api_port] = p.split(':')
    end

    opts.on '-w', '--websocket_host HOST', "WebSocket service address (Default: 0.0.0.0:8080)" do |p|
      @options[:websocket_host], @options[:websocket_port] = p.split(':')
    end

    opts.on '--size NUMBER', 'Payload size in bytes. (Default: 100)' do |s|
      @options[:payload_size] = s.to_i
    end
  end.parse!

  def new_websocket
    EM::WebSocketClient.connect("ws://" + @options[:websocket_host] + ":" + @options[:websocket_port] + "/app/" + @opts_app_key + "?client=js&version=1.8.5")
  end
  
  def configure_pusher
    Pusher.tap do |p|
      p.host   = @options[:api_host]
      p.port   = @options[:api_port].to_i
      p.app_id = @opts_app_id
      p.secret = @opts_secret
      p.key    = @opts_app_key
    end
  end 

  def get_stats(latencies)
    lowest = latencies.min * 1000
    highest = latencies.max * 1000
    total = latencies.inject(:+) * 1000
    len = latencies.length
    average = total.to_f / len
    sorted = latencies.sort
    median = (len % 2 == 1 ? sorted[len/2] : (sorted[len / 2 - 1] + sorted[len / 2]).to_f / 2) * 1000
    return {
      min: lowest,
      mean: average,
      median: median,
      max: highest
    }
  end

  def regular_channel
    configure_pusher
    latencies  = []
    client_who_received = 0
    messages_to_send = @options[:nb_messages].to_i
    puts "Pusher host:port : " + Pusher.host.to_s + ":" + Pusher.port.to_s
    puts "Pusher id/key/secret:" + Pusher.app_id.to_s + " " + Pusher.key.to_s + " " + Pusher.secret.to_s

    EM.run do
      # Connect clients
      (1..@options[:nb_clients]).each do
        websocket = new_websocket

        websocket.errback { |e|
          puts "Websocket error: " + e.to_s
          EM.stop
        }

        websocket.stream do |message|
          now = Time.now.to_f
          message = JSON.parse(message)
          data = message['data']
          data = JSON.parse(data) unless data.is_a?(Hash)
          if data.has_key?('time')
            latency = now - data['time']
            latencies << latency
            client_who_received += 1
            #puts "Latency: " + (latency * 1000.0).to_s + " ms."
          end
          if client_who_received >= @options[:nb_clients] then
            # Display statistics
            stats = get_stats(latencies)
            puts "Latency (ms)"
            puts "min mean median max"
            puts "#{stats[:min]} #{stats[:mean]} #{stats[:median]} #{stats[:max]}" 
            @all_latencies += latencies
          end
        end

        websocket.callback do
          websocket.send_msg({ event: 'pusher:subscribe', data: { channel: 'MY_CHANNEL'} }.to_json)
        end

      end
      # Send messages to the channel
      EM::PeriodicTimer.new(1) do 
        if messages_to_send > 0
          client_who_received = 0
          latencies  = []
          Pusher['MY_CHANNEL'].trigger_async 'an_event', { time: Time.now.to_f, payload: " " * @options[:payload_size] }
          messages_to_send -= 1
        else
          EM.stop
        end
      end
    end
  end

  extend self
end

begin
  SlangerBenchmark.regular_channel
rescue SystemExit, Interrupt
end

# Print final stats
stats = SlangerBenchmark.get_stats(SlangerBenchmark.get_latencies)
puts "Overall latencies (ms)"
puts "min mean median max"
puts "#{stats[:min]} #{stats[:mean]} #{stats[:median]} #{stats[:max]}" 
 


