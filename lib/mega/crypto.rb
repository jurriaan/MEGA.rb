require 'openssl'
module MEGA
  class Crypto
    class << self
      def prepare_key array
        packing = 'l>*'
        cipher = OpenSSL::Cipher::AES.new(128, :ECB)
        pkey = [0x93C467E3,0x7DB0C7A4,0xD1BE3F81,0x0152CB56]
        65536.downto(1) do |r|
          0.step(array.length-1, 4) do |j|
            key = [0,0,0,0]
            0.upto(3) do |i|
              if i+j < array.length
                key[i] = array[i+j]
              end
            end
            cipher.reset
            cipher.encrypt
            cipher.key = key.pack(packing)
            pkey = (cipher.update(pkey.pack(packing))).unpack(packing)
          end
        end
        pkey
      end

      def stringhash(string,key)
        cipher = OpenSSL::Cipher::AES.new(128, :ECB)
        packing = 'l>*'
        s32 = MEGA::Utils.str_to_a32(string)
        h32 = [0,0,0,0]
        s32.length.times do |i| 
          h32[i&3] ^= s32[i]
        end
        key = key.pack(packing)
        16384.times do
          cipher.reset
          cipher.encrypt
          cipher.key=key
          h32 = (cipher.update(h32.pack(packing))).unpack(packing)
        end
        h32 = [h32[0],h32[2]].pack(packing)
        [h32].pack('m0').gsub('=','')
      end
    
      def prepare_key_pw(password)
        prepare_key(MEGA::Utils.str_to_a32(password))
      end
    end
  end
end

