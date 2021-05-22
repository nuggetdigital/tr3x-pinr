source <(curl -sSf https://raw.githubusercontent.com/chiefbiiko/bashert/v1.1.0/bashert.sh)

wd=$(dirname ${BASH_SOURCE[0]})

source $wd/../.env

stacks="$(aws cloudformation describe-stacks --stack-name $STACK_NAME)"
alb="$( \
  jq -r ".Stacks[] | select(.StackName == \"$STACK_NAME\") | .Outputs[] | select(.OutputKey == \"LoadBalancerDomainName\") | .OutputValue" <<< "$stacks" \
)"

test_add_a_file_200() {
  printf "test_add_a_file_200\n"

  resp_head=$(mktemp)
  resp_body=$(mktemp)

  curl \
    -F "file=@$wd/celesta.wav" \
    -D "$resp_head" \
    -vL# \
    "http://$alb/api/v0/add?cid-version=1&hash=blake2b-256&pin=false" \
  > $resp_body

  assert_status $resp_head 200

  cid=$(jq -r '.Hash' $resp_body)

  assert_match "$cid" '^[a-z2-7]+=*$'
  assert_equal ${#cid} 62
  assert_equal "$cid" $(<$wd/celesta.cid) 
}

test_get_a_file_200() {
  printf "test_get_a_file_200\n"
  printf "NOTE: needs to run AFTER test_add_a_file_200\n"

  resp_head=$(mktemp)
  resp_body=$(mktemp)
  cid=$(<$wd/celesta.cid)

  curl \
    -X POST \
    -D $resp_head \
    -vL# \
    http://$alb/api/v0/cat?arg=$cid \
  > $resp_body

  assert_status $resp_head 200

  assert_files_equal $resp_body $wd/celesta.wav
}

test_add_a_file_twice_200() {
  printf "NOT IMPLEMENTED: test_add_a_file_twice_200\n"
}

test_api_shield() {
   printf "NOT IMPLEMENTED: test_api_shield\n"
}