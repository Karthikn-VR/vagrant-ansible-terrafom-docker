---

## 🚀 Value Added Course – DevOps Lab

This project sets up a complete **DevOps lab environment** for students using **Vagrant, Docker, Terraform, Ansible, Flask, and GitHub Actions**.

The goal is to give students a **hands-on CI/CD experience** where pushing code automatically deploys an application inside a provisioned VM.

<img width="250" height="248" alt="image" src="https://github.com/user-attachments/assets/3baf3430-3c00-4d00-a66d-fe9c3c39b92c" /> <img width="250" height="173" alt="image" src="https://github.com/user-attachments/assets/020dfe67-b2c0-44e1-ba67-a9441a8c0a14" /> <img width="130" height="320" alt="image" src="https://github.com/user-attachments/assets/d978445f-3636-4a41-9db4-9429a8e01d79" /> <img width="140" height="166" alt="image" src="https://github.com/user-attachments/assets/da2269db-6b3c-415c-8eb2-17d3d6b257a6" /> <img width="200" height="226" alt="image" src="https://github.com/user-attachments/assets/b9a0605e-497f-4691-bed9-757fdc3dea50" />

---

## 🔹 What’s Inside

* **Vagrant VM** → provisioned with **Docker, Terraform, and Ansible**.
* **Flask App** → `k8s-quiz/` (simple quiz web app).
* **Terraform** → `terraform-docker/` (builds Docker image & runs container).
* **GitHub Actions** → `.github/workflows/deploy.yml` (pipeline triggered on push).
* **Self-hosted Runner** → runs inside the VM, listens for GitHub Actions jobs.
* ✅ **App comes online automatically after every commit** on port **5000**.

---

## 🔹 How to use It

