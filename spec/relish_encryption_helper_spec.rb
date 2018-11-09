require 'spec_helper'

describe Relish::EncryptionHelper do
  let(:good_secret) { 'a' * 32    }
  let(:bad_secret)  { 'b' * 32    }
  let(:key)         { 'my-key'    }
  let(:data)        { 'test-data' }

  describe '#decrypt' do
    it 'raises RelishDecryptionFailed on incorrect decryption secret' do
      encrypt_helper = Relish::EncryptionHelper.new('static_secret', [good_secret])
      decrypt_helper = Relish::EncryptionHelper.new('static_secret', [bad_secret])
      token = encrypt_helper.encrypt(key, data)

      assert_raises(RelishDecryptionFailed) do
        decrypt_helper.decrypt(key, token)
      end
    end

    it 'ignores keys that raise JSON errors' do
      allow(Fernet::Legacy).to receive(:verifier).and_call_original
      encrypt_helper = Relish::EncryptionHelper.new('static_secret', [good_secret])
      token = encrypt_helper.encrypt(key, data)

      decrypt_helper = Relish::EncryptionHelper.new('static_secret', [bad_secret, good_secret])
      bad_hmac = OpenSSL::HMAC.hexdigest('sha256', 'static_secret', bad_secret)
      expect(Fernet::Legacy).to \
        receive(:verifier).with(bad_hmac, token).and_raise(MultiJson::ParseError)

      assert_equal data, decrypt_helper.decrypt(key, token)
    end
  end
end
