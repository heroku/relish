# Adapted from https://github.com/stlondemand/aws_cf_signer
# Modified to support in-memory instead of on-disk signing keys
require 'openssl'
require 'time'
require 'base64'

class Relish
  class CloudFrontHelper

    attr_reader :key_pair_id

    def initialize(pem, key_pair_id)
      @key         = OpenSSL::PKey::RSA.new(pem)
      @key_pair_id = key_pair_id
    end

    def sign(url_to_sign, policy_options = {})
      separator = url_to_sign =~ /\?/ ? '&' : '?'
      if policy_options[:policy_file]
        policy = IO.read(policy_options[:policy_file])
        "#{url_to_sign}#{separator}Policy=#{encode_policy(policy)}&Signature=#{create_signature(policy)}&Key-Pair-Id=#{@key_pair_id}"
      else
        raise ArgumentError.new("'ending' argument is required") if policy_options[:ending].nil?
        if policy_options.keys.size == 1
          # Canned Policy - shorter URL
          expires_at = epoch_time(policy_options[:ending])
          policy = %({"Statement":[{"Resource":"#{url_to_sign}","Condition":{"DateLessThan":{"AWS:EpochTime":#{expires_at}}}}]})
          "#{url_to_sign}#{separator}Expires=#{expires_at}&Signature=#{create_signature(policy)}&Key-Pair-Id=#{@key_pair_id}"
        else
          # Custom Policy
          resource = policy_options[:resource] || url_to_sign
          policy = generate_custom_policy(resource, policy_options)
          "#{url_to_sign}#{separator}Policy=#{encode_policy(policy)}&Signature=#{create_signature(policy)}&Key-Pair-Id=#{@key_pair_id}"
        end
      end
    end

    def generate_custom_policy(resource, options)
      conditions = ["\"DateLessThan\":{\"AWS:EpochTime\":#{epoch_time(options[:ending])}}"]
      conditions << "\"DateGreaterThan\":{\"AWS:EpochTime\":#{epoch_time(options[:starting])}}" if options[:starting]
      conditions << "\"IpAddress\":{\"AWS:SourceIp\":\"#{options[:ip_range]}\"" if options[:ip_range]
      %({"Statement":[{"Resource":"#{resource}","Condition":{#{conditions.join(',')}}}}]})
    end

    def epoch_time(timelike)
      case timelike
      when String then Time.parse(timelike).to_i
      when Time   then timelike.to_i
      else raise ArgumentError.new("Invalid argument - String or Time required - #{timelike.class} passed.")
      end
    end

    def encode_policy(policy)
      url_safe(Base64.encode64(policy))
    end

    def create_signature(policy)
      url_safe(Base64.encode64(@key.sign(OpenSSL::Digest::SHA1.new, (policy))))
    end

    def url_safe(s)
      s.gsub('+','-').gsub('=','_').gsub('/','~').gsub(/\n/,'').gsub(' ','')
    end
  end
end
