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
      
      def get_cipher(key, decrypt = false)
        packing = 'l>*'
        @@cipher.reset
        @@cipher.padding=0
        if decrypt
          @@cipher.decrypt 
        else
          @@cipher.encrypt
        end
        if key.is_a? String
          @@cipher.key = key
        else 
          @@cipher.key = key.pack(packing)
        end
        @@cipher
      end
      
      # Does not work yet :(, need some help figuring out how RSA encryption works and how to parse the private key so OpenSSL can use it
      def decrypt_key(key, real_key)
         @@cipher = OpenSSL::Cipher::AES.new(128, :ECB)
        packing = 'l>*'
        #p "key = #{key}, real_key = #{real_key} "
        cipher = get_cipher(key, true)
        real_key = real_key.pack(packing) unless real_key.is_a? String
        (cipher.update(real_key)+cipher.final).unpack(packing)
      end

      # Does not work yet.. :(
      
      def decrypt_session_id key, csid, privk, password_key
        p key
  			key = MEGA::Utils.base64_to_a32(key)
        p key
  			if key.size == 4

          p password_key
          p key
          key = decrypt_key(password_key,key)
          p "Decrypted key: #{key}"
          #p csid
          privk = MEGA::Utils.a32_to_str(decrypt_key(key,MEGA::Utils.base64_to_a32(privk)))
          p privk.bytesize
          p Base64.encode64(privk)
          
          #puts privk
          privbytes = privk.bytes.to_a
        
          open('test.key','w') do |f|
            f << privk
          end
          
          #key = OpenSSL::PKey::RSA.new privk
          
          #p key
         # p privbytes.collect {|a| a.to_s(16)}.join(' ').upcase
          #t = mbi2b(Base64.decode64(csid))
          
          rsa_privk = [0,0,0,0]
          4.times do |i|
            l = ((privbytes[0]*256+privbytes[1] + 7)>>3)+2
            rsa_privk[i] = mpi2b(privk.byteslice(0..l))
            #if (typeof rsa_privk[i] == 'number') break;
            privk= privk.byteslice(l..-1)  #privk = privk.substr(l);
          end
          p rsa_privk
          raise
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

