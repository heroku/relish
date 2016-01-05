require "fog/aws"

class Relish
  class S3Helper

    def initialize(aws_access_key, aws_secret_key, bucket_name)
      @aws_access_key = aws_access_key
      @aws_secret_key = aws_secret_key
      @bucket_name = bucket_name
    end

    def db
      @db ||= Fog::Storage::AWS.new(:aws_access_key_id => @aws_access_key, :aws_secret_access_key => @aws_secret_key)
    end

    def signed_url(name, expires)
      db.get_object_https_url(@bucket_name, name, expires)
    end
  end
end
