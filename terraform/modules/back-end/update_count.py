import boto3, json
from decimal import Decimal

# Initialize AWS resources
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor_count')
cloudwatch = boto3.client('cloudwatch')  # 👈 Add this line

def convert_decimal(obj):
    if isinstance(obj, Decimal):
        return int(obj) if obj % 1 == 0 else float(obj)
    raise TypeError("Object of type Decimal is not JSON serializable")

def lambda_handler(event, context):
    try:
        response = table.get_item(Key={'PK': 'visitor_count'})
        
        if 'Item' in response:
            current_count = response['Item'].get('updated_total_count', Decimal(0))
            updated_count = current_count + Decimal(1)

            table.update_item(
                Key={'PK': 'visitor_count'},
                UpdateExpression='SET updated_total_count = :val1',
                ExpressionAttributeValues={':val1': updated_count}
            )

            # ✅ Push custom metric to CloudWatch
            cloudwatch.put_metric_data(
                Namespace='CloudResume',
                MetricData=[
                    {
                        'MetricName': 'VisitorCount',
                        'Value': float(updated_count),
                        'Unit': 'Count'
                    }
                ]
            )

            return {
                'statusCode': 200,
                'headers': {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type"
                },
                'body': json.dumps({'updated_total_count': convert_decimal(updated_count)})
            }
        else:
            table.put_item(
                Item={'PK': 'visitor_count', 'updated_total_count': Decimal(1)}
            )

            # ✅ Push initial count to CloudWatch
            cloudwatch.put_metric_data(
                Namespace='CloudResume',
                MetricData=[
                    {
                        'MetricName': 'VisitorCount',
                        'Value': 1.0,
                        'Unit': 'Count'
                    }
                ]
            )

            return {
                'statusCode': 200,
                'headers': {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type"
                },
                'body': json.dumps({'updated_total_count': 1})
            }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            'body': json.dumps(f"Error updating data: {str(e)}")
        }
