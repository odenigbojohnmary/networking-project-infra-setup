# DBS DevOps Automation Assignment

End-to-end automation pipeline built for the Dublin Business School DevOps
automation assignment: Terraform provisions a GCP VM, Ansible configures it
(installs Docker, enables it on boot), a Flask app is containerised with
Docker, and two separate GitHub Actions workflows handle infrastructure vs.
application delivery. Full write-up, rationale, and Harvard-referenced
citations are in `report/DBS_DevOps_Automation_Report.pdf`.

## Repository layout

```
devops-automation-project/
├── terraform/           Part 1 — VPC, subnet, firewall rules, GCE VM (main.tf, variables.tf, outputs.tf, network.tf, firewall.tf, versions.tf, terraform.tfvars.example)
├── ansible/              Part 2 — playbook.yml (tags: configure / deploy), inventory.ini, ansible.cfg, README.md
├── app/                  Part 3 — Flask sample app (app.py, requirements.txt), Dockerfile, .dockerignore
├── .github/workflows/    Part 4 — infra.yml + deploy-app.yml (GitHub Actions CI/CD, see below)
├── diagrams/             architecture.svg / architecture.png
└── report/               DBS_DevOps_Automation_Report.docx / .pdf (Part 5)
```

## Two CI/CD workflows, one automation source of truth

Infrastructure/configuration and application deployment change at very
different rates, so they're split into two independently-triggered
workflows rather than one combined pipeline:

| Workflow | Triggers on changes to | Does |
|---|---|---|
| `.github/workflows/infra.yml` | `terraform/**`, `ansible/playbook.yml` | `terraform apply` (Part 1), then `ansible-playbook playbook.yml --tags configure` (Part 2) — installs Docker and enables it on boot |
| `.github/workflows/deploy-app.yml` | `app/**` | Builds & pushes the Docker image (Part 3), then `ansible-playbook playbook.yml --tags deploy` (Part 4) — pulls and restarts the container, then smoke-tests `/health` |

Both workflows call the *same* `ansible/playbook.yml`, just with different
`--tags`, so there is one definition of "what a correctly configured host
looks like" rather than logic duplicated across two playbooks.

## Quick start

```bash
# Part 1 — provision infrastructure
cd terraform
cp terraform.tfvars.example terraform.tfvars   # fill in your GCP project_id and ssh_public_key
terraform init
terraform apply

# Part 2 — configure the VM (installs & enables Docker)
cd ../ansible
# update inventory.ini with the terraform output `instance_public_ip`
ansible-galaxy collection install community.docker
ansible-playbook -i inventory.ini playbook.yml --tags configure

# Part 3 — build & test the container locally
cd ../app
docker build -t dbs-flask-app .
docker run -p 5000:5000 dbs-flask-app

# Part 4 — CI/CD
# Push to `main` on GitHub:
#   - changes under terraform/ or ansible/playbook.yml trigger infra.yml
#   - changes under app/ trigger deploy-app.yml
# Or run either workflow manually via workflow_dispatch in the Actions tab.
```

## Required GitHub repository secrets

| Secret | Used by | Purpose |
|---|---|---|
| `GCP_SA_KEY` | `infra.yml` | JSON key for a GCP service account with permission to manage Compute Engine/VPC resources (used by `google-github-actions/auth`) |
| `GCP_PROJECT_ID` | `infra.yml` | GCP project ID, passed to Terraform as `TF_VAR_project_id` |
| `SSH_PUBLIC_KEY` | `infra.yml` | Contents of an SSH public key, passed to Terraform as `TF_VAR_ssh_public_key` and injected into the VM's metadata |
| `GCP_VM_SSH_KEY` | `infra.yml`, `deploy-app.yml` | Matching SSH *private* key, used to connect to the VM |
| `GCP_VM_HOST` | `deploy-app.yml` | Public IP of the VM (the `instance_public_ip` Terraform output printed at the end of `infra.yml`; the IP is static once reserved, so this only needs setting once) |

`GITHUB_TOKEN` is provided automatically by GitHub Actions and used to authenticate to GHCR.

## Deliverables mapping (per assignment brief)

| Part | Deliverable | Location |
|---|---|---|
| 1 — Infrastructure | Terraform scripts + diagram | `terraform/`, `diagrams/architecture.png` |
| 2 — Configuration Management | Ansible playbook + README | `ansible/playbook.yml` (`--tags configure`), `ansible/README.md` |
| 3 — Container Deployment | Dockerfile + sample app | `app/Dockerfile`, `app/app.py` |
| 4 — CI/CD | GitHub Actions workflows | `.github/workflows/infra.yml`, `.github/workflows/deploy-app.yml` |
| 5 — Documentation | Full report (PDF, Harvard references) | `report/DBS_DevOps_Automation_Report.pdf` |
