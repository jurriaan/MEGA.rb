module MEGA
  class Response
    attr_reader :data
    
    def initialize json
      if json.length == 1
        @data = json.first 
      else
        raise NotImplementedError.new
      end
    end
    
    def method_missing(s,*a,&b)
        case
        when a.empty? && @data.key?(s)
          @data[s.to_s]
        #when a.size == 1 && /\A(.+)=\z/ =~ s
        #  @data[$1.to_s] = a.first
        else
          super
        end
      end
  end
end