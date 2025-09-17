#!/usr/bin/env bats
@test "Resolutor DNS" {
  run bash tests/dns_validate.sh
  [ -s out/dns_response.txt ]
}