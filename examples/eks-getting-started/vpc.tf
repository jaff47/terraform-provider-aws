#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "ali" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
      "Name", "terraform-eks-ali-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "ali" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.ali.id}"

  tags = "${
    map(
      "Name", "terraform-eks-ali-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "ali" {
  vpc_id = "${aws_vpc.ali.id}"

  tags = {
    Name = "terraform-eks-ali"
  }
}

resource "aws_route_table" "ali" {
  vpc_id = "${aws_vpc.ali.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ali.id}"
  }
}

resource "aws_route_table_association" "ali" {
  count = 2

  subnet_id      = "${aws_subnet.ali.*.id[count.index]}"
  route_table_id = "${aws_route_table.ali.id}"
}
