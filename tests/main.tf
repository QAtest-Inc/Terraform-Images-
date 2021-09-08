terraform {
  backend "http" {}
}

resource "local_file" "foo" {
  content  = "foo!"
  filename = "${path.module}/foo.bar"
}

resource "random_pet" "pet" {
  length = 2
}

output "pet" {
  value = random_pet.pet.id
}
