module "sqs" {
  source = "../sqs"

  aws_account_number      = var.aws_account_number
  aws_account_client      = var.aws_account_client
  aws_account_client_role = var.aws_account_client_role
}

module "sqs_fifo" {
  source = "../sqs_fifo"

  aws_account_number      = var.aws_account_number
  aws_account_client      = var.aws_account_client
  aws_account_client_role = var.aws_account_client_role
}
