terraform {
  backend "s3" {
    bucket = "shloka-terraform-backend1234"
    key    = "terraform-state.tfstate"
    region = "ap-south-1"
  }
}
