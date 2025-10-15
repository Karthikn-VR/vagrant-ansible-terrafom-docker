# # #!/usr/bin/env bash
# # set -euo pipefail
# # export DEBIAN_FRONTEND=noninteractive

# # # --- Speed up apt globally ---
# # sudo tee /etc/apt/apt.conf.d/99-speed >/dev/null <<'EOF'
# # Acquire::Retries "5";
# # Acquire::http::Timeout "30";
# # Acquire::https::Timeout "30";
# # Acquire::ForceIPv4 "true";
# # Acquire::Languages "none";
# # APT::Install-Recommends "false";
# # Dpkg::Use-Pty "0";
# # Acquire::Queue-Mode "host";
# # EOF

# # # --- Use India mirror (IIT Kanpur) ---
# # sudo sed -i 's|http://us.archive.ubuntu.com/ubuntu|http://mirror.cse.iitk.ac.in/ubuntu|g' /etc/apt/sources.list || true
# # sudo apt-get clean

# # # --- Base tools (no update yet) ---
# # sudo apt-get install -y curl gnupg lsb-release ca-certificates software-properties-common || true

# # # --- Add official Docker repo ---
# # sudo mkdir -p /usr/share/keyrings
# # curl -fsSL --retry 5 --retry-delay 3 https://download.docker.com/linux/ubuntu/gpg \
# #   | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# # echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
# # https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
# # | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# # # --- Single apt-get update (after all repos are ready) ---
# # sudo apt-get update -y

# # # --- Install only Docker Engine (skip compose plugins) ---
# # if timeout 180s sudo apt-get -o Acquire::Retries=5 -o Acquire::ForceIPv4=true \
# #     install -y docker-ce docker-ce-cli containerd.io; then
# #   DOCKER_SRC="docker.com"
# # else
# #   echo ">> Official Docker repo too slow, falling back to Ubuntu docker.io"
# #   sudo apt-get -f install -y || true
# #   sudo rm -f /etc/apt/sources.list.d/docker.list
# #   sudo apt-get update -y
# #   sudo apt-get install -y docker.io containerd runc
# #   DOCKER_SRC="ubuntu-mirror"
# # fi
# # set -e

# # # --- Enable & start ---
# # sudo systemctl enable --now docker

# # # --- Verify ---
# # docker --version || true
# # echo ">> Docker installed via: ${DOCKER_SRC}"
# # sudo usermod -aG docker vagrant



# # chown -R vagrant:vagrant /home/vagrant/terraform-docker

# # # # SSH key for Ansible
# # sudo -u vagrant ssh-keygen -t rsa -b 2048 -N "" -f /home/vagrant/.ssh/id_rsa || true


# # # # Setup Docker workers
# # # docker network create --subnet=172.20.0.0/24 ansible-net || true
# # # docker pull ubuntu:22.04

# # # pubkey=$(cat /home/vagrant/.ssh/id_rsa.pub)

# # # for i in 1 2; do
# # #   cname="worker$i"
# # #   cip="172.20.0.1$i"

# # #   docker rm -f $cname || true
# # #   docker volume create worker_ssh

# # #   docker run -d --name $cname --hostname $cname \
# # #   --net ansible-net --ip $cip \
# # #   --privileged --restart=always \
# # #   -v worker_ssh:/root/.ssh \
# # #   ubuntu:22.04 sleep infinity

# # #   docker exec $cname apt-get update
# # #   docker exec $cname apt-get install -y openssh-server python3 sudo

# # #   docker exec $cname mkdir -p /var/run/sshd /root/.ssh
# # #   docker exec $cname bash -c "echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config"

# # #   # Add the VM's pubkey into root's authorized_keys safely
# # #  # echo "$pubkey" | docker exec -i $cname tee /root/.ssh/authorized_keys > /dev/null
# # #   echo "$pubkey"| docker exec -i $cname bash -c 'tee /root/.ssh/authorized_keys' > /dev/null

