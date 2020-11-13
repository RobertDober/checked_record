require_relative "./types/abstract_type.rb"
Dir.glob(File.expand_path("../types/*.rb", __FILE__)).each do |file|
  require file
end
class CheckedRecord
  module Types
      
  end
end
