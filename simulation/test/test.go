// test.go
package main

import (
	"encoding/json"

	xtptest "github.com/dylibso/xtp-test-go"
)

func callOnEmail(input []byte) {
	output := xtptest.CallString("onEmail", input)
	xtptest.AssertNe("we got some output", "", output)
	var res int32
	err := json.Unmarshal([]byte(output), &res)
	xtptest.AssertEq("unmarshalling json", nil, err)
	if err != nil {
		xtptest.AssertEq("output", "", output)
	}
}

//go:export test
func test() int32 {

	xtptest.Group("Test with Deliver and Reply both succeeding", func() {
		input := []byte(`{
			"headers":{"Subject":"simulation00"},
			"body":"What body?",
			"sender":"a@example.com","receiver":"b@example.com"
		}`)
		callOnEmail(input)
	})
	xtptest.Group("Test with Deliver and Reply both failing", func() {
		input := []byte(`{
			"headers":{"Subject":"simulation11"},
			"body":"What body?",
			"sender":"a@example.com","receiver":"b@example.com"
		}`)
		callOnEmail(input)
	})
	xtptest.Group("Test with Deliver succeeding and Reply failing", func() {
		input := []byte(`{
			"headers":{"Subject":"simulation01"},
			"body":"What body?",
			"sender":"a@example.com","receiver":"b@example.com"
		}`)
		callOnEmail(input)
	})
	xtptest.Group("Test with Deliver failing and Reply succeeding", func() {
		input := []byte(`{
			"headers":{"Subject":"simulation10"},
			"body":"What body?",
			"sender":"a@example.com","receiver":"b@example.com"
		}`)
		callOnEmail(input)
	})
	xtptest.Group("Test without Subject header", func() {
		input := []byte(`{
			"headers":{},
			"body":"What body?",
			"sender":"a@example.com","receiver":"b@example.com"
		}`)
		callOnEmail(input)
	})
	return 0
}

func main() {
}
