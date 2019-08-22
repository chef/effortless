file '/hab/svc/user-linux-include-policy/test' do
  content "Hello world!"
end

if node['ci']['double_quote']
  file '/hab/svc/user-linux-include-policy/test_double' do
    content 'Include policy with double quote'
  end
end

if node['ci']['single_quote']
  file '/hab/svc/user-linux-include-policy/test_single' do
    content 'Include policy with double quote'
  end
end
