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


module "event_bus_context" {
  source     = "git::https://github.com/raringgroup/terraform-null-context.git?ref=v0.1.0"
  context    = module.context.self
  attributes = ["eventbus"]
}

resource "aws_cloudwatch_event_bus" "event_bus" {
  count = module.event_bus_context.enabled ? 1 : 0

  name               = module.event_bus_context.id
  kms_key_identifier = var.kms_key_identifier
  event_source_name  = var.event_source_name

  tags = module.event_bus_context.tags
}

resource "aws_cloudwatch_event_bus_policy" "event_bus_policy" {
  count          = module.context.enabled && var.policy_document != null ? 1 : 0
  policy         = var.policy_document
  event_bus_name = try(aws_cloudwatch_event_bus.event_bus[0].name, "")
}
