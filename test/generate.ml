#use "topfind";;
#require "fmt";;
#require "re";;

let re =
  let open Re in
  compile (seq [ str "8859-"; group (rep1 digit); str ".TXT" ])

let ( / ) = Filename.concat

let make_rule database name =
  let txt_file = name in
  let number = Re.(get (exec re name) 1) |> int_of_string in
  let ml_file = Fmt.strf "iso8859_%d.ml" number in

  Fmt.strf
    "(rule \
      ((targets (%s))
       (deps (%s))
       (action (run ${exe:../src/uuuui.exe} %s %s))))"
    ml_file (database / txt_file) (database / txt_file) ml_file

let error () =
  Fmt.invalid_arg "Invalid argument, expected folder database and output file: \
                   %s --database <folder> -o <output>" Sys.argv.(1)

let () =
  let database, output =
    try
      match Sys.argv with
      | [| _; "--database"; folder; "-o"; output; |] -> folder, output
      | _ -> error ()
    with _ -> error () in

  let files = Array.to_list (Sys.readdir database) in
  let out = open_out output |> Format.formatter_of_out_channel in

  List.map (make_rule database) files |> List.iter (Fmt.(pf out) "%s\n\n%!")

