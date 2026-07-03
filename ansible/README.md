# Part 2 — Configuration Management (Ansible)

This directory automates configuration of the Compute Engine VM provisioned by
Terraform (`../terraform`): installing Docker and nginx, and enabling both to
start on boot. **Deploying or running the application itself is out of scope
for this playbook** — it only prepares the host so that a container can be
started on it later, with nginx already reverse-proxying port 80 to the
port the app is expected to listen on (5000).

## Files

| File | Purpose |
|---|---|
| `playbook.yml` | Installs Docker CE from the official repository and enables the `docker` systemd service (`enabled: true` guarantees start on boot); installs nginx, removes the default site, and templates a reverse-proxy site config that forwards `:80` → `127.0.0.1:5000`, then enables the `nginx` systemd service. |
| `templates/app-proxy.conf.j2` | nginx server block template. `app_upstream_port` (default `5000`) controls the proxied port. |
| `inventory.ini` | Static inventory listing the target VM. Replace `REPLACE_WITH_VM_PUBLIC_IP` with the `instance_public_ip` Terraform output, or let the CI workflow generate it (see below). |
| `ansible.cfg` | Local project settings (default inventory path, disables strict host-key checking for a fresh VM's first connection). |

## Automation flow

1. `.github/workflows/terraform.yml`'s `terraform-apply` job runs
   `terraform apply` (Part 1), captures `instance_public_ip` as a job
   output.
2. The `configure` job (`needs: terraform-apply`) reads that output, writes
   it into a generated `inventory.ini`, waits for SSH to come up, then runs
   `ansible-playbook playbook.yml --tags configure`, which:
   - installs Docker CE and enables the `docker` systemd unit so the daemon
     survives reboots without manual intervention;
   - installs nginx, removes the default site, templates
     `app-proxy.conf.j2` to `/etc/nginx/sites-available/app-proxy.conf`,
     symlinks it into `sites-enabled`, and enables the `nginx` systemd unit
     so it also survives reboots;
   - reloads nginx (via a handler) whenever the site config changes.
3. Ansible's idempotency means re-running the playbook against an
   already-configured host performs no destructive changes — only drifted
   tasks report as "changed".
4. Nothing in this playbook pulls an image or starts an application
   container. Once a container is deployed to the host on port 5000 (by
   whatever process handles that, outside this playbook's scope), nginx is
   already listening on port 80 and will proxy straight through to it —
   no further nginx changes are needed.

## Running it locally

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml --tags configure
```

## Dynamic inventory (alternative)

Instead of the static `inventory.ini`, the `google.cloud.gcp_compute` inventory
plugin can query the GCP API directly using instance labels so no IP address
ever needs to be hand-copied. This was not used here to keep the assignment
reviewable without extra Ansible collections, but it is the recommended
approach for anything beyond a single-VM setup.
