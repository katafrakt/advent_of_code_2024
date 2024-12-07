import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils/utils

type Equation {
  Equation(target_value: Int, partial_value: Int, numbers_to_process: List(Int))
}

fn parse_line(line) {
  case string.split(line, ": ") {
    [p1, p2] -> {
      let target = utils.str_to_int(p1)
      let nums =
        string.split(p2, " ")
        |> list.map(utils.str_to_int)

      case nums {
        [hd, ..tail] ->
          Equation(
            target_value: target,
            partial_value: hd,
            numbers_to_process: tail,
          )
        _ -> panic as "Incorrect input"
      }
    }
    _ -> panic as "Incorrect format"
  }
}

fn can_achieve_target(equation: Equation, with_cat: Bool) -> Bool {
  case equation.numbers_to_process {
    [] -> equation.partial_value == equation.target_value
    [hd, ..tail] -> {
      let base = [
        Equation(
          ..equation,
          partial_value: equation.partial_value + hd,
          numbers_to_process: tail,
        ),
        Equation(
          ..equation,
          partial_value: equation.partial_value * hd,
          numbers_to_process: tail,
        ),
      ]

      let variants = case with_cat {
        False -> base
        True ->
          list.prepend(
            base,
            Equation(
              ..equation,
              partial_value: cat(equation.partial_value, hd),
              numbers_to_process: tail,
            ),
          )
      }

      variants
      |> list.map(fn(i) { can_achieve_target(i, with_cat) })
      |> list.any(fn(v) { v })
    }
  }
}

fn cat(n1, n2) {
  let str1 = int.to_string(n1)
  let str2 = int.to_string(n2)
  string.append(str1, str2)
  |> utils.str_to_int
}

pub fn run(input) {
  let equations =
    input
    |> string.split("\n")
    |> list.filter(fn(l) { l != "" })
    |> list.map(parse_line)

  // part 1
  equations
  |> list.filter(fn(l) { can_achieve_target(l, False) })
  |> list.fold(0, fn(acc, l) { acc + l.target_value })
  |> io.debug()

  //part 2
  equations
  |> list.filter(fn(l) { can_achieve_target(l, True) })
  |> list.fold(0, fn(acc, l) { acc + l.target_value })
  |> io.debug()

  Nil
}
