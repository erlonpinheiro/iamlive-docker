# iamlive-docker

[![Push latest version to DockerHub](https://github.com/erlonpinheiro/iamlive-docker/actions/workflows/release.yml/badge.svg)](https://github.com/erlonpinheiro/iamlive-docker/actions/workflows/release.yml) [![Dockerhub pulls](https://img.shields.io/docker/pulls/erlonpinheiro/iamlive-docker)](https://hub.docker.com/r/erlonpinheiro/iamlive-docker)


Run [iamlive](https://github.com/iann0036/iamlive) as a Docker container.

To read more about how iamlive works, see [Determining AWS IAM Policies According To Terraform And AWS CLI
](https://meirg.co.il/2021/04/23/determining-aws-iam-policies-according-to-terraform-and-aws-cli/)

## Requirements

1. [AWS Account Credentials Configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
1. [Docker](https://docs.docker.com/get-docker/)

## Getting Started

### Run iamlive by building the Docker image locally

1. Git clone this repo, **or** [curl](https://curl.se/) relevant files
   ```
   curl -L --remote-name-all https://raw.githubusercontent.com/erlonpinheiro/iamlive-docker/master/{Dockerfile,.dockerignore,Makefile,entrypoint.sh,generate_ca.sh} && \
   chmod +x entrypoint.sh generate_ca.sh
   ```
2. **Terminal #1**: Build the Docker image
   ```bash
   make build
   ```
3. **Terminal #2**: Run the Docker image for the first time
    ```bash
    make run
    # Runs in the background ...
    # Average Memory Usage: 88MB
    ```
4. **Terminal #1**: Copy CA certificate from the container to host; To keep `ca.pem` valid for future runs, **do not remove** the `iamlive-docker` container.
    ```bash
    make copy
    ```

### Proxy IAM Requests Through iamlive

1. **Terminal #1**: Set AWS credentials
    ```bash
    export AWS_PROFILE=MY_AWS_PROFILE
    ```

    **OR**
    ```bash
    export AWS_ACCESS_KEY_ID=MY_AWS_ACCESS_KEY_ID
    ```
    ```bash
    export AWS_SECRET_ACCESS_KEY=MY_AWS_SECRET_ACCESS_KEY
    ```
1. **Terminal #1**: Set required environment variables [HTTP_PROXY, HTTPS_PROXY](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-proxy.html) and [AWS_CA_BUNDLE](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html#envvars-list)
    ```bash
    export \
        HTTP_PROXY=http://127.0.0.1:80 \
        HTTPS_PROXY=http://127.0.0.1:443
    ```
    
    **AND**

    ```bash
    export AWS_CA_BUNDLE="${HOME}/.iamlive/ca.pem"
    ```
1. **Terminal #1**: Test it by making calls to AWS, using the CLI is the easiest way
   ```bash
   aws s3 ls
   ```

   **Terminal #2**: iamlive output after `aws s3 ls`
   ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:ListAllMyBuckets"
                ],
                "Resource": "*"
            }
        ]
    }   
   ```
1. **Terminal #1**: Stop the iamlive container
   ```bash
   make stop
   ```
1. **Terminal #2**: Start iamlive container again (no need to invoke `make copy`)
   ```bash
   make start
   ```
1.  **Terminal #1**: Do your thing again ;)

### Run iamlive by docker compose

1. Git clone this repo, **or** [curl](https://curl.se/) the docker-compose file
   ```bash
   curl -L --remote-name-all https://raw.githubusercontent.com/erlonpinheiro/iamlive-docker/master/docker-compose.yml
   ```

2. Create the required local directories
   ```bash
   mkdir -p "$PWD/iamlive/logs" "$PWD/iamlive/.iamlive"
   ```

3. Start the container
   ```bash
   docker compose up -d
   ```
    The container will start the proxy listening on ports 80 and 443, internally mapped to port 10080.

    Logs will be written to $PWD/iamlive/logs/iamlive.log

    The generated certificate will be located at $PWD/iamlive/.iamlive/ca.pem

4. Automatically start the container on reboot (optional)
   ```bash
   docker update --restart=always iamlive-proxy
   ```

5. Export environment variables to redirect AWS CLI / Terraform traffic

    Set AWS credentials
    ```bash
    export AWS_PROFILE=MY_AWS_PROFILE
    ```

    **OR**
    ```bash
    export AWS_ACCESS_KEY_ID=MY_AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=MY_AWS_SECRET_ACCESS_KEY
    ```

    Set required environment variables [HTTP_PROXY, HTTPS_PROXY](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-proxy.html) and [AWS_CA_BUNDLE](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html#envvars-list)

    ```bash
    export \
        HTTP_PROXY=http://127.0.0.1:80 \
        HTTPS_PROXY=http://127.0.0.1:443 \
        AWS_CA_BUNDLE="$PWD/iamlive/.iamlive/ca.pem"
    ```

    ⚠️ Important:

        - Do not export these variables before running terraform init.    
        - Terraform init downloads Terraform providers and plugins from public registries which do not support self-signed certificates.
        - This may cause certificate validation errors.
        - Only export these variables after initialization is complete to monitor AWS calls.

6. Viewing logs

    Display log content:
    ```bash
    cat "$PWD/iamlive/logs/iamlive.log"
    ```

    Live streaming the log (real-time output):
    ```bash
    docker logs -f iamlive-proxy
    ```

7. Force flushing the log file
    ```bash
    docker exec iamlive-proxy kill -HUP 1
    ```

8. Remove container, cleanup directories, and unset environment variables
    ```bash
    docker compose down
    rm -rf "$PWD/iamlive/logs/"* "$PWD/iamlive/.iamlive/"*

    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset AWS_CA_BUNDLE
    ```

## Authors

This repository is maintained by [Erlon Pinheiro](https://github.com/erlonpinheiro) but it is based on the original created and maintained by [Meir Gabay](https://github.com/unfor19)

## License

This project is licensed under the [DBAD](https://dbad-license.org/) License - see the [LICENSE](https://github.com/erlonpinheiro/iamlive-docker/blob/master/LICENSE) file for details
