require "fog"

class Relish
  class DynamoHelper

    def initialize(aws_access_key, aws_secret_key, table_name)
      @aws_access_key = aws_access_key
      @aws_secret_key = aws_secret_key
      @table_name = table_name
    end

    def db
      @db ||= Fog::AWS::DynamoDB.new(:aws_access_key_id => @aws_access_key, :aws_secret_access_key => @aws_secret_key)
    end

    def query_current_version(id)
      response = db.query(@table_name, {:S => id}, :ConsistentRead => true, :Limit => 1, :ScanIndexForward => false)
      if response.status != 200
        raise('status: #{response.status}')
      end
      if response.body['Count'] == 1
        response.body['Items'].first
      end
    end

    def put_current_version(item)
      response = db.put_item(@table_name, item, {:Expected => {:id => {:Exists => false}, :version => {:Exists => false}}})
      if response.status != 200
        raise('status: #{response.status}')
      end
    end

    def get_version(id, version)
      response = db.get_item(@table_name, {:HashKeyElement => {:S => id}, :RangeKeyElement => {:N => version}})
      if response.status != 200
        raise('status: #{response.status}')
      end
      response.body['Item']
    end

    def put_version(id, version, item)
      response = db.put_item(@table_name, item, {:Expected => {:id => {:Value => {:S => id}}, :version => {:Value => {:N => version}}}})
      if response.status != 200
        raise('status: #{response.status}')
      end
    end

    def put(item)
      response = db.put_item(@table_name, item)
      if response.status != 200
        raise('status: #{response.status}')
      end
    end

    def query(id, consistent, limit)
      response = db.query(@table_name, {:S => id}, :ConsistentRead => consistent, :Limit => limit, :ScanIndexForward => false)
      if response.status != 200
        raise('status: #{response.status}')
      end
      response.body['Items']
    end
  end
end
