#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Speedy mirrors & apt tuning
sudo sed -i 's|http://us.archive.ubuntu.com/ubuntu|http://mirror.cse.iitk.ac.in/ubuntu|g' /etc/apt/sources.list || true
sudo tee /etc/apt/apt.conf.d/99-speed >/dev/null <<'EOF'
Acquire::Retries "5";
Acquire::http::Timeout "30";
Acquire::https::Timeout "30";
Acquire::ForceIPv4 "true";
Acquire::Languages "none";
APT::Install-Recommends "false";
Dpkg::Use-Pty "0";
Acquire::Queue-Mode "host";
EOF
sudo apt-get clean
sudo apt-get update -y

# Fastest: no PPA
sudo apt-get install -y ansible-core

# Optional SSH key, inventory, etc… (your existing content)

# # SSH key for Ansible ## added in docker
#sudo -u vagrant ssh-keygen -t rsa -b 2048 -N "" -f /home/vagrant/.ssh/id_rsa || true

# Create sample inventory and config
mkdir -p /home/vagrant/ansible

cat <<EOF | sudo tee /home/vagrant/ansible/inventory.ini
[runner]
localhost ansible_connection=local

[workers]
worker1 ansible_host=172.20.0.11 ansible_user=root
worker2 ansible_host=172.20.0.12 ansible_user=root

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

cat <<EOF | sudo tee /home/vagrant/ansible/ansible.cfg
[defaults]
inventory = ./inventory.ini
remote_user = root
host_key_checking = False
deprecation_warnings = False
interpreter_python = auto_silent

[privilege_escalation]
become = false

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

EOF

# Fix permissions
sudo chown -R vagrant:vagrant /home/vagrant/ansible

# If a containerized runner playbook exists in repo, copy it into place for students
if [ -f /vagrant/ansible/install_github_runner_container.yml ]; then
  cp -f /vagrant/ansible/install_github_runner_container.yml /home/vagrant/ansible/
  chown vagrant:vagrant /home/vagrant/ansible/install_github_runner_container.yml
fi

# Task 1 - Install Apache
cat <<EOF > /home/vagrant/ansible/install_nginx.yml
---
- name: Install nginx on workers
  hosts: workers
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
    - name: Install nginx
      apt:
        name: nginx
        state: present
    - name: Ensure nginx is running
      service:
        name: nginx
        state: started
        enabled: yes
EOF

# Task 2 - Create user
cat <<EOF >  /home/vagrant/ansible/user_add.yml
---
- name: Create DevOps user
  hosts: workers
  become: yes
  tasks:
    - name: Ensure user 'devops' exists
      user:
        name: devops
        shell: /bin/bash
        groups: sudo
        state: present
EOF

# Task 3 - Copy index.html
cat <<EOF >  /home/vagrant/ansible/copy_index.yml
---
- name: Deploy simple index.html and restart nginx
  hosts: workers
  become: yes
  tasks:
    - name: Place index.html
      copy:
        dest: /var/www/html/index.html
        content: |
          <h1>Welcome to Jeevi Academy</h1>
          <p>Deployed on {{ inventory_hostname }}</p>

    - name: Restart nginx
      service:
        name: nginx
        state: restarted
EOF

# Task 4 - Stop Apache
cat <<EOF >  /home/vagrant/ansible/stop_nginx.yml
---
- name: Stop nginx on workers
  hosts: workers
  become: yes
  tasks:
    - name: Stop nignx
      service:
        name: nginx
        state: stopped
EOF


# Playbook 5 - Health check
cat <<'EOF' > /home/vagrant/ansible/healthcheck.yml
---
- name: Check NGINX homepage
  hosts: workers
  become: yes
  tasks:
    - name: Request homepage
      uri:
        url: http://127.0.0.1/
        return_content: yes
      register: homepage
      changed_when: false

    - name: Show HTTP status
      debug:
        msg: "Status code from {{ inventory_hostname }} is {{ homepage.status }}"

    - name: Ensure status is 200 OK
      assert:
        that:
          - homepage.status == 200
        fail_msg: "Homepage is not reachable on {{ inventory_hostname }}"
        success_msg: "Homepage is up and returning 200 on {{ inventory_hostname }}"
EOF


