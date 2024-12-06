import argv
import clip
import clip/arg
import clip/flag
import gleam/dict
import gleam/io
import gleam/string
import simplifile

import day00/solution as day00
import day01/solution as day01
import day02/solution as day02
import day03/solution as day03
import day04/solution as day04
import day05/solution as day05
import day06/solution as day06

type Context {
  Context(day: String, is_test: Bool)
}

fn command() {
  clip.command({
    use day <- clip.parameter
    use is_test <- clip.parameter

    Context(day, is_test)
  })
  |> clip.arg(arg.new("day") |> arg.help("Day"))
  |> clip.flag(flag.new("test") |> flag.help("Test"))
}

fn run_solution(ctx: Context) {
  let solution_fns =
    dict.from_list([
      #("00", day00.run),
      #("01", day01.run),
      #("02", day02.run),
      #("03", day03.run),
      #("04", day04.run),
      #("05", day05.run),
      #("06", day06.run),
    ])

  let fname = case ctx.is_test {
    True -> "src/day" |> string.append(ctx.day) |> string.append("/test")
    False -> "src/day" |> string.append(ctx.day) |> string.append("/input")
  }

  case simplifile.read(fname) {
    Error(_) -> panic as "File not found"
    Ok(body) ->
      case dict.get(solution_fns, ctx.day) {
        Error(_) -> panic as "Day not added to solution_fns"
        Ok(fun) -> fun(body)
      }
  }
}

pub fn main() {
  let result =
    command()
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(ctx) -> run_solution(ctx)
  }
}
