module MEGA
  class Utils
    class << self
      def padstr str
        str.ljust(str.length + 4 - (str.length % 4), "\x00")
      end
  
      def str_to_a32 str
        padstr(str).unpack('l>*')
      end
      
      def a32_to_str str
        (str).pack('l>*')
      end
      
      def base64_to_a32(s)
        str_to_a32(Base64.decode64(s))
      end
      
      def b2s barr
        #28 bit integers, possibly not needed
        [barr.reverse.inject('') {|a, b| a + b.to_s(16)}].pack('H*')
      end
    end
  end
end