1. **Fork the repository**

   Login to github first. If you dont have the account, create the one by clicking on Sign up Button.

   <img width="1835" height="719" alt="image" src="https://github.com/user-attachments/assets/0f1db4ce-3a4f-49a3-a2b6-b4d7fc267995" />

    
   Fork this repo:
   👉 [https://github.com/deenamanick/vagrant-ansible-terrafom-docker.git](https://github.com/deenamanick/vagrant-ansible-terrafom-docker.git)

3. **Clone your fork**

   ```bash
   git clone https://github.com/<your-username>/vagrant-ansible-terrafom-docker.git
   
   ```
   ```bash
   cd vagrant-ansible-terrafom-docker
   
   ```
   

4. **Start the VM with Ansible Setup**

   ```bash
   vagrant provision --provision-with ansible
   ```

   * VM provisions with Docker, Terraform, and Ansible.

5. **login to the VM**

   ```bash
   vagrant ssh
---

<img width="557" height="361" alt="image" src="https://github.com/user-attachments/assets/9147fd00-8e29-44ee-a04c-26381b73fbec" />


## 🔹 **Practice Ansible**

1. **Switch to ansible directory & Check ansible version**

  ```bash
   cd ansible
  ```
  ```bash
  ansible --version
  ```

  ```bash
  ansible all -m ping

  ```

   You should see similar output.
  
   <img width="1150" height="245" alt="image" src="https://github.com/user-attachments/assets/5f958dce-977d-477f-9aab-78ac2cd9be49" />

2. **Let's practice some ansible commands**

    ```bash
    ls
    ```
    <img width="979" height="99" alt="image" src="https://github.com/user-attachments/assets/d1121b81-9a39-4cc5-b9f5-567a97b4b1f6" />

   This make sure your github repo is copied the necessary files in /home/vagrant home directory.

6. **Install nginx**

     ```bash
    ansible-playbook install_nginx.yml
    ```
    To check the website
     
     ```
     curl http://172.20.0.11
     ```
     

7. **copy index.html file**
   
   ```bash
   ansible-playbook copy_index.yml
   ```

8. **Stop nginx**
   
   ```bash
   ansible-playbook stop_nginx.yml
   ```
---

9. **Health Check nginx**
   
   ```bash
   ansible-playbook healthcheck.yml 
   ```
---

10. **Shutdown vagrant**

    ```bash
    exit

    ```

11. **Shutdown**

    ```bash
      vagrant halt
    ```
    

## 🔹 **Practice Terraform**

**Bring Up Vagrant**

```bash
vagrant up --provision-with terraform

```

```bash
vagrant ssh

```

1. **Switch to Terraform directory and check terraform version**
   
  ```bash
   cd /home/vagrant/terraform-docker/
  ```
  ```bash
   terraform version
  ```
   
   <img width="884" height="220" alt="image" src="https://github.com/user-attachments/assets/33d8b378-935c-4949-bf47-70d0dc40f0f8" />

2. **List terraform directory**

    ```bash
    ls
    ```
    <img width="931" height="75" alt="image" src="https://github.com/user-attachments/assets/4daef2d5-22e5-48db-987e-5c857c4fcb85" />

3. **Initialization in Terraform**

    ```bash
    terraform init
    ```
   <img width="1042" height="472" alt="image" src="https://github.com/user-attachments/assets/e0bad5cc-0f52-4013-9a81-1d915a50efb2" />
   
4. **Terraform Plan**

    ```bash
    terraform plan
    ```
    <img width="1308" height="686" alt="image" src="https://github.com/user-attachments/assets/f6d42e4b-811e-4223-af70-97b30642b3f6" />
    <img width="1320" height="741" alt="image" src="https://github.com/user-attachments/assets/40faf425-cc6d-4a81-b92f-e734702780d0" />

5. **Terraform apply**

    ```bash
    terraform apply --auto-approve
    ```
    <img width="1395" height="370" alt="image" src="https://github.com/user-attachments/assets/c3797dcd-9174-454d-b9a5-30f2568802e2" />

6. **Terraform destroy**

    ```bash
    terraform destroy --auto-approve
    ```
   <img width="1273" height="280" alt="image" src="https://github.com/user-attachments/assets/c895a070-9d11-4634-bc83-8b8e112e93dc" />


---
### **Additional Terraform Tasks**


## 🟢 Simple Terraform Tasks

### 1. **Hello World with Terraform**

* Create a file `main.tf`.
* Define a provider (like Docker).
* Just run `terraform init` + `terraform plan`.
  👉 Goal: Get used to Terraform commands.

---

### 2. **Create a Local File**

```hcl
resource "local_file" "example" {
  content  = "Hello from Terraform!"
  filename = "hello.txt"
}
```

👉 Task: Run `terraform apply` → check that `hello.txt` is created.

---

### 3. **Deploy a Docker Nginx Container**

```hcl
provider "docker" {}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "nginx-server"
  ports {
    internal = 80
    external = 8080
  }
}
```

👉 Task: Run `terraform apply`, then open `http://localhost:8080`.

---

### 4. **Create Two Docker Containers**

* Use Nginx (port 8081) and Redis (port 6379).
* Just like the **multi-container setup** we discussed earlier, but simpler.

👉 Task: Verify with `docker ps`.

---

### 5. **Variable Usage**

```hcl
variable "instance_name" {
  default = "my-container"
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = var.instance_name
  ports {
    internal = 80
    external = 8082
  }
}
```

👉 Task: Change the variable value → reapply → container should have new name.

---

### 6. **Destroy & Reapply**

* Run `terraform destroy` to remove resources.
* Run `terraform apply` again to recreate.
  👉 Task: Learn how IaC makes infra reproducible.

---

### **Challenge Tasks**


### 1. **Deploy Two Nginx Containers on Different Ports**

* Use Terraform to run **two Nginx containers**.
* Map them to ports `8081` and `8082`.
  👉 Challenge: Check both in the browser.

---

### 2. **Use a Variable for Container Name**

* Create a variable called `container_name`.
* Use it in your container resource.
  👉 Challenge: Change the variable and see Terraform rename the container.

---

### 3. **Create a Simple Local File**

