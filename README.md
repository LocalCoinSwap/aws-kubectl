# Github Action for Kubernetes CLI

Action to provide `kubectl` on Github Actions.

There are many such actions but we can't control what an action does when they update them. If their account gets compromised, every Github Action which uses their action are under threat because some AWS keys are provided to actions.

Until AWS's official [action](https://github.com/aws-actions/amazon-eks-fargate) comes around we will have to use our own action to use kubectl.


## Usage

`.github/workflows/deploy.yml`

```yaml
on:
  push:
    branches: [master]

name: deploy

env:
  AWS_DEFAULT_REGION: us-east-1

jobs:
  deploy:
    name: Deploy to AWS EKS Cluster
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v2

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_DEFAULT_REGION }}

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1

    - name: Set new image on deployment
      uses: LocalCoinSwap/aws-kubectl@v4
      env:
        KUBE_CONFIG_DATA: ${{ secrets.YOUR_KUBE_CONFIG_DATA_KEY }}
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        ECR_REPOSITORY: your-app
        IMAGE_TAG: ${{ github.sha }}
      with:
        args: set image deployment/$ECR_REPOSITORY $ECR_REPOSITORY=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

```

## Secrets

`KUBE_CONFIG_DATA` – **required**: A base64-encoded kubeconfig file data.

It's important that you verify what you encode. There could be many configs in the `$HOME/.kube/config` file on local systems.

```bash
cat $HOME/.kube/config | base64
```
