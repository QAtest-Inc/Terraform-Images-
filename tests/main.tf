terraform {
  backend "http" { }
}

resource "local_file" "foo" {
  filename = "${path.module}/foo.bar"
  content = "bar!"
  directory_permission = "0755"
  file_permission = "0755"
}
