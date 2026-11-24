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

module "example_context" {
  source     = "git::https://github.com/raringgroup/terraform-null-context.git?ref=v0.1.0"
  context    = module.context.self
  attributes = []
}

locals {
  eventbus_name = "domain"
}
data "aws_iam_policy_document" "eventbus_policy" {
  count = module.example_context.enabled ? 1 : 0
  statement {
    sid    = "DevAccountAccess"
    effect = "Allow"
    actions = [
      "events:PutEvents",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [local.account_id]
    }
  }
}

module "eventbus" {
  source  = "../../"
  context = module.example_context.self

  eventbus_name      = local.eventbus_name
  kms_key_identifier = module.eventbus_kms_key.key_arn
  policy_document    = try(data.aws_iam_policy_document.eventbus_policy[0].json, "")
}
