source 'https://rubygems.org'

gem 'rake', '~> 10.0'
gem 'pry'
gem 'debug'

group :spec do
    gem 'rspec', '~> 3.0'
end

group :prof do

    if File.exist? '../monitor'
        gem 'rkn-monitor', path: '../monitor'
    end

    gem 'stackprof'
    gem 'ruby-prof'
    gem 'benchmark-ips'
    gem 'memory_profiler'
end

if File.exist? '../../scnr/scnr'
    gem 'scnr', path: '../../scnr/scnr'
end

if File.exist? '../rkn'
    gem 'rkn', path: '../rkn'
end

if File.exist? '../../scnr/engine'
    gem 'scnr-engine', path: '../../scnr/engine'
end

if File.exist? '../../scnr/application'
    gem 'scnr-application', path: '../../scnr/application'
end

if File.exist? '../application'
    gem 'rkn-application', path: '../application'
end

if File.exist? '../../ecsypno/license-client'
    gem 'ecsypno-license-client', path: '../../ecsypno/license-client'
else
    gem 'ecsypno-license-client'
end

if File.exist? '../../scnr/license-client'
    gem 'scnr-license-client', path: '../../scnr/license-client'
end

if File.exist? '../license-client'
    gem 'rkn-license-client', path: '../license-client'
end

gemspec
