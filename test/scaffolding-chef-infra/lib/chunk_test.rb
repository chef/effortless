require 'minitest/autorun'
require 'minitest/pride'
require 'test_helper'
require 'json'

puts TestHelper.project_base

class TestChunk < Minitest::Test
  def template_path
    File.join(TestHelper.file_path(__FILE__), 'windows', 'client-chunk.rb')
  end

  def handlebars_eval(template_path, node_binding)
    f = Tempfile.new('handlebars')

    f.write(%Q|
      const fs = require('fs');
      const Handlebars = require('#{TestHelper.project_base}/node_modules/handlebars/dist/handlebars.js')
      fs.readFile('#{template_path}', (err, data) => {
        if (err) throw err;
        var template = Handlebars.compile(data.toString());
        console.log(template(#{node_binding.to_json}))
      });
    |)

    f.rewind
    # puts f.read
    node_exec=%x|node #{f.path}|

  end

  def test_chunk
    node_binding = {
      "pkg" => {
        "svc_data_path" => "C:/hab/svc/chef-client/data",
        "svc_var_path" => "C:/hab/svc/chef-client/var",
        "svc_config_path" => "C:/hab/svc/chef-client/config",
      },
      "cfg" => {
        "env_path_prefix" => ";C:/WINDOWS;C:/WINDOWS/system32/;C:/WINDOWS/system32/WindowsPowerShell/v1.0;C:/ProgramData/chocolatey/bin",
        "ssl_verify_mode" => ":verify_peer",
        "rubygems_url" => "https://www.rubygems.org",
      }
    }
    puts handlebars_eval(template_path, {})
    assert_equal 1, 1
  end
end