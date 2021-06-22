# Port forwarding example to AWS ElastiCache for Redis using AWS Systems Manager (SSM)

This project is a sample code repository that shows a complete example of how to set up port forwarding to a remote ElastiCache cluster.

The purpose of this code repository is to provide you with a complete example of both AWS service components and the necessary configuration. In this way, the project enables you to port-forward from your local machine to a secure AWS ElastiCache for Redis cluster. As a result, you can seamlessly and securely interact with remote resources running within private VPC subnets from your local development machine.

Within this project, we are also deploying Amazon Virtual Private Cloud (Amazon VPC) configuration that simulates a common structure of public / private subnets with all of the necessary network infrastructure elements. Amazon VPC is deployed as part of a nested stack within the provided template.yml file.

From the CloudFormation template we also provision a sample AWS ElastiCache for Redis cluster and an Amazon EC2 instance. All resources are deployed within a private VPC subnet. Deployed Amazon EC2 instance is running an [HAProxy](http://www.haproxy.org) server that acts as a load balancer for port forwarded requests towards ElastiCache nodes.

## Project prerequisites
---

The following tools are necessary for you to deploy described AWS resources, start port forwarding via SSM and test the forwarded connection.

1. Installed [AWS Command Line Interface (CLI)](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html).
2. Installed [Session Manager plugin for the AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
3. (Optional) Installed [Redis CLI](https://redis.io/topics/rediscli) used to test the forwarded connection.
4. Access to an AWS account with respective permissions.

## Project Deployment
---

1. Assuming your AWS CLI is configured to use AWS Region `eu-west-1`, within project home directory, execute: 

```
aws cloudformation deploy --template-file template.yml --stack-name SsmComputeStack --parameter-overrides AvailabilityZones="eu-west-1a,eu-west-1b,eu-west-1c" --capabilities CAPABILITY_IAM
```

If you do not wish to use `eu-west-1` region, then update the `AvailabilityZones` parameter according to the preferred region. 

2. Within project home directory, execute `./open-redis-tunnel.sh` script that will start a port forwarding session using SSM. Optionally, you can execute AWS CLI `start-session` command directly from the console with appropriate parameters.
3. (Optional) From any location, open a second console window and execute `redis-cli ping`. You should receive “PONG” in response. Receiving “PONG” indicates that you have successfully port-forwarded your machine and that you are able to reach remote Redis cluster.

## Project Clean-up
---

From any location on your machine execute `aws cloudformation delete-stack --stack-name SsmComputeStack`. This action will delete all of provisioned compute resources and any accompanying configuration. Since Amazon VPC configuration is provisioned as a nested stack, the Amazon VPC configuration is also going to be deleted. Alternatively, you can delete the _SsmComputeStack_ stack via the AWS Console.


## License
---
This library is licensed under the MIT-0 License. See the [LICENSE](./LICENCE) file.