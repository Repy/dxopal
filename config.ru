# config.ru for local development
require 'tempfile'
require 'opal/sprockets'

opal_server = Opal::Sprockets::Server.new{|s|
  # Let javascript_include_tag to serve compiled version of lib/dxopal.rb
  s.append_path 'lib'
  s.main = 'dxopal'
  # Serve static files
  s.public_root = __dir__
  # Just serve static ./index.html
  s.use_index = false
}

DEMO_DIRS = Dir["examples/*"].reject{|x| x =~ /_vendor|top_page/}.map{|x| "/#{x}"}
DEMO_DIRS << ""  # top page
DEMO_DIRS << "/starter-kit"
DEMO_DIRS.each do |path|
  # Compile dxopal.js dynamically to avoid manual recompiling
  map "#{path}/index.html" do
    index = Opal::Sprockets::Server::Index.new(nil, opal_server)
    run lambda{|env|
      s = File.read(".#{path}/index.html")
              .gsub(%r{<script (.*)dxopal(.min)?.js"></script>}){
                s = index.javascript_include_tag(opal_server.main)
                s += "<script type='text/javascript' src='/_vendor/matter-0.10.0.js'></script>" if path =~ /matter/
                s
              }
      [200, {}, [s]]
    }
  end
  if File.exist?(".#{path}/main.rb")
    map "#{path}/main.rb" do
      run lambda{|env|
        [200, {'Cache-Control' => 'no-cache'}, [File.read(".#{path}/main.rb")]]
      }
    end
  end
end

run lambda{|env|
  if env["PATH_INFO"] == '/'
    [301, {"Location" => '/index.html'}, [""]]
  else
    opal_server.call(env)
  end
}
