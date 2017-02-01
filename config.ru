require 'bundler/setup'
Bundler.require

class ClearwaterBenchmarks < Roda
  plugin :public

  assets = Roda::OpalAssets.new

  route do |r|
    r.public
    assets.route r

    <<-HTML
<!DOCTYPE html>
<body>
  #{assets.js 'application'}
</body>
    HTML
  end
end

use Rack::Deflater
run ClearwaterBenchmarks
