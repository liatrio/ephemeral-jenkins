remote_state {
  backend = "local"
  config = { 
    path = "terraform.tfstate" 
  }
  generate = {
    path      = "backend.tf"
    if_exists = "skip"
  }
}
