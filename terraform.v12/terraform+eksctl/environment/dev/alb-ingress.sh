#!/bin/bash
#Purpose: ALB Ingress Setup
#Maintainer: Muhammad Asim <quickbooks2018@gmail.com>


REGION="us-east-1"
CLUSTER_NAME="cloudelligent-eks"
POLICY_ARN=`aws sts get-caller-identity |  awk '{ print $2 }' | grep "iam" | cut -d':' -f2,3,4,5`


# Create an IAM OIDC provider and associate it with your cluster. If you don't have eksctl version 0.14.0 or later installed, complete the instructions in Installing or Upgrading eksctl to install or upgrade it. You can check your installed version with eksctl version.

eksctl utils associate-iam-oidc-provider \
    --region $REGION \
    --cluster $CLUSTER_NAME \
    --approve


# Create an IAM policy called ALBIngressControllerIAMPolicy for the ALB Ingress Controller pod that allows it to make calls to AWS APIs on your behalf. Use the following AWS CLI command to create the IAM policy in your AWS account. You can view the policy document on GitHub.

aws iam create-policy \
    --policy-name ALBIngressControllerIAMPolicy \
    --policy-document https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json

# Create a Kubernetes service account named alb-ingress-controller in the kube-system namespace, a cluster role, and a cluster role binding for the ALB Ingress Controller to use with the following command. If you don't have kubectl installed, complete the instructions in Installing kubectl to install it.
 
 kubectl create serviceaccount alb-ingress-controller -n kube-system
 
 kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml



# Create an IAM role for the ALB ingress controller and attach the role to the service account created in the previous step. If you didn't create your cluster with eksctl, then use the instructions on the AWS Management Console or AWS CLI tabs.

# SEARCH ----> IAM ---> POLICY ---> ALBIngressControllerIAMPolicy ---> COPY THE ARN BELOW

# https://stackoverflow.com/questions/47313778/find-role-being-used-on-server-from-aws-cli

eksctl create iamserviceaccount \
    --region us-east-1 \
    --name alb-ingress-controller \
    --namespace kube-system \
    --cluster cloudelligent-eks \
    --attach-policy-arn arn:$POLICY_ARN:policy/ALBIngressControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --approve


# Deploy the ALB Ingress Controller with the following command.

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml


echo -e "\nOpen the ALB Ingress Controller deployment manifest for editing with the following command\n"

echo -e "\nkubectl edit deployment.apps/alb-ingress-controller -n kube-system\n"

echo -e "\nThe line number is 41, at the  end of line press ENTER\n"

echo -e "\n - --cluster-name=$CLUSTER_NAME \n"
echo -e "\n - --aws-vpc-id=vpc-0419355bf920ef189 \n"
echo -e "\n - --aws-region=us-east-1 \n"


 
echo -e "\n If ALB is not setup check the logs with mentioned below commands \n"


echo -e "\n    kubectl logs -n kube-system   deployment.apps/alb-ingress-controller   \n"
    
    
echo -e "\n Confirm that the ALB Ingress Controller is running with the following command\n"

echo -e "\n kubectl get pods -n kube-system \n"


#END
