Gem::Specification.new do |s|
  s.platform                    = Gem::Platform::RUBY
  s.name                        = 'pbenchmark'
  s.version                     = '0.0.1'
  s.summary                     = 'A benchmarking tool for servers compatible with the Pusher protocol.'
  s.description                 = 'A benchmarking tool for servers compatible with the Pusher protocol.'
  s.homepage			= 'https://github.com/tech-angels/pbenchmark'
  s.license			= 'GPL-3'

  s.required_ruby_version       = '>= 1.9.3'

  s.author                      = 'Gilbert Roulot'
  s.email                       = 'gilbert.roulot@tech-angels.com'

  s.add_dependency                'activesupport',    '~> 3.2.3'
  s.add_dependency                'eventmachine',     '~> 1.0.0'
  s.add_dependency                'em-http-request' ,  '~> 1.0.3'
  s.add_dependency                'em-websocket-client', '~>0.1.1'
  s.add_dependency                'pusher',           '~> 0.8.2'

  s.files                       = Dir['README.md', 'pbenchmark.rb']
  s.require_path                = '.'

  s.executables << 'pbenchmark'
end

