data "archive_file" "removalwatch-archive" {
  type                    = "zip"
  source_dir              = "${path.module}/function"
  output_path             = "${path.module}/function.zip"
}
