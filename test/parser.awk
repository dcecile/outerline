@use("../src/parser")
@use("../src/pretty")
@use("./check")

@check("basic elements parse", \
  expr) \
{
  check_matches( \
    pretty_print(parse_text("(aa;(d)),ccc;bb")), \
    "(list," NL \
    "  (rec;" NL \
    "    type, block;" NL \
    "    args," NL \
    "      (rec;" NL \
    "        type, call;" NL \
    "        call," NL \
    "          (rec;" NL \
    "            type, block;" NL \
    "            args," NL \
    "              (rec;" NL \
    "                type, string;" NL \
    "                string, aa))," NL \
    "          (rec;" NL \
    "            type, block;" NL \
    "            args," NL \
    "              (rec;" NL \
    "                type, call;" NL \
    "                call," NL \
    "                  (rec;" NL \
    "                    type, block;" NL \
    "                    args," NL \
    "                      (rec;" NL \
    "                        type, string;" NL \
    "                        string, d)))))," NL \
    "      (rec;" NL \
    "        type, string;" NL \
    "        string, ccc))," NL \
    "  (rec;" NL \
    "    type, block;" NL \
    "    args," NL \
    "      (rec;" NL \
    "        type, string;" NL \
    "        string, bb)))")
}

@check("basic elements parse with whitespace", \
  expr) \
{
  check_matches( \
    pretty_print(parse_text( \
      "  " NL \
      " ( " NL \
      "  aa ; " NL \
      "  (  d  " NL \
      ") )" NL \
      "  " NL \
      "" NL \
      " , " NL \
      "  ccc    " NL \
      " ;" NL \
      "  bb" NL \
      "" NL \
      " ")), \
    "(list," NL \
    "  (rec;" NL \
    "    type, block;" NL \
    "    args," NL \
    "      (rec;" NL \
    "        type, call;" NL \
    "        call," NL \
    "          (rec;" NL \
    "            type, block;" NL \
    "            args," NL \
    "              (rec;" NL \
    "                type, string;" NL \
    "                string, aa))," NL \
    "          (rec;" NL \
    "            type, block;" NL \
    "            args," NL \
    "              (rec;" NL \
    "                type, call;" NL \
    "                call," NL \
    "                  (rec;" NL \
    "                    type, block;" NL \
    "                    args," NL \
    "                      (rec;" NL \
    "                        type, string;" NL \
    "                        string, d)))))," NL \
    "      (rec;" NL \
    "        type, string;" NL \
    "        string, ccc))," NL \
    "  (rec;" NL \
    "    type, block;" NL \
    "    args," NL \
    "      (rec;" NL \
    "        type, string;" NL \
    "        string, bb)))")
}

@check("empty argument parse", \
  expr) \
{
  check_matches( \
    pretty_print(parse_text("(cat; , x, ();)")), \
    "(list," NL \
    "  (rec;" NL \
    "    type, block;" NL \
    "    args," NL \
    "      (rec;" NL \
    "        type, call;" NL \
    "        call," NL \
    "          (rec;" NL \
    "            type, block;" NL \
    "            args," NL \
    "              (rec;" NL \
    "                type, string;" NL \
    "                string, cat))," NL \
    "          (rec;" NL \
    "            type, block;" NL \
    "            args," NL \
    "              (rec;" NL \
    "                type, string;" NL \
    "                string, )," NL \
    "              (rec;" NL \
    "                type, string;" NL \
    "                string, x)," NL \
    "              (rec;" NL \
    "                type, call;" NL \
    "                call," NL \
    "                  (rec;" NL \
    "                    type, block;" NL \
    "                    args," NL \
    "                      (rec;" NL \
    "                        type, string;" NL \
    "                        string, ))))," NL \
    "          (rec;" NL \
    "            type, block;" NL \
    "            args," NL \
    "              (rec;" NL \
    "                type, string;" NL \
    "                string, )))))")
}

