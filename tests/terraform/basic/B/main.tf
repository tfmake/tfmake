resource "random_id" "id" {
  keepers = {
    content = var.content
  }

  byte_length = 8
}

output "id" {
  value = random_id.id.id
}
