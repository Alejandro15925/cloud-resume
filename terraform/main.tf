module "front_end" {
  source = "./modules/front-end"
}


# Referencing back-end module
module "back-end" {
  source = "./modules/back-end"
}

module "monitoring" {
  source               = "./modules/monitoring"
  alert_email          = "Alejandro953504@gmail.com"
  alert_sms            = "+522221437364"
  lambda_function_name = module.back-end.lambda_function_name
}



