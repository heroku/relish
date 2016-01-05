require "fog/aws"

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
      response = db.query(@table_name,
                          :KeyConditionExpression => 'id = :id AND version > :version',
                          :FilterExpression => 'draft <> :isDraft',
                          :ExpressionAttributeValues => {
                            ':id' => {:S => id},
                            ':version' => {:N => '0'},
                            ':isDraft' => {:BOOL => true}
                          },
                          :ConsistentRead => true,
                          :ScanIndexForward => false)
      count = response.body['Count'] || 0
      if count > 0
        response.body['Items'].first
      end
    end

    def query_latest_version(id, *attrs)
      response = db.query(@table_name,
                          :KeyConditionExpression => 'id = :id AND version > :version',
                          :ExpressionAttributeValues => {
                            ':id' => {:S => id},
                            ':version' => {:N => '0'},
                          },
                          :Limit => 1,
                          :ConsistentRead => true,
                          :ScanIndexForward => false)
      count = response.body['Count'] || 0
      if count > 0
        response.body['Items'].first
      end
    end

    def put_current_version(item)
      db.put_item(@table_name, item, {:Expected => {:id => {:Exists => false}, :version => {:Exists => false}}})
    end

    def get_version(id, version, *attrs)
      response = db.get_item(@table_name, {:id => {:S => id}, :version => {:N => version}}, :ConsistentRead => true)
      response.body['Item']
    end

    def delete_version(id, version)
      db.delete_item(@table_name, id: {:S => id}, :version => {:N => version})
    end

    def put_version(id, version, item)
      db.put_item(@table_name, item,
                  :ConditionExpression => 'id <> :id AND version <> :version',
                  :ExpressionAttributeValues => {
                    ':id' => {:S => id},
                    ':version' => {:N => version}
                  })
    end

    def put(item)
      db.put_item(@table_name, item)
    end

    def query(id, consistent, limit)
      response = db.query(@table_name,
                          :KeyConditionExpression => 'id = :id AND version > :version',
                          :ExpressionAttributeValues => {
                            ':id' => {:S => id},
                            ':version' => {:N => '0'}
                          },
                          :ConsistentRead => consistent,
                          :Limit => limit,
                          :ScanIndexForward => false)
      response.body['Items']
    end

    def inspect
      "#<Relish::DynamoHelper>"
    end

    alias to_s inspect
  end
end
