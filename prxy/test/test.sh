# a small test suite runnin ontop of ./up.sh invokin the prxy from localhost
# note this suite focuses the simpler client request anatomy of the prxy

source <(curl -sSf https://raw.githubusercontent.com/chiefbiiko/bashert/v1.1.0/bashert.sh)

wd=$(dirname ${BASH_SOURCE[0]})

source $wd/../../.env

test_add_a_file_200() {
  printf "test_add_a_file_200\n"

  resp_head=$(mktemp)
  resp_body=$(mktemp)

  # curl \
  #   -F "file=@$wd/celesta.wav" \
  #   -D "$resp_head" \
  #   -vL# \
  #   http://localhost:$PRXY_FROM_PORT/ \
  # > $resp_body
  curl \
    --data @$wd/celesta.wav \
    -D "$resp_head" \
    -v# \
    http://localhost:$PRXY_FROM_PORT/ \
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
    -D $resp_head \
    -v# \
    http://localhost:$PRXY_FROM_PORT/$cid \
  > $resp_body

  assert_status $resp_head 200

  assert_files_equal $resp_body $wd/celesta.wav
}

test_add_a_file_twice_200() {
  printf "NOT IMPLEMENTED: test_add_a_file_twice_200\n"
}
