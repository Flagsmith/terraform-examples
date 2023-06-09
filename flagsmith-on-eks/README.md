# EKS

The following prerequisites are expected to apply this example configuration successfully:

- Terraform: [install instructions](https://developer.hashicorp.com/terraform/downloads).
- An up and running EKS cluster with a VPC set up for at least two availability zones. [Read an official example on Terraform EKS provisioning](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks).
- A configured AWS CLI or a Terraform AWS provider. [Read more on AWS provider configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration).

## Usage

If you don't have a running EKS cluster yet, you can provision it with Terraform using the official Terraform EKS example:

```bash
git clone https://github.com/hashicorp/learn-terraform-provision-eks-cluster.git
cd learn-terraform-provision-eks-cluster
terraform apply
```

Clone this repository:

```bash
git clone https://github.com/Flagsmith/terraform-examples.git
cd terraform-examples
```

Apply the configuration:

```bash
cd examples/flagsmith-on-eks
terraform apply
```

Terraform will ask for one input:

- **`var.cluster_name`**: the name of the EKS cluster Flagsmith gets deployed to. Note that your AWS CLI/provider should be configured with the cluster's region set as default.

## Resources

Terraform will manage the following resources:

- A subnet group and a security group for RDS. [Read more about how VPCs and RDS instances relate](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html).
- A minimal `db.t3.micro` RDS instance. See [examples/flagsmith-on-eks/rds.tf](examples/flagsmith-on-eks/rds.tf) for configuration.
- A Kubernetes secret containing the full database DSN.
- A Helm release based on Flagsmith's [official Helm charts](https://flagsmith.github.io/flagsmith-charts/), configured to use the RDS instance as the database backend. [Read an official example for managing Helm releases with Terraform](https://developer.hashicorp.com/terraform/tutorials/kubernetes/helm-provider).

Flagsmith's endpoints are exposed in `LoadBalancer` mode.

**NOTE**: The database won't get backed up upon perfoming `terraform destroy`. If you'd rather keep your data, be sure to remove the

```
  skip_final_snapshot    = true
```

line in the `aws_db_instance` configuration.

## Outputs

After successfull `terraform apply` you will see these outputs:

- **`flagsmith_api_endpoint`**: This URL should be provided to your SDKs. (Read more on configuring the Flagsmith SDKs)[https://docs.flagsmith.com/clients/server-side#configuring-the-sdk].
- **`flagsmith_frontend_endpoint`**: Flagsmith's UI is accesible via this endpoint.

## Access the UI endpoint locally

```bash
kubectl port-forward svc/flagsmith-frontend 8080:8080
```

Navigate to your newly deployed Flagsmith: http://localhost:8080

Have fun!