# # #   # Fix SSH perms
# # #   docker exec $cname chmod 700 /root/.ssh
# # #   docker exec $cname chmod 600 /root/.ssh/authorized_keys

# # #   # Restart ssh service
# # #   docker exec $cname service ssh restart
# # # done

# # # Network (ignore error if exists)


# # ## Testing the docker network
# # docker network create --subnet=172.20.0.0/24 ansible-net || true

# # pubkey=$(cat /home/vagrant/.ssh/id_rsa.pub)

# # for i in 1 2; do
# #   cname="worker$i"
# #   cip="172.20.0.1$i"

# #   docker rm -f "$cname" || true
# #   # separate ssh volume per worker (so authorized_keys are independent if you want)
# #   docker volume create "worker_${i}_ssh" >/dev/null

# #   docker run -d --name "$cname" --hostname "$cname" \
# #     --net ansible-net --ip "$cip" \
# #     --privileged --restart=always \
# #     -v "worker_${i}_ssh:/root/.ssh" \
# #     deenamanick/ansible-ssh:22.04

# #   # inject your public key
# #  # echo "$pubkey" | docker exec -i "$cname" bash -lc 'cat > /root/.ssh/authorized_keys && chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys'
 
# #    # Add the VM's pubkey into root's authorized_keys safely
# #   echo "$pubkey"| docker exec -i $cname bash -c 'tee /root/.ssh/authorized_keys' > /dev/null

# #   # Fix SSH perms
# #   docker exec $cname chmod 700 /root/.ssh
# #   docker exec $cname chmod 600 /root/.ssh/authorized_keys

# #   # Restart ssh service
# #   docker exec $cname service ssh restart
 
# # done



------------
#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# --- APT speedups + parallel downloads ---
sudo tee /etc/apt/apt.conf.d/99-speed >/dev/null <<'EOF'
Acquire::Retries "5";
Acquire::http::Timeout "30";
Acquire::https::Timeout "30";
Acquire::ForceIPv4 "true";
Acquire::Languages "none";
APT::Install-Recommends "false";
Dpkg::Use-Pty "0";
Acquire::Queue-Mode "access";
APT::Fetcher::MaxParallelDownloads "8";
Acquire::PDiffs "false";
EOF

# --- Use Ubuntu's mirror auto-selector ---
sudo tee /etc/apt/sources.list >/dev/null <<'EOF'
deb mirror://mirrors.ubuntu.com/mirrors.txt jammy main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt jammy-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt jammy-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
EOF

sudo apt-get clean

# --- Base tools (avoid multiple updates) ---
sudo apt-get update -y
sudo apt-get install -y curl gnupg lsb-release ca-certificates software-properties-common

# --- Add official Docker repo ---
sudo mkdir -p /usr/share/keyrings
curl -fsSL --retry 5 --retry-delay 3 https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update -y

# --- Install Docker with smart fallbacks ---
if timeout 180s sudo apt-get -o Acquire::Retries=5 -o Acquire::ForceIPv4=true \
    install -y docker-ce docker-ce-cli containerd.io; then
  DOCKER_SRC="docker-ce (docker.com)"
else
  echo ">> docker-ce slow; trying get.docker.com convenience script"
  if curl -fsSL https://get.docker.com | sudo sh; then
    DOCKER_SRC="get.docker.com"
  else
    echo ">> Falling back to Ubuntu docker.io (last resort)"
    sudo rm -f /etc/apt/sources.list.d/docker.list
    sudo apt-get update -y
    sudo apt-get install -y docker.io containerd runc
    DOCKER_SRC="ubuntu docker.io"
  fi
fi

# sudo systemctl enable --now docker
# docker --version || true
# echo ">> Docker installed via: ${DOCKER_SRC}"
# sudo usermod -aG docker vagrant

# # Optional: load pre-saved image if present (skips docker pull)
# if [[ -f /home/vagrant/ansible-ssh-22.04.tar ]]; then
#   sudo docker load -i /home/vagrant/ansible-ssh-22.04.tar || true
# fi

