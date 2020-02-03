if node['os'] == 'linux'  
  file '/tmp/example_file' do
    content 'YAY! It works!'
  end
elsif node['os'] == 'windows'
  direcotry 'c:/temp'

  file 'c:/temp/example_file' do
    content 'YAY! It works!'
  end
end


