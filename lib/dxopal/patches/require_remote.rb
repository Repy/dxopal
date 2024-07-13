require 'opal-parser'
module Kernel
  def require_remote(url)
    %x{
      var r = new XMLHttpRequest();
      r.overrideMimeType("text/plain"); // https://github.com/yhara/dxopal/issues/12
      r.open("GET", encodeURI(url), false);
      r.send('');
    }
    Kernel.eval(`r.responseText`,nil,`encodeURI(url)`)
  end
end
