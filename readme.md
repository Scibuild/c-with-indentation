# C with indents

My friend told me the problem he had with C was the lack of indentation based syntax.

So I made their dream a reality.

## How to build

The only dependency is the zig compiler. Build with `zig build -Drelease-safe=true` and find the executable in `zig-out/bin/c-with-indents`.

## Usage

Although branded as *C with indents* there is no requirement to use C, any language with `{..}` style code blocks should work. 

To use, make sure to include the line `#tabsize <number>` at the top of any file with the specified width of a tab. This most likely wants to be 4, which allows for multi-line expressions when the indentation is less than 4. Examples can be found in the `examples/` directory. Run the executable with a single path to a file as its only argument.


