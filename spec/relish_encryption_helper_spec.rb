require 'spec_helper'
require 'fernet/legacy'

describe Relish::EncryptionHelper do
  before do
  end

  describe '#decrypt' do
    it 'raises RelishDecryptionFailed on incorrect decryption secret' do
      secret = '89f057fc596f2419e83a1e15a42d7fde503edc23d3674655cabd5c5d6ad7ae61' 
      data = 'test-data'
      key = 'my-data' 
      encrypt_helper = Relish::EncryptionHelper.new('static_secret', [secret])
      decrypt_helper = Relish::EncryptionHelper.new('static_secret', ['a' * 32])
      token = encrypt_helper.encrypt(key, data)
      assert_raises(RelishDecryptionFailed) do
        decrypt_helper.decrypt(key, token)
      end
    end

    it 'ignores keys that raise JSON errors' do
      allow(Fernet::Legacy).to receive(:verifier).and_call_original

      good = 'a'*32
      bad = 'b'*32

      encrypt_helper = Relish::EncryptionHelper.new('static_secret', [good])
      data = 'test-data'
      key = 'my-data' 
      token = encrypt_helper.encrypt(key, data)

      decrypt_helper = Relish::EncryptionHelper.new('static_secret', [bad, good])
      bad_hmac = OpenSSL::HMAC.hexdigest('sha256', 'static_secret', bad)
      expect(Fernet::Legacy).to \
        receive(:verifier).with(bad_hmac, token).and_raise(MultiJson::ParseError)

      assert_equal data, decrypt_helper.decrypt(key, token)
    end
  end
end
