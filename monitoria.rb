require 'net/https'
require 'uri'

URL = 'https://desafioperformance.b2w.io'

def request_status(path)
  uri = URI.parse(path)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  
  request = Net::HTTP::Get.new(uri.request_uri)
  res = http.request(request)
  
  res.code
end

def restart_service(path)
  uri = URI.parse(path)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Put.new(uri.request_uri)
  http.request(request)
end

def log(data)
  File.open('./log.csv', 'a') do |f|
    f.puts(data)
  end
end

start_time = Time.now
_2xx = _4xx = _5xx = 0
loop do
  status = request_status(URL + '/bairros').to_i

  if status >=200 and status < 300
    _2xx += 1
  elsif status >= 400 and status < 500
    _4xx += 1
  elsif status >= 500 and status < 600
    _5xx += 1
  end

  if Time.now - start_time >= 60
    log("#{Time.now.strftime("%F %H:%M")},#{_2xx},#{_4xx},#{_5xx}\n\n")
    if _5xx > _2xx
      restart_service(URL + '/reinicia')
    end
    _2xx = _4xx = _5xx = 0
    start_time = Time.now
  end
  sleep(2)
end
