with rec {
  # Duplicate of lib.concatStrings, to avoid dependency
  #
  # Type:
  #   :: [String] -> String
  concatStrings = builtins.concatStringsSep "";

  # Replace the substitutions in a replacement string with the appropriate
  # values from the captures.
  #
  # Type:
  #   :: String -> [String] -> String
  replaceCaptures = rep: captures:
    let
      subs = builtins.split ''\\([[:digit:]]+)'' rep;
      replaceGroup = group:
        if builtins.isList group
          then builtins.elemAt captures (builtins.fromJSON (builtins.head group))
          else group;
    in concatStrings (builtins.map replaceGroup subs);
};

rec {
  # Perform regex substitution on a string. For each match, run a function on
  # the resulting capture groups to determine the substitution text.
  #
  # Example:
  #   substituteWith "([[:digit:]])" (g: builtins.head g + "0") "abc123"
  #   => "abc102030"
  #
  # Type:
  #   :: Regex -> ([String] -> String) -> String -> String
  substituteWith = regex: f: str:
    let
      groups = builtins.split regex str;
      replaceGroup = group:
        if builtins.isList group
          then f group
          else group;
    in concatStrings (builtins.map replaceGroup groups);

  # Perform regex substitution on a string. If the regex contains capture
  # groups, the replacing string can refer to them with \0, \1, etc.
  #
  # Examples:
  #   substitute "[[:digit:]]" "x" "abc123"
  #   => "abcxxx"
  #
  #   substitute "([[:digit:]])([[:digit:]])" ''\1\0'' "123456"
  #   => "214365"
  #
  # Type:
  #   :: Regex -> String -> String -> String
  substitute = regex: rep:
    let substituteCaptures = replaceCaptures rep;
    in substituteWith regex substituteCaptures;
}
