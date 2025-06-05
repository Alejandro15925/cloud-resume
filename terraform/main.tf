module "front_end" {
  source = "./modules/front-end"
}


# Referencing back-end module
module "back-end" {
  source = "./modules/back-end"
}

module "monitoring" {
  source = "./modules/monitoring"
}
