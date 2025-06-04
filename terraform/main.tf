module "front_end" {
  source = "./modules/front-end"
}

module "back_end" {
  source = "./modules/back-end"
}

module "monitoring" {
  source = "./modules/monitoring"
}
