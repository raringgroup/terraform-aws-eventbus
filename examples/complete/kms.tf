## ----------------------------------------------------------------------------
## Copyright 2026 Raring Group LLC
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ----------------------------------------------------------------------------

data "aws_iam_policy_document" "kms_policy" {
  count = module.example_context.enabled ? 1 : 0
  statement {
    sid    = "RootUserPermission"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${local.arn_prefix}:iam::${local.account_id}:root"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:Encrypt"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:Encrypt"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = ["${local.arn_prefix}:events:${local.region}:${local.account_id}:event-bus/${local.eventbus_name}"]
    }
  }
}

module "eventbus_kms_key" {
  source     = "git::https://github.com/raringgroup/terraform-aws-kms-key.git?ref=v0.1.0"
  context    = module.example_context.self
  attributes = ["kms", "key"]

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "KMS key for ${module.example_context.id}"
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
  policy                   = try(data.aws_iam_policy_document.kms_policy[0].json, "")
}
