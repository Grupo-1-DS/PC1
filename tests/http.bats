#!/usr/bin/env bats
@test "Respuesta HTTP 200" {
  run bash tests/http_validate.sh
  [ -f out/http_code.txt ]
  grep -q 200 out/http_code.txt
}
