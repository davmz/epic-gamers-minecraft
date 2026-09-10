resource "aws_vpc" "this" {
  cidr_block           = var.CIDR_BLOCK
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.TAGS,
    {
      Name = var.NAME
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.TAGS,
    {
      Name = "${var.NAME}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  for_each = var.PUBLIC_SUBNETS

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    var.TAGS,
    {
      Name                     = "${var.NAME}-public-${each.key}"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = var.PRIVATE_SUBNETS

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.TAGS,
    {
      Name                              = "${var.NAME}-private-${each.key}"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.TAGS,
    {
      Name = "${var.NAME}-public-rt"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count = var.ENABLE_NAT_GATEWAY ? 1 : 0

  domain = "vpc"

  tags = merge(
    var.TAGS,
    {
      Name = "${var.NAME}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "this" {
  count = var.ENABLE_NAT_GATEWAY ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.public)[0].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(
    var.TAGS,
    {
      Name = "${var.NAME}-nat"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.TAGS,
    {
      Name = "${var.NAME}-private-rt"
    }
  )
}

resource "aws_route" "private_nat" {
  count = var.ENABLE_NAT_GATEWAY ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}