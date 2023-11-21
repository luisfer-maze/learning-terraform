locals {
  binary_path = "../contact-state-keeper/main"
  src_path    = "../contact-state-keeper"
}

resource "null_resource" "function_binary" {
  provisioner "local-exec" {
    command = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ${local.binary_path} ${local.src_path}"
  }
}

data "archive_file" "lambda" {
  depends_on = [null_resource.function_binary]

  type        = "zip"
  source_file = "../contact-state-keeper/main"
  output_path = "${path.module}/contact-state-keeper.zip"
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
  filename      = "contact-state-keeper.zip"
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