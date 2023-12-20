resource "aws_iam_user" "lb" {
  name = "Natalie"

}

resource "aws_iam_user" "lb2" {
  name = "Kaizen"

}

resource "aws_iam_user" "lb3" {
  name = "Hello"

}

resource "aws_iam_user" "lb4" {
  name = "World"

}

resource "aws_iam_group" "devops" {
  name = "DevOps"
}

resource "aws_iam_group" "devops1" {
  name = "QA"
}

resource "aws_iam_group_membership" "team" {
  name = "tf-testing-group-membership"

  users = [
    aws_iam_user.lb.name,
    aws_iam_user.lb2.name,
  ]

  group = aws_iam_group.devops.name
}

resource "aws_iam_group_membership" "team2" {
  name = "tf-testing-group-membership"

  users = [
    aws_iam_user.lb3.name,
    aws_iam_user.lb4.name,
  ]

  group = aws_iam_group.devops1.name
}

resource "aws_iam_user" "lb5" {
  name = "Admin"

}

output name {
    value = aws_iam_user.lb
}

output unique_id {
    value = aws_iam_user.lb2.unique_id
}
