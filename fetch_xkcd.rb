#!/usr/bin/ruby
require 'rubygems'
require 'promise'
require 'uri'
require 'json'
require 'open-uri'

class Xkcd
    attr_reader :latest
    BASE_URL = URI('http://xkcd.com')

    def initialize
        @latest = promise do
            url = BASE_URL + 'info.0.json'
            JSON.parse(url.read)
        end
    end

    def reverse_each(&block)
        @latest['num'].to_i.downto(1).each do |n|
            url = BASE_URL + "#{n}/info.0.json"
            yield JSON.parse(url.read), n
        end
    end
end

def save(dest, data)
    File.open(dest, 'wb') { |f| f.write(data) } unless File.exists?(dest)
end

xkcd = Xkcd.new
puts "latest comic: #{xkcd.latest.inspect}"

xkcd.reverse_each do |meta, n|
    date = Date.new(meta['year'].to_i, meta['month'].to_i, meta['day'].to_i)
    puts "#{n}: #{date}"
    save("#{n}.json", promise { meta.to_json })
    save("#{n}#{File.extname(meta['img'])}", promise { URI(meta['img']).read })
end
