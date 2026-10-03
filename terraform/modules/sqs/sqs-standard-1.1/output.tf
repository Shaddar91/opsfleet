output "sqs" {
  value = aws_sqs_queue.main
}

output "dlq" {
  value = try(aws_sqs_queue.dlq[0], null)
}

output "arn" {
  value = aws_sqs_queue.main.arn
}

output "name" {
  value = aws_sqs_queue.main.name
}

output "url" {
  value = aws_sqs_queue.main.url
}
