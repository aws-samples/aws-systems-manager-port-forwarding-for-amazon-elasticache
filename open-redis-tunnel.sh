# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#!/bin/bash
echo "Have you exported your account credentials? reply y/n"
read credentialsexported

echo "What AWS Region are you using (ex. us-east-1)?"
read usedawsregion

if [[ $credentialsexported == "Y" || $credentialsexported == "y" || $credentialsexported == "YES" || $credentialsexported == "yes" ]]; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

    BASTION_HOST_NAME="bastionhost-redis"

    echo "---"
    BASHION_HOST_INSTANCE_ID=$(aws ec2 describe-instances --filters Name=tag-value,Values=$BASTION_HOST_NAME Name=instance-state-code,Values=16 --region $usedawsregion --query 'Reservations[0].Instances[0].InstanceId' --output=text)

    if [ "$BASHION_HOST_INSTANCE_ID" != "None" ]; then
      echo "We found a Bastion Host with instance id $BASHION_HOST_INSTANCE_ID and will use that to connect."
      echo "---"

      echo "Opening port now usin aws ssm start-session, this will run in an attached state and can be cancelled using your default command. (control + c)"

      aws ssm start-session --target $BASHION_HOST_INSTANCE_ID \
          --document-name AWS-StartPortForwardingSession \
          --parameters '{"portNumber":["6379"],"localPortNumber":["6379"]}' --region $usedawsregion
    else
      echo "We could not identify a configured bastion host in this environment, make sure that $BASTION_HOST_NAME is available and running."
      exit
    fi
else
    echo "We will need to be authenticated before we can continue, please do so and return afterwards."
fi