# # Permissions for your repo path (if needed)
# chown -R vagrant:vagrant /home/vagrant/terraform-docker

# # SSH key for Ansible
# sudo -u vagrant ssh-keygen -t rsa -b 2048 -N "" -f /home/vagrant/.ssh/id_rsa || true

# # --- Network + Workers using your prebuilt image ---
# docker network create --subnet=172.20.0.0/24 ansible-net || true
# pubkey=$(cat /home/vagrant/.ssh/id_rsa.pub)

# for i in 1 2; do
#   cname="worker$i"
#   cip="172.20.0.1$i"

#   docker rm -f "$cname" || true
#   docker volume create "worker_${i}_ssh" >/dev/null

#   docker run -d --name "$cname" --hostname "$cname" \
#     --net ansible-net --ip "$cip" \
#     --privileged --restart=always \
#     -v "worker_${i}_ssh:/root/.ssh" \
#     deenamanick/ansible-ssh:22.04

#   echo "$pubkey" | docker exec -i "$cname" bash -lc 'cat > /root/.ssh/authorized_keys && chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys'
#   docker exec "$cname" service ssh restart
# done

# --- Docker on host VM ---
sudo systemctl enable --now docker
docker --version || true
echo ">> Docker installed via: ${DOCKER_SRC:-unknown}"
sudo usermod -aG docker vagrant

# Optional: load pre-saved image if present (skips docker pull)
if [[ -f /home/vagrant/ansible-ssh-22.04.tar ]]; then
  sudo docker load -i /home/vagrant/ansible-ssh-22.04.tar || true
fi

# Permissions for your repo path (if needed)
sudo chown -R vagrant:vagrant /home/vagrant/terraform-docker || true

# SSH key for Ansible (host VM -> containers)
sudo -u vagrant ssh-keygen -t rsa -b 2048 -N "" -f /home/vagrant/.ssh/id_rsa || true
pubkey=$(cat /home/vagrant/.ssh/id_rsa.pub)

# --- Network + Workers using your prebuilt image ---
docker network create --subnet=172.20.0.0/24 ansible-net || true

for i in 1 2; do
  cname="worker$i"
  cip="172.20.0.1$i"

  # Recreate container
  docker rm -f "$cname" 2>/dev/null || true
  docker volume create "worker_${i}_ssh" >/dev/null

  docker run -d --name "$cname" --hostname "$cname" \
    --net ansible-net --ip "$cip" \
    --privileged --restart=always \
    -v "worker_${i}_ssh:/root/.ssh" \
    deenamanick/ansible-ssh:22.04

  # Inject authorized_keys without restarting host sshd
  echo "$pubkey" | docker exec -i "$cname" bash -lc '
    umask 077
    mkdir -p /root/.ssh
    cat > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
  '

  # Ensure sshd INSIDE the container is running (start but don't restart host)
  docker exec "$cname" bash -lc '
    if command -v systemctl >/dev/null 2>&1; then
      systemctl enable --now ssh || systemctl enable --now sshd || true
    else
      service ssh start || service sshd start || /etc/init.d/ssh start || true
    fi
  '
done

# ---- WAIT for all container SSH ports to be ready before proceeding ----
for i in 1 2; do
  cname="worker$i"
  echo "Waiting for SSH in $cname..."
  # Use bash TCP check; avoids needing nc/ss tools in the container
  until docker exec "$cname" bash -lc 'timeout 1 bash -c "</dev/tcp/127.0.0.1/22" 2>/dev/null'; do
    sleep 1
  done
  echo "$cname: SSH is ready."
done

# IMPORTANT: Do NOT restart ssh on the Vagrant VM here (that kills provisioning)
# If you must apply sshd config changes on the host, do a reload at the VERY END:
# (sleep 2; sudo systemctl reload ssh || sudo systemctl reload sshd || true) & disown