```hcl
resource "local_file" "note" {
  content  = "Terraform is fun!"
  filename = "note.txt"
}
```

👉 Challenge: Run `terraform apply`, then `terraform destroy` to see how IaC manages files.

---

### 4. **Count Challenge – Multiple Containers**

* Use `count = 3` in your resource block.
* Spin up **3 Nginx containers**.
  👉 Challenge: Name them `nginx-1`, `nginx-2`, `nginx-3`.

---

### 5. **Custom HTML in Nginx**

* Create a local `index.html` file.
* Mount it into the Nginx container using Terraform volume mapping.
  👉 Challenge: Show a custom welcome page in the browser.

---

### 6. **Output Challenge**

* Add an `output.tf` file.
* Print the container’s **name** and **port** after `terraform apply`.
  👉 Challenge: Verify outputs appear on screen.

---

### 7. **Destroy & Recreate**

* Deploy a container.
* Run `terraform destroy`.
* Run `terraform apply` again.
  👉 Challenge: Notice how Terraform recreates the same resource automatically.



---


## 🔹 **Lets practice github Actions / CICD**


### 🔹 1. Check if a remote exists

```bash
git remote -v
```

* If you see `origin  https://github.com/...` → you’re good.
* If **nothing shows**, add it:

```bash
git remote add origin https://github.com/username/repo.git
```

---

### 🔹 2. Set your identity (global)

```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```


---

### 🔹 3. Cache credentials (HTTPS only)

So you don’t type your token each time:

```bash
git config --global credential.helper cache
```


---



## 🔹 **Lets practice github Actions / CICD**

1. **Create token**
   Click on the top right corner and click setting 

   <img width="1860" height="390" alt="image" src="https://github.com/user-attachments/assets/ebba8127-aba4-48eb-9c73-3f78c48ffc87" />

   <img width="1777" height="803" alt="image" src="https://github.com/user-attachments/assets/4c62a84e-939e-4257-9ee5-29aa48ec5521" />

   click on Developer menu

   <img width="1369" height="727" alt="image" src="https://github.com/user-attachments/assets/3dc84b2d-e262-464e-b9d6-5cb346c1a083" />

   <img width="1217" height="683" alt="image" src="https://github.com/user-attachments/assets/f15b55c5-e556-49b5-8065-acc731d8abd3" />

   
  Click on **Generate new token**

   <img width="1171" height="696" alt="image" src="https://github.com/user-attachments/assets/3c131d94-2579-4012-84de-b33bdf2aa34b" />

  Type Token in the Note Text box, select *repo* and *workflow*
  
   <img width="1196" height="690" alt="image" src="https://github.com/user-attachments/assets/17af1a44-7184-4dea-8049-f738112b305c" />

  Scroll down and Click on **Generate Token**
   
   <img width="1221" height="582" alt="image" src="https://github.com/user-attachments/assets/4519fd93-51dc-4575-8953-823fc75f1588" />

  Now you got the Github Personal Access Token, copy this token and keep it in notepad.

  <img width="1177" height="603" alt="image" src="https://github.com/user-attachments/assets/65731a08-93ea-48fd-9765-fa199082c179" />

 Go to Gitbash and paste the token after typing **export GITHUB_PAT**

2. **Export GITHUB Token**

     <img width="947" height="99" alt="image" src="https://github.com/user-attachments/assets/0f849cba-77f4-499e-a534-21c107da2f5a" />

   Paste the github token here

  ```bash

  export GITHUB_PAT=
    
  ```
  Paste your repo url here

  ```bash
   export GITHUB_REPO=

  ```

3. **Run Ansible playbook to setup local runner**

    ```bash
    cd /home/vagrant/ansible/
    ```
    ```bash
    ansible-playbook install_github_runner.yml -l runner
    ```

   **Exit from vagrant**
  ```bash
   exit

  ```

4. **Commit & push**

     ```bash
     git add .
     git commit -m "Update quiz app"
     git push origin main
     ```

