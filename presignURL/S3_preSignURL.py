import boto3
import json
from botocore.exceptions import ClientError

def create_s3_bucket_with_presign():
    # 初始化S3客户端
    s3_client = boto3.client('s3')
    bucket_name = 'pythongotos3presign2020'
    region = 'us-east-1'  # 可以选择其他区域
    
    try:
        # 1. 创建存储桶
        print(f"正在创建存储桶: {bucket_name}")
        if region == 'us-east-1':
            s3_client.create_bucket(Bucket=bucket_name)
        else:
            s3_client.create_bucket(
                Bucket=bucket_name,
                CreateBucketConfiguration={'LocationConstraint': region}
            )
        print("存储桶创建成功!")
        
        # 等待存储桶创建完成
        s3_client.get_waiter('bucket_exists').wait(Bucket=bucket_name)
        
        # 2. 禁用默认的阻止公共访问策略
        print("禁用默认的阻止公共访问策略...")
        s3_client.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                'BlockPublicAcls': False,
                'IgnorePublicAcls': False,
                'BlockPublicPolicy': False,
                'RestrictPublicBuckets': False
            }
        )
        print("公共访问策略已禁用!")
        
        # 3. 设置桶策略允许Presigned URL访问
        print("设置桶策略...")
        bucket_policy = {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": "*",
                    "Action": "s3:GetObject",
                    "Resource": f"arn:aws:s3:::{bucket_name}/*"
                }
            ]
        }
        
        s3_client.put_bucket_policy(
            Bucket=bucket_name,
            Policy=json.dumps(bucket_policy)
        )
        print("桶策略设置成功!")
        
        # 4. 上传一个测试文件
        print("上传测试文件...")
        test_content = "This is a test file for Presigned URL demonstration"
        s3_client.put_object(
            Bucket=bucket_name,
            Key='test-file.txt',
            Body=test_content,
            ContentType='text/plain'
        )
        print("测试文件上传成功!")
        
        # 5. 生成1小时后过期的Presigned URL
        print("生成Presigned URL...")
        presigned_url = s3_client.generate_presigned_url(
            'get_object',
            Params={
                'Bucket': bucket_name,
                'Key': 'test-file.txt'
            },
            ExpiresIn=3600  # 1小时过期
        )
        
        print("\n" + "="*50)
        print("设置完成!")
        print(f"存储桶名称: {bucket_name}")
        print(f"Presigned URL (1小时后过期):")
        print(presigned_url)
        print("="*50)
        
        return presigned_url
        
    except ClientError as e:
        print(f"错误: {e}")
        return None

def test_presigned_url(url):
    """测试Presigned URL是否有效"""
    import requests
    
    try:
        print("\n测试Presigned URL...")
        response = requests.get(url)
        if response.status_code == 200:
            print("✅ Presigned URL 有效!")
            print(f"文件内容: {response.text[:100]}...")
        else:
            print(f"❌ Presigned URL 无效，状态码: {response.status_code}")
    except Exception as e:
        print(f"❌ 测试失败: {e}")

if __name__ == "__main__":
    # 确保AWS凭证已配置
    # 可以通过环境变量、~/.aws/credentials文件或IAM角色配置
    
    presigned_url = create_s3_bucket_with_presign()
    
    if presigned_url:
        test_presigned_url(presigned_url)
        
        # 显示使用说明
        print("\n" + "="*50)
        print("使用说明:")
        print("1. 生成的Presigned URL将在1小时后自动过期")
        print("2. 可以使用此URL直接下载文件，无需AWS凭证")
        print("3. 要生成新的Presigned URL，请再次运行此脚本")
        print("="*50)