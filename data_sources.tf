# reads the pfx
data "local_file" "certificate_pfx" {
  filename = "./certificate/certificate.pfx"

  depends_on = [
    null_resource.crt2pfx
  ]
}
# data "local_file" "certificate_crt" {
#   filename = "./cert/certificate.crt"
# }

# # writes the private key to a temp file.
# data "local_file" "private_key_crt" {
#   filename = "./cert/private.key"
# }
