package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"


BUFFER_SIZE :: 1024

Stack :: [dynamic]i64

stack_push :: #force_inline proc(stack: ^Stack, element: i64) {
	append(stack, element)
}

// pops an element off the stack, return nil , false if the stack is empty
stack_pop :: proc(stack: ^Stack) -> (Maybe(i64), bool) {

	if len(stack) == 0 do return nil, false

	return pop(stack), true


}

// attempts to pop two elements off the stack and return nil , nil , false if the stack is too short
//
// note: due to stack behavior, b is the first popped item and a is the second
// though, the function in question returns them in the correct order of their appendment
stack_attempt_pop_twice :: proc(stack: ^Stack) -> (Maybe(i64), Maybe(i64), bool) {

	if len(stack) < 2 do return nil, nil, false

	b, _ := stack_pop(stack)
	a, _ := stack_pop(stack)

	return a, b, true

}

main :: proc() {

	if len(os.args) == 1 {
		fmt.println("Usage: ./bac <barely-source>")
		os.exit(-1)
	}


	file_handle := os.args[1]

	file, file_error := os.open(file_handle)

	if file_error != os.ERROR_NONE {
		fmt.println("cannot find barely-lang src(s) ")
		os.exit(-1)
	}

	defer os.close(file)

	source_code, read_error := os.read_entire_file_from_file(file, context.allocator)

	if read_error != os.ERROR_NONE {
		fmt.println("could not read barely-lang src(s)")
		os.exit(-1)
	}

	source := string(source_code)


	fmt.println(source)

	fmt.println("------------------------")


	lines, _ := strings.split_lines(source)

	stack: Stack = {}
	jump_to_label: string


	for line, line_number in lines {


		if len(line) == 0 do continue

		opcode, _, instruction := strings.partition(line, " ")

		fmt.printf(
			"opcode: %s\ninstructions: %s\n\n",
			opcode,
			"<none given>" if len(instruction) == 0 else instruction,
		)

		if jump_to_label != "" {
			if (strings.has_suffix(opcode, ":")) {

				label, ok := strings.substring(opcode, 0, len(opcode) - 1)

				if !ok || label == "" {
					fmt.printf("invalid label at line number %u", line_number)
					os.exit(-1)
				}

				if label == jump_to_label do jump_to_label = ""
			}
		}

		if opcode == "PUSH" {
			number, ok := strconv.parse_i64(instruction)

			if !ok {
				fmt.printf("error whilst parsing read data (must be a valid integer)")
				os.exit(-1)
			}

			fmt.println(number)

			stack_push(&stack, number)

		} else if opcode == "READ" {
			buffer: [BUFFER_SIZE]byte
			byte_read, err := os.read(os.stdin, buffer[:])

			if err != os.ERROR_NONE {
				fmt.printf("could not read from stdin")
				os.exit(-1)
			}

			fmt.println(buffer[:(byte_read - 1)])

			number, ok := strconv.parse_i64(string(buffer[:(byte_read - 1)]))

			if !ok {
				fmt.printf("error whilst parsing read data (must be a valid integer)")
				os.exit(-1)
			}

			fmt.println(number)

			stack_push(&stack, number)

		} else if opcode == "SUB" {

			a, b, ok := stack_attempt_pop_twice(&stack)

			if !ok {
				fmt.println("cannot subtract whilst stack has not enough elements")
				os.exit(-1)
			}


			c := a.(i64) - b.(i64)
			fmt.printf("result: %d\n", c)
			stack_push(&stack, c)

		} else if opcode == "JUMP.EQ.0" {

			a, ok := stack_pop(&stack)

			if !ok {
				fmt.println("stack is empty")
				os.exit(-1)
			}


			if a == 0 {

				if len(instruction) == 0 {
					fmt.println(
						"label not found in JUMP instruction at line number %u",
						line_number + 1,
					)
					os.exit(-1)
				}

				jump_to_label = instruction

			} else {
				fmt.println("<debug>JUMP DID NOT SUCCEED</debug>\n")
				continue
			}

		} else if opcode == "PRINT" {

			if len(instruction) == 0 {
				fmt.println(
					"expected message for PRINT instruction at line number %u",
					line_number + 1,
				)
				os.exit(-1)
			}

			fmt.printfln("message: %s\n", instruction)
		} else if opcode == "HALT" do return
	}

}
