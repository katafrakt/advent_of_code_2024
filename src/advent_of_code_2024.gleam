import gleam/io
import gleam/string
import gleam/dict
import argv
import clip
import clip/arg
import clip/flag
import simplifile

import day00/solution as day00

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
  let solution_fns = dict.from_list([
    #("00", day00.run)
  ])
  
  let fname = case ctx.is_test {
    True -> "src/day" |> string.append(ctx.day) |> string.append("/test")
    False -> "src/day" |> string.append(ctx.day) |> string.append("/input")
  }

  case simplifile.read(fname) {
    Error(_) -> panic as "File not found"
    Ok(body) -> case dict.get(solution_fns, ctx.day) {
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
