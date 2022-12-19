# Terraform Examples

## Before you start

You won't getting very far without a few things, so prior to getting started make sure you have a few things:
    
- Terraform (*obviously*)
- Confluent Cloud Account
- AWS Account
- Confluent "Cloud API Key & Secret"
- AWS API Key & Secret

## Getting started

The first thing you should do is clone this repo.

```bash
git clone https://github.com/zacharydhamilton/terraform-examples.git && cd terraform-examples
```

Once you've done that, create a "secrets" file to store your credentials. Do something like the following and replace the placeholders with your credentials. 

```bash
cat <<EOF > env.sh
export CONFLUENT_CLOUD_API_KEY="<replace>"
export CONFLUENT_CLOUD_API_SECRET="<replace>" 
export AWS_ACCESS_KEY_ID="<replace>"
export AWS_SECRET_ACCESS_KEY="<replace>"
export AWS_DEFAULT_REGION="us-east-2"
EOF
```

With your secrets stored in your `env.sh` file, export them to the console.

```bash
source env.sh
```

## Simple Basic cluster example

```bash
cd simple-basic-cluster
```
```bash
terraform init
```
```bash
terraform plan
```
```bash
terraform apply -auto-approve
```

When you're ready to do some cleanup:
```bash
terraform destroy -auto-approve
```

## Simple Dedicated VPC peered cluster example

> ***Note:*** this example doesn't actually create the Dedicated cluster. It just creates a network and peers it to another VPC. To add a Dedicated cluster, you would simply add the resource and add reference the network.

```bash
cd dedicated-vpc-peered-cluster
```
```bash
terraform init
```
```bash
terraform plan
```
```bash
terraform apply -auto-approve
```

When you're ready to do some cleanup:
```bash
terraform destroy -auto-approve
```

