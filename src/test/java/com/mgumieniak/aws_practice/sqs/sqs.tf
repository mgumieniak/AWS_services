variable "aws_account_number" {}
variable "aws_account_client" {}
variable "aws_account_client_role" {}

resource "aws_kms_key" "mgumieniak_sqs_key" {
  description             = "KMS for sqs"
  deletion_window_in_days = 7
  tags = {
    environment = "dev"
  }
  policy                  = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${var.aws_account_number}:root",
            "arn:aws:iam::${var.aws_account_number}:user/terraform",
            "arn:aws:iam::${var.aws_account_number}:user/maciej"
          ]
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "webapp_clients permissions for encryption and decryption",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_number}:role/${var.aws_account_client_role}",
        },
        "Action" : [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "sqs_client_policy" {
  queue_url = aws_sqs_queue.sqs.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "SQS permissions for producer",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_number}:role/${var.aws_account_client_role}"
        },
        "Action" : [
          "sqs:SendMessage",
        ],
        "Resource" : aws_sqs_queue.sqs.arn,
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "true"
          }
        }
      },
      {
        "Sid" : "SQS permissions for consumer",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_number}:role/${var.aws_account_client_role}"
        },
        "Action" : [
          "sqs:DeleteMessage",
          "sqs:ReceiveMessage"
        ],
        "Resource" : aws_sqs_queue.sqs.arn,
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "true"
          }
        }
      }
    ]
  })
}


resource "aws_sqs_queue" "sqs" {
  name                      = var.sqs_name
  delay_seconds             = 0
  max_message_size          = 262144 # 256 KiB
  message_retention_seconds = 1209600 # 14 days

  # set the visibility timeout to the maximum time that it takes your application to process and delete a message from the queue
  visibility_timeout_seconds = 5

  receive_wait_time_seconds  = 20 # 20s long polling - be aware of the timeout!

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_dlq.arn
    maxReceiveCount     = 3
  })

  kms_master_key_id                 = aws_kms_key.mgumieniak_sqs_key.key_id
  kms_data_key_reuse_period_seconds = 86400

  tags = {
    environment = "dev"
  }
}
