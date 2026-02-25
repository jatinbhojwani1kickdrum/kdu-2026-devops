locals {
  common_tags = {
    Environment = var.environment
    Creator     = var.creator
    Project     = var.name_prefix
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-${var.environment}-bastion"
  })
}


# Launch Template for Application Servers
resource "aws_launch_template" "app" {
  name_prefix   = "${var.name_prefix}-${var.environment}-app-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.app_sg_id]


user_data = base64encode(<<-EOF
#!/bin/bash
set -e

yum update -y
yum install -y docker git
systemctl enable docker
systemctl start docker

DB_HOST="${var.db_endpoint}"
DB_USER="${var.db_username}"
DB_PASS="${var.db_password}"

mkdir -p /opt/app
cd /opt/app

rm -rf frontend backend1 backend2 || true
git clone ${var.frontend_repo} frontend
git clone ${var.backend1_repo} backend1
git clone ${var.backend2_repo} backend2

# Dockerfile for FRONTEND
cat > /opt/app/frontend/Dockerfile << 'DF'
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DF

# Function to create backend Dockerfile
create_backend_dockerfile() {
  TARGET_DIR="$1"
  cat > $TARGET_DIR/Dockerfile << 'DF'
FROM gradle:8-jdk17 AS build
WORKDIR /home/gradle/project
COPY . .
RUN gradle clean build -x test

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /home/gradle/project/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
DF
}

create_backend_dockerfile /opt/app/backend1
create_backend_dockerfile /opt/app/backend2

docker build -t kdu-frontend:latest /opt/app/frontend
docker build -t kdu-backend1:latest /opt/app/backend1
docker build -t kdu-backend2:latest /opt/app/backend2

docker rm -f kdu-frontend kdu-backend1 kdu-backend2 || true

docker run -d --restart=always --name kdu-frontend -p 80:80 kdu-frontend:latest

docker run -d --restart=always --name kdu-backend1 -p 8080:8080 \
  -e SPRING_DATASOURCE_USERNAME="$DB_USER" \
  -e SPRING_DATASOURCE_PASSWORD="$DB_PASS" \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://$DB_HOST:3306/company?createDatabaseIfNotExist=true&characterEncoding=UTF-8&useUnicode=true&useSSL=false&allowPublicKeyRetrieval=true" \
  -e FEIGN_CLIENT_NAME=localhost \
  -e FEIGN_CLIENT_URL=http://localhost:8081 \
  kdu-backend1:latest

docker run -d --restart=always --name kdu-backend2 -p 8081:8080 \
  -e SPRING_DATASOURCE_USERNAME="$DB_USER" \
  -e SPRING_DATASOURCE_PASSWORD="$DB_PASS" \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://$DB_HOST:3306/company?createDatabaseIfNotExist=true&characterEncoding=UTF-8&useUnicode=true&useSSL=false&allowPublicKeyRetrieval=true" \
  kdu-backend2:latest
EOF
)
  
  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, {
      Name = "${var.name_prefix}-${var.environment}-app"
    })
  }
}



# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                      = "${var.name_prefix}-${var.environment}-asg"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  vpc_zone_identifier       = var.app_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-${var.environment}-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.name_prefix}-${var.environment}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}


resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.name_prefix}-${var.environment}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.name_prefix}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}


resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.name_prefix}-${var.environment}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}