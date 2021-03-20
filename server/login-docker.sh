aws ecr get-login-password --region {your-region} | docker login --username AWS --password-stdin {your-account-id}.dkr.ecr.{your-region}.amazonaws.com
