terraform {
  backend "http" { }
}

resource "local_file" "foo" {
    content     = "foo!"
    filename = "${path.module}/foo.bar"
}