5. **GitHub Actions runs automatically**

   * Workflow builds Docker image.
   * Terraform deploys container inside VM.
   * App is available at:
     👉 [quiz_app_url = "http://192.168.56.10:8080" ]








---
## 🔹 **Troubleshooting Steps**


### Why?

* When you ran into this earlier:

  ```
  Error: container name "/quiz_app" is already in use
  ```

  Terraform failed to create a new container because an **old container** was already running.
* At that point, Terraform state and Docker diverged:

  * Terraform **lost track of the container** (wasn’t written to state, or was removed manually from `.tfstate`).
  * But Docker still has the container (`docker ps -a` will show it).

So when you run `terraform destroy`, it only destroys what’s in the state (`docker_image`) — not the “orphaned” container.

---

### ✅ How to fix

1. **Check if the container still exists**

   ```bash
   docker ps -a | grep quiz_app
   ```

2. **Remove it manually**

   ```bash
   docker rm -f quiz_app
   ```

3. **(Optional) Sync Terraform state with reality**
   If Terraform state has gotten dirty, you can clean it:

   ```bash
   terraform state list              # see tracked resources
   terraform state rm docker_container.quiz_app
   terraform state rm docker_image.quiz_app
   ```

4. **Re-run**

   ```bash
   terraform apply   # will recreate properly
   terraform destroy # will now clean up both image & container
   ```


## 🔹 Run the GitHub Runner from local registry (offline-friendly)

If your internet is unreliable, you can use a prebuilt Docker image of the GitHub Actions Runner from a local Docker registry. This avoids downloading the runner during setup.

### 1) Build and publish the runner image (instructor)

Files:

- `runner-image/Dockerfile`
- `runner-image/entrypoint.sh`

Build and push to Docker Hub:

```bash
cd runner-image
docker build -t <DOCKERHUB_USER>/gha-runner:2.328.0 .
docker push <DOCKERHUB_USER>/gha-runner:2.328.0
```

Optional: host in a local registry for your lab server:

```bash
docker run -d --restart=always -p 5000:5000 --name registry registry:2
docker pull <DOCKERHUB_USER>/gha-runner:2.328.0
docker tag <DOCKERHUB_USER>/gha-runner:2.328.0 localhost:5000/gha-runner-new:2.328.0
docker push localhost:5000/gha-runner:2.328.0
```

If clients use an insecure local registry, configure `/etc/docker/daemon.json` on each client:

```json
# on student machine (one-time)
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json >/dev/null <<'JSON'
{
  "insecure-registries": ["192.168.3.134:5000"],
  "registry-mirrors": ["192.168.3.134:5000"]
}
JSON
sudo systemctl daemon-reload
sudo systemctl restart docker

```
# Print the best-guess LAB Ip

```bash
ip route get 8.8.8.8 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}' \
  || hostname -I | awk '{print $1}'

```

### 2) Provision the containerized runner (students)

Export the required environment variables on the controller (the machine running Ansible):

```bash
export GITHUB_REPO="<your-username>/<your-repo>"
# One of the two below must be provided
export GITHUB_PAT="<token with repo+workflow scopes>"   # or
export RUNNER_TOKEN="<repo runner token>"
```

Run the Ansible playbook:

```bash
cd ansible
ansible-playbook install_github_runner_container.yml --extra-vars 'runner_labels=self-hosted,lab,mytag runner_workdir=/runner/_work' -e "image_ref=deenamanick/gha-runner-new:2.328.0"
```

By default the playbook pulls `localhost:5000/gha-runner:2.328.0`. Change `image_ref` in `ansible/install_github_runner_container.yml` to use your Docker Hub image if you prefer.

### 3) Verify

Check that the container is running on the target VM and appears as a self-hosted runner in your GitHub repo settings.

```bash
docker ps -a | grep gha-runner

docker logs -a gha-runner
```

### Notes

- The container’s entrypoint registers the runner on start and unregisters it on stop.
- If your workflows need Docker access, the playbook mounts `/var/run/docker.sock` into the container.




