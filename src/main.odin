package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	file, file_error := os.open("../barely_src/test01.barely")

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


	// need to remove remaining "" empty strings
	for line in lines {

		if len(line) == 0 do continue

		opcode, _, instruction := strings.partition(line, " ")

		fmt.printf(
			"opcode: %s\ninstructions: %s\n\n",
			opcode,
			"<none given>" if len(instruction) == 0 else instruction,
		)


	}

}
