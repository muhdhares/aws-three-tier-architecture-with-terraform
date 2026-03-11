# Generating a Secret for RDS using the random provider and storing it in AWS Secrets Manager, with the secret string containing the database username and the generated password in JSON format.

resource "random_password" "rds_random_password" {
  length  = var.password_length
  special = false
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = var.name_of_secret
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.rds_random_password.result
  })
}
