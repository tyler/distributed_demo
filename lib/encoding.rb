module Dist
  module Encoding
    def send_string(out, string)
      out << [string.size].pack('n')
      out << string
    end
  end
end
