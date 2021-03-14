data "archive_file" "sentiment-archive" {
  type                    = "zip"
  source_dir              = "${path.module}/function"
  output_path             = "${path.module}/function.zip"
}
