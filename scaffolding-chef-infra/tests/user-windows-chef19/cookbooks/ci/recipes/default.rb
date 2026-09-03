directory 'C:/temp' do
  action :create
end

file 'C:/temp/test-chef19' do
  content "Hello from Chef 19!"
end
