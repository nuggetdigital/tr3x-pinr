source ./.env
source <(curl -sSf https://raw.githubusercontent.com/chiefbiiko/bashert/v1.0.1/bashert.sh)

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

  echo "[DEBUG] http://$alb/api/v0/add?pin=false"

  curl \
    --progress-bar \
    -X POST \
    -F "file=@./fixture.wav" \
    -D "$resp_head" \
    -fL \
    http://$alb/api/v0/add?pin=false \
  > $resp_body
  cat $resp_body
  assert_status $resp_head 200

  cid=$(jq -r '.Hash' $resp_body)

  assert_match "$cid" '^[a-z2-7]+=*$'
  assert_equal ${#cid} 46
}