# Task 5 - Install GitHub Runner (cached download + retries + verification)
cat <<'EOF' >  /home/vagrant/ansible/install_github_runner.yml
---
- name: Install GitHub Actions Runner
  hosts: all
  become: yes

  vars:
    # github_repo: "deenamanick/vagrant-ansible-terrafom-docker"
    github_repo: "{{ lookup('env','GITHUB_REPO') }}"
    runner_version: "2.328.0"
    runner_dir: "/opt/actions-runner"
    github_pat: "{{ lookup('env','GITHUB_PAT') }}"
    cache_dir: "/home/vagrant/ansible/cache"   # cache on controller

  pre_tasks:
    - name: Ensure cache dir exists on controller
      delegate_to: localhost
      file:
        path: "{{ cache_dir }}"
        state: directory
        mode: '0755'

    - name: Download runner once to controller cache (with retries)
      delegate_to: localhost
      get_url:
        url: "https://github.com/actions/runner/releases/download/v{{ runner_version }}/actions-runner-linux-x64-{{ runner_version }}.tar.gz"
        dest: "{{ cache_dir }}/actions-runner-linux-x64-{{ runner_version }}.tar.gz"
        mode: '0644'
        timeout: 600
      register: download_result
      retries: 5
      delay: 20
      until: download_result is succeeded

  tasks:
    - name: Install dependencies
      apt:
        name: [ "curl", "tar", "jq", "ca-certificates" ]
        state: present
        update_cache: yes

    - name: Create runner directory on target
      file:
        path: "{{ runner_dir }}"
        state: directory
        owner: vagrant
        group: vagrant
        mode: '0755'

    - name: Copy cached runner tarball to target
      copy:
        src: "{{ cache_dir }}/actions-runner-linux-x64-{{ runner_version }}.tar.gz"
        dest: "{{ runner_dir }}/runner.tar.gz"
        mode: '0644'

    - name: Extract GitHub runner
      unarchive:
        src: "{{ runner_dir }}/runner.tar.gz"
        dest: "{{ runner_dir }}"
        remote_src: yes
        creates: "{{ runner_dir }}/config.sh"

    - name: Ensure runner directory owned by vagrant
      file:
        path: "{{ runner_dir }}"
        state: directory
        recurse: yes
        owner: vagrant
        group: vagrant

    - name: Request registration token from GitHub API (with retries)
      uri:
        url: "https://api.github.com/repos/{{ github_repo }}/actions/runners/registration-token"
        method: POST
        headers:
          Authorization: "token {{ github_pat }}"
          Accept: "application/vnd.github.v3+json"
        status_code: 201
        timeout: 60
      register: reg_token
      retries: 5
      delay: 10
      until: reg_token.status == 201

    - name: Configure GitHub runner
      command: >
        ./config.sh --url https://github.com/{{ github_repo }}
        --token {{ reg_token.json.token }} --unattended
      args:
        chdir: "{{ runner_dir }}"
      become_user: vagrant

    - name: Install runner as service
      command: ./svc.sh install
      args:
        chdir: "{{ runner_dir }}"

    - name: Start runner service
      command: ./svc.sh start
      args:
        chdir: "{{ runner_dir }}"

    - name: Verify runner config exists
      stat:
        path: "{{ runner_dir }}/.runner"
      register: runner_cfg

    - name: Fail if runner is not configured
      fail:
        msg: "Runner configuration not found at {{ runner_dir }}/.runner"
      when: not runner_cfg.stat.exists

    - name: Check runner service status
      command: ./svc.sh status
      args:
        chdir: "{{ runner_dir }}"
      register: runner_status
      changed_when: false

    - name: Show runner status
      debug:
        var: runner_status.stdout

    - name: Ensure runner service is running
      assert:
        that:
          - "'is running' in runner_status.stdout"
        fail_msg: "GitHub Actions runner service is not running"
        success_msg: "GitHub Actions runner service is running"
EOF

# Task 6 - Install GitHub Runner in container.yml
## How to run -- ansible-playbook install_github_runner_container.yml --extra-vars 'runner_labels=self-hosted,lab,mytag runner_workdir=/runner/_work' -e "image_ref=192.168.1.15:5000/gha-runner-new:2.328.0"

## Post check - docker logs -f gha-runner

## MAKE SURE HAVE ENV 

# ## vagrant@devops-lab:~/terraform-docker$ env | egrep  'RUNNER|GITHUB_PAT|REPO' 
# RUNNER_TOKEN=
# GITHUB_REPO=
# GITHUB_PAT=

cat <<'EOF' >  /home/vagrant/ansible/install_github_runner_container.yml
---
- name: Install containerized GitHub Actions Runner
  hosts: runner
  become: yes

  vars:
    image_ref: "192.168.1.15:5000/gha-runner-new:2.328.0"   # updated to your pushed image
    container_name: "gha-runner"
    runner_labels: "self-hosted,lab"
    runner_workdir: "/runner/_work"

  tasks:
    - name: Ensure Docker is installed
      command: docker --version
      register: docker_ver
      changed_when: false
      failed_when: docker_ver.rc != 0

    - name: Pull runner image
      command: docker pull {{ image_ref }}
      register: pull_out
      changed_when: "'Downloaded newer image' in pull_out.stdout"

    - name: Stop and remove existing container
      shell: |
        docker rm -f {{ container_name }} 2>/dev/null || true
      changed_when: false

    - name: Run GitHub Actions runner container
      shell: |
        docker run -d --name {{ container_name }} --restart=always \
          -e GITHUB_REPO="{{ lookup('env','GITHUB_REPO') }}" \
          -e GITHUB_PAT="{{ lookup('env','GITHUB_PAT') | default('', true) }}" \
          -e RUNNER_TOKEN="{{ lookup('env','RUNNER_TOKEN') | default('', true) }}" \
          -e RUNNER_ALLOW_RUNASROOT=1 \
          -e TF_PLUGIN_CACHE_DIR="/tfplugin-cache" \
          -e RUNNER_TOOL_CACHE="/runner/_toolcache" \
          -e RUNNER_LABELS="{{ runner_labels }}" \
          -e RUNNER_WORKDIR="{{ runner_workdir }}" \
          -v /opt/tfplugin-cache:/tfplugin-cache \
          -v /opt/gha-toolcache:/runner/_toolcache \
          -v /var/run/docker.sock:/var/run/docker.sock \
          {{ image_ref }}
      args:
        executable: /bin/bash

    - name: Wait for container to become healthy-ish
      shell: |
        sleep 5
        docker logs --tail 50 {{ container_name }} | tail -n +1
      register: logs
      changed_when: false

    - name: Show runner container logs (last 50 lines)
      debug:
        var: logs.stdout

EOF

sudo chown -R vagrant:vagrant /home/vagrant/ansible
