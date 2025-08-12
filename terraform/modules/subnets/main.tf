locals {
  private_subnet_map = {
    for idx, cidr in var.private_subnet_cidrs : idx => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-igw"
      Role = "network"
    }
  )
}

resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-${var.azs[0]}"
      Role = "public"
    }
  )
}

resource "aws_subnet" "private" {
  for_each                = local.private_subnet_map
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-${each.value.az}"
      Role = "private"
    }
  )
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nat-eip"
      Role = "network"
    }
  )
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nat"
      Role = "network"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-rt"
      Role = "network"
    }
  )
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-rt"
      Role = "network"
    }
  )
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

