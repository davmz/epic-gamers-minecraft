variable "NAME" {
  description = "Name used for Discord bot AWS resources"
  type        = string
}

variable "TAGS" {
  description = "Tags applied to supported AWS resources"
  type        = map(string)
}