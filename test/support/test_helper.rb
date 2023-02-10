
class TestHelper
  def self.project_base
    File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  end
  def self.file_path(test_file_path)
    File.dirname(test_file_path.gsub(/test\//, ''))
  end
end
