#\ -w -o 127.0.0.1 -p 8765
use Rack::Reloader, 0
use Rack::ContentLength

IP_ADDR_FILE = './ipaddr.log'

def save_ip_addr(addr)
  f = open(IP_ADDR_FILE, 'w')

  str = addr + "\n" + Time.now.getlocal('+08:00').to_s
  enc = `echo "#{str}" | openssl rsautl -encrypt -inkey /root/rack/rsa.key -pubin | base64`
  f.puts enc
  f.close
end

def load_ip_addr
  f = open(IP_ADDR_FILE)
  addr = f.read || 'empty'
  f.close
  addr
end

p = Proc.new do |env|
  f=open('a.txt','w')
  f.puts env.inspect
  f.close
  req = Rack::Request.new(env)
  path = req.fullpath.to_s
  if path.include?('ip')
    content = path.gsub('ip', '').gsub('/', '')
    if content.size == 0
      ret = ['200', {}, [load_ip_addr]]
    else
      save_ip_addr(content)
      ret = ['200', {}, [content]]
    end
  else
    ret = ['404', {}, []]
  end

  ret
end

run p
