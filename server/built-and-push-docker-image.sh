DEV_HELLO_REPO_URI="{your-account-id}.dkr.ecr.{your-region}.amazonaws.com/dev-hello"

# change to your region for the ease of finding Docker images later
timestamp=$(TZ=":Asia/Seoul" date +%Y%m%d%H%M%S)

docker build -t "${DEV_HELLO_REPO_URI}:latest" -t "${DEV_HELLO_REPO_URI}:${timestamp}" ./packages/hello

docker push "${DEV_HELLO_REPO_URI}:latest"
docker push "${DEV_HELLO_REPO_URI}:${timestamp}"
