<br />

# **!!!! D R A F T** !!!

# **Creating AWS EKS cluster using terraform and deploying two sample applications**

<br />

## Technologies used:

1. Terraform
2. AWS
3. GitLab
4. ArgoCD
5. Docker

<br />

## Diagram:
XXXXXX
XXXXXX
XXXXXX

<br />

## Steps:


<br />
<br />
<br />

### Create S3 bucket and dynamodb table for terraform backend state locking:

#### Create the S3 bucket:
```
aws s3api create-bucket --bucket eks-sunstar-apps-tfstate --region us-east-1
```

<br />

#### Block all public access:
```
aws s3api put-public-access-block \
  --bucket eks-sunstar-apps-tfstate \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

<br />

```
# If production (recommedned by hashicorp):
aws s3api put-bucket-versioning --bucket eks-sunstar-apps-tfstate --versioning-configuration Status=Enabled
```

<br />

#### Create a dynamodb table for state locking:
```
# While still possible in v1.11.x, the use of dynamodb for state locking is going to be deprecated in a future version of terraform.
# Use "use_lockfile = true" in the backend configuration block instead.
# https://developer.hashicorp.com/terraform/language/backend/s3#state-locking

aws dynamodb create-table \
    --table-name eks-apps-tf-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

<br />

```
aws s3api put-bucket-encryption --bucket eks-sunstar-apps-tfstate --server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}'
```

<br />

###### **DISCLAIMER**
Please consult the official documentation before using.
NOBODY BUT YOU IS RESPONSIBLE FOR ANY USE OR DAMAGE THIS COMMANDS MAY CAUSE.
THIS IS INTENDED FOR EDUCATIONAL PURPOSES ONLY. USE AT YOUR OWN RISK.



<!-- How to install
Repo providers
ssh -->
