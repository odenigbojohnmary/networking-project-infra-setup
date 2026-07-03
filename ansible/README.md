# Part 2 — Configuration Management (Ansible)

This directory automates configuration of the Compute Engine VM provisioned by
Terraform (`../terraform`): installing Docker, enabling it on boot, and
(when asked) deploying the containerised Flask application.

## Files

| File | Purpose |
|---|---|
| `playbook.yml` | Single playbook, split into two tag groups so it can be driven by two different pipelines from one source of truth: `--tags configure` installs Docker CE and enables the systemd service (`enabled: true` guarantees start on boot); `--tags deploy` pulls/runs the application container. Running it with no `--tags` does both, useful for a manual first-time bring-up. |
| `inventory.ini` | Static inventory listing the target VM. Replace `REPLACE_WITH_VM_PUBLIC_IP` with the `instance_public_ip` Terraform output, or generate a dynamic inventory instead (see below). |
| `ansible.cfg` | Local project settings (default inventory path, disables strict host-key checking for a fresh VM's first connection). |

## Why one playbook, two tags, two workflows

The assignment's four parts map naturally onto two operational concerns that
change at very different rates: infrastructure/configuration (how many VMs
exist, what's installed on them) changes rarely, while the application
(what container image is running) changes on every commit. Splitting these
into `.github/workflows/infra.yml` (Terraform + Ansible `--tags configure`)
and `.github/workflows/deploy-app.yml` (Docker build/push + Ansible
`--tags deploy`) means a routine app change never re-applies Terraform or
reinstalls Docker, and a VM resize never rebuilds/redeploys the container.
Keeping both tag groups in a single `playbook.yml`, rather than two separate
playbook files, avoids duplicating the `hosts`/`vars` block and keeps "what a
correctly configured host looks like" defined in exactly one place.

## Automation flow

1. **`infra.yml`** runs `terraform apply` (Part 1), captures
   `instance_public_ip` as a job output, writes it into a generated
   `inventory.ini`, then runs `ansible-playbook playbook.yml --tags configure`,
   which:
   - refreshes the apt cache and installs prerequisite packages;
   - adds Docker's official GPG key and apt repository;
   - installs `docker-ce`, `docker-ce-cli`, `containerd.io`, and the
     buildx/compose plugins;
   - adds the SSH user to the `docker` group;
   - enables and starts the `docker` systemd unit so the daemon survives
     reboots without manual intervention.
2. **`deploy-app.yml`** runs independently, on every push to `app/**`. It
   builds and pushes the Docker image, then runs
   `ansible-playbook playbook.yml --tags deploy`, which authenticates to
   GHCR using CI-injected credentials, pulls the latest application image,
   and (re)starts the container with a restart policy of `always`.
3. Ansible's idempotency means re-running either tag group against an
   already-configured host performs no destructive changes — only the
   drifted tasks report as "changed".

## Running it locally

```bash
cd ansible
ansible-galaxy collection install community.docker   # provides docker_container/docker_image modules
ansible-playbook -i inventory.ini playbook.yml --tags configure   # server prep only
ansible-playbook -i inventory.ini playbook.yml --tags deploy      # app deploy only
ansible-playbook -i inventory.ini playbook.yml                    # both, first-time bring-up
```

## Dynamic inventory (alternative)

Instead of the static `inventory.ini`, the `google.cloud.gcp_compute` inventory
plugin can query the GCP API directly using instance labels
(`project: dbs-devops-assignment`) so no IP address ever needs to be
hand-copied. This was not used here to keep the assignment reviewable without
extra Ansible collections, but it is the recommended approach for anything
beyond a single-VM demo (see report, Section: Alternative Approaches).
