source <(curl -sSf https://raw.githubusercontent.com/chiefbiiko/bashert/v1.1.0/bashert.sh)

source ./.env

stacks="$(aws cloudformation describe-stacks --stack-name $STACK_NAME)"
alb="$( \
  jq -r ".Stacks[] | select(.StackName == \"$STACK_NAME\") | .Outputs[] | select(.OutputKey == \"LoadBalancerDomainName\") | .OutputValue" <<< "$stacks" \
)"
cfd="$( \
  jq -r ".Stacks[] | select(.StackName == \"$STACK_NAME\") | .Outputs[] | select(.OutputKey == \"DistributionDomainName\") | .OutputValue" <<< "$stacks" \
)"

test_add_a_file_200() {
  printf "test_add_a_file_200\n"

  resp_head=$(mktemp)
  resp_body=$(mktemp)

  curl \
    -F "file=@./fixture.wav" \
    -D "$resp_head" \
    -vL# \
    "http://$alb/api/v0/add?cid-version=1&hash=blake2b-256&pin=false" \
  > $resp_body

  assert_status $resp_head 200

  cid=$(jq -r '.Hash' $resp_body)

  assert_match "$cid" '^[a-z2-7]+=*$'

  assert_equal ${#cid} 62
}

test_get_a_file_200() {
  printf "test_get_a_file_200\n"

  printf "NOTE: test_get_a_file_200 needs to run AFTER test_add_a_file_200\n"

  resp_head=$(mktemp)
  resp_body=$(mktemp)

  lurc \
    -X GET \
    -D $resp_head \
    https://$cfd/api/v0/cat?arg=$cid \
  > $resp_body
  echo "[DBG]" && cat $resp_head && cat $resp_body && echo "[DBGEND]"
  assert_status $resp_head 200

  assert_files_equal $resp_body ./fixture.wav
}

test_add_a_file_twice_200() {
  printf "NOT IMPLEMENTED: test_add_a_file_twice_200\n"
}

test_only_api_add_exposed() {
   printf "NOT IMPLEMENTED: test_only_api_add_exposed\n"
}