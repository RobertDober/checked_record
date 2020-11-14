require "securerandom"

module Support
  module Random
    def string_double(prefix=nil, size: 10)
      [ prefix, SecureRandom.alphanumeric(size) ]
        .compact
        .join("_")
    end
  end
end

RSpec.configure do |cfg|
  cfg.include Support::Random
end
