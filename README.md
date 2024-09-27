# Terraform AWS template

To use this template initialise a new repository with this as the template.

## Terraform scripts

Using command line prompt navigate to the ```/src/``` directory and execute the following scripts.

```bash
terraform init
```

```bash
terraform plan
```

```bash
terraform apply
```

To gain access to the terraform outputs use this script.

```bash
terraform output -raw <output_name>
```

To remove all the requisitioned resources use the following script.

```bash
terraform destroy
```

