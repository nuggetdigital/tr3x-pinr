stack_exists() { # $stack_name
  aws cloudformation describe-stacks --stack-name $1 >/dev/null 2>&1
}