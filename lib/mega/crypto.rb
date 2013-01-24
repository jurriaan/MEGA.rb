require 'openssl'
require 'base64'
module MEGA
  class Crypto
    class << self
      def prepare_key array
        packing = 'l>*'
        pkey = [0x93C467E3,0x7DB0C7A4,0xD1BE3F81,0x0152CB56]
        65536.times do
          0.step(array.length-1, 4) do |j|
            key = [0,0,0,0]
            0.upto(3) do |i|
              if i+j < array.length
                key[i] = array[i+j]
              end
            end
            cipher = get_cipher(key)
            pkey = (cipher.update(pkey.pack(packing))).unpack(packing)
          end
        end
        pkey
      end

      def stringhash(string,key)
        packing = 'l>*'
        s32 = MEGA::Utils.str_to_a32(string)
        h32 = [0,0,0,0]
        s32.length.times do |i| 
          h32[i&3] ^= s32[i]
        end
        16384.times do
          cipher = get_cipher(key)
          h32 = (cipher.update(h32.pack(packing))).unpack(packing)
        end
        h32 = [h32[0],h32[2]].pack(packing)
        [h32].pack('m0').gsub('=','')
      end
    
      def prepare_key_pw(password)
        prepare_key(MEGA::Utils.str_to_a32(password))
      end
      
      @@cipher = OpenSSL::Cipher::AES.new(128, :ECB)
      
      def get_cipher(key)
        packing = 'l>*'
        @@cipher.reset
        @@cipher.encrypt
        @@cipher.key=key.pack(packing)
        @@cipher
      end
      
      # Does not work yet :(, need some help figuring out how RSA encryption works and how to parse the private key so OpenSSL can use it
      def decrypt_key(key, real_key)
        packing = 'l>*'
        cipher = get_cipher(key) 
        
	      if real_key.length == 4 
          return cipher.update(real_key.pack(packing)).unpack(packing)
        end
        x = []
        
        0.step(real_key.length-1, 4) do |i|
          cipher = get_cipher(key) 
          x += cipher.update([real_key[i],real_key[i+1],real_key[i+2],real_key[i+3]].pack(packing)).unpack(packing)
        end
        x
      end

      # Does not work yet.. :(
      
      def decrypt_session_id key, csid, privk, password_key
  			key = MEGA::Utils.base64_to_a32(key)
  			if key.length == 4
          key = decrypt_key(password_key,key)
          p csid
          
          privk = MEGA::Utils.a32_to_str(decrypt_key(key,MEGA::Utils.base64_to_a32(privk)))
          privbytes = privk.bytes.to_a
          
          #t = mbi2b(Base64.decode64(csid))
          rsa_privk = [0,0,0,0]
          4.times do |i|
            l = ((privbytes[0]*256+privbytes[1] + 7)>>3)+2
            rsa_privk[i] = mpi2b(priv.byteslice(0..l))
            #if (typeof rsa_privk[i] == 'number') break;
            privk= priv.byteslice(l..-1)  #privk = privk.substr(l);
          end
          p rsa_privk
          if privk.bytesize > 16
            #(m, d, p, q, u)
            return [k,Base64.encode64(MEGA::Utils.b2s(RSAdecrypt(t,rsa_privk[2],rsa_privk[0],rsa_privk[1],rsa_privk[3])).substr(0,43)),rsa_privk]
          else
            raise 
          end
        else
          raise
        end
      end
    end
  end
end

