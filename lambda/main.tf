locals {
  binary_path  = "${path.module}/tf_generated/main"
  src_path     = "${path.module}/../contact-state-keeper"
  archive_path = "${path.module}/tf_generated/contact-state-keeper.zip"
}

resource "null_resource" "function_binary" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ${local.binary_path} ${local.src_path}"
  }
}

data "archive_file" "lambda" {
  depends_on = [null_resource.function_binary]

  type        = "zip"
  source_file = local.binary_path
  output_path = local.archive_path
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = local.archive_path
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "go1.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}