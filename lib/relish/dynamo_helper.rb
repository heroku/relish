require "fog"

class Relish
  class DynamoHelper

    def initialize(aws_access_key, aws_secret_key, table_name, region = 'us-east-1')
      @aws_access_key = aws_access_key
      @aws_secret_key = aws_secret_key
      @table_name     = table_name
      @region         = region
    end

    def db
      @db ||= Fog::AWS::DynamoDB.new(:aws_access_key_id => @aws_access_key, :aws_secret_access_key => @aws_secret_key, :region => @region)
    end

    def query_current_version(id, *attrs)
      response = db.query(@table_name, {:S => id}, :ConsistentRead => true, :Limit => 1, :ScanIndexForward => false)
      if response.body['Count'] == 1
        response.body['Items'].first
      end
    end

    def put_current_version(item)
      db.put_item(@table_name, item, {:Expected => {:id => {:Exists => false}, :version => {:Exists => false}}})
    end

    def get_version(id, version, *attrs)
      response = db.get_item(@table_name, {:HashKeyElement => {:S => id}, :RangeKeyElement => {:N => version}}, :ConsistentRead => true)
      response.body['Item']
    end

    def put_version(id, version, item)
      db.put_item(@table_name, item, {:Expected => {:id => {:Value => {:S => id}}, :version => {:Value => {:N => version}}}})
    end

    def put(item)
      db.put_item(@table_name, item)
    end

    def query(id, consistent, limit)
      response = db.query(@table_name, {:S => id}, :ConsistentRead => consistent, :Limit => limit, :ScanIndexForward => false)
      response.body['Items']
    end

    def inspect
      "#<Relish::DynamoHelper>"
    end

    alias to_s inspect
  end
end
