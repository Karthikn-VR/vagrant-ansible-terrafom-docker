variable "vm_ip" {
  type        = string
  description = "Vagrant VM private_network IP"
  default     = "192.168.56.10"
}

variable "app_port" {
  type        = number
  description = "App port inside the VM (guest port)"
  default     = 8080
}

# Docker image to pull and run for the IaC Quiz app
variable "image" {
  type        = string
  description = "Fully qualified Docker image (e.g., myuser/iac-quiz:latest)"
  default     = "deenamanick/iac-quiz:v1"
}

# Host port to expose the app on (maps to container port 8080)
variable "external_port" {
  type        = number
  description = "Host port to map to container's 8080"
  default     = 8080
}
