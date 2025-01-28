module "primary" {
  source   = "./modules/region-stamp"
  location = var.primary
  name     = var.name
  suffix   = "primary"
}

module "alternate" {
  source   = "./modules/region-stamp"
  location = var.alternate
  name     = var.name
  suffix   = "alternate"
}

