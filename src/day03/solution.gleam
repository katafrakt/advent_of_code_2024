import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

type ParserMode {
  Nada
  M
  U
  L
  D
  O
  N
  T
  Apostrophe
  LPARENMUL
  LParenDo
  LParenDont
  Comma
  Num1
  Num2
}

type Parser {
  Parser(
    mode: ParserMode,
    num1: Option(Int),
    num2: Option(Int),
    sum: Int,
    active: Bool,
  )
}

fn process(chars: List(String)) -> Int {
  let parser = Parser(mode: Nada, num1: None, num2: None, sum: 0, active: True)
  list.fold(chars, parser, parser_step).sum
}

fn parser_step(parser: Parser, char: String) -> Parser {
  let reset_parser = fn() {
    Parser(..parser, mode: Nada, num1: None, num2: None)
  }
  case char, parser.mode {
    "m", _ -> Parser(..parser, mode: M)
    "u", M -> Parser(..parser, mode: U)
    "l", U -> Parser(..parser, mode: L)
    "(", L -> Parser(..parser, mode: LPARENMUL)
    c, LPARENMUL -> {
      case int.parse(c) {
        Ok(n) -> process_num1(parser, n)
        Error(_) -> reset_parser()
      }
    }
    ",", Num1 -> Parser(..parser, mode: Comma)
    c, Num1 -> {
      case int.parse(c) {
        Ok(n) -> process_num1(parser, n)
        Error(_) -> reset_parser()
      }
    }
    c, Comma -> {
      case int.parse(c) {
        Ok(n) -> process_num2(parser, n)
        Error(_) -> reset_parser()
      }
    }
    ")", Num2 -> {
      let num1 = parser.num1 |> option.unwrap(0)
      let num2 = parser.num2 |> option.unwrap(0)
      let to_add = num1 * num2
      case parser.active {
        True -> Parser(..reset_parser(), sum: parser.sum + to_add)
        False -> reset_parser()
      }
    }
    c, Num2 -> {
      case int.parse(c) {
        Ok(n) -> process_num2(parser, n)
        Error(_) -> reset_parser()
      }
    }
    "d", _ -> Parser(..parser, mode: D)
    "o", D -> Parser(..parser, mode: O)
    "n", O -> Parser(..parser, mode: N)
    "'", N -> Parser(..parser, mode: Apostrophe)
    "t", Apostrophe -> Parser(..parser, mode: T)
    "(", T -> Parser(..parser, mode: LParenDont)
    "(", O -> Parser(..parser, mode: LParenDo)
    ")", LParenDo -> Parser(..parser, active: True)
    ")", LParenDont -> Parser(..parser, active: False)
    _, _ -> reset_parser()
  }
}

fn process_num1(parser: Parser, num: Int) {
  case parser.num1 {
    Some(x) -> Parser(..parser, num1: Some(x * 10 + num), mode: Num1)
    None -> Parser(..parser, num1: Some(num), mode: Num1)
  }
}

fn process_num2(parser: Parser, num: Int) {
  case parser.num2 {
    Some(x) -> Parser(..parser, num2: Some(x * 10 + num), mode: Num2)
    None -> Parser(..parser, num2: Some(num), mode: Num2)
  }
}

pub fn run(input) {
  input
  |> string.to_graphemes()
  |> process()
  |> io.debug()

  Nil
}
