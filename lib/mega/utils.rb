module MEGA
  class Utils
    class << self
      def padstr str
        str.ljust(str.length + 4 - (str.length % 4), "\x00")
      end
  
      def str_to_a32 str
        padstr(str).unpack('l>*')
      end
    end
  end
end