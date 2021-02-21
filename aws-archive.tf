data "archive_file" "mineddit-archive" {
  type                    = "zip"
  source_dir              = "${path.module}/mineddit"
  output_path             = "${path.module}/mineddit.zip"
}
