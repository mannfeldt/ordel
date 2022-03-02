class Constants {
  static const int multiplayerRounds = 3;
  static const double boxMargin = 4;
  static const double keyMargin = 2;
  static const double horizontalPadding = 30;
  static const double minKeyboardKeySize = 30;
  static const List<String> ADJECTIVE = [
    "ny",
    "rå",
    "yr",
    "öm",
    "arg",
    "blå",
    "bra",
    "dov",
    "dum",
    "dyr",
    "död",
    "döv",
    "fel",
    "feg",
    "fet",
    "fin",
    "fri",
    "ful",
    "god",
    "grå",
    "gul",
    "hal",
    "hel",
    "hes",
    "het",
    "hög",
    "kal",
    "kry",
    "kul",
    "kåt",
    "kär",
    "lam",
    "lat",
    "len",
    "lik",
    "loj",
    "lös",
    "mer",
    "mör",
    "ont",
    "ond",
    "rak",
    "rar",
    "ren",
    "rik",
    "rät",
    "röd",
    "seg",
    "slö",
    "små",
    "sne",
    "sur",
    "söt",
    "tam",
    "tom",
    "tät",
    "ung",
    "vag",
    "van",
    "vid",
    "vig",
    "vis",
    "vit",
    "våt",
    "öde"
  ];
  static const List<String> NOUNS = [
    "as",
    "by",
    "bo",
    "ek",
    "fä",
    "is",
    "hö",
    "kö",
    "ro",
    "te",
    "tå",
    "vy",
    "wc",
    "ål",
    "år",
    "öl",
    "alg",
    "and",
    "apa",
    "arv",
    "bal",
    "ben",
    "bas",
    "bil",
    "bio",
    "bit",
    "bly",
    "bod",
    "boj",
    "bok",
    "bom",
    "bot",
    "box",
    "bov",
    "bro",
    "bud",
    "buk",
    "bur",
    "bus",
    "båt",
    "bär",
    "bön",
    "dag",
    "dal",
    "dam",
    "deg",
    "duk",
    "dyn",
    "ego",
    "eka",
    "eld",
    "eko",
    "fan",
    "far",
    "fas",
    "fat",
    "fik",
    "fia",
    "fot",
    "fru",
    "frö",
    "fyr",
    "får",
    "föl",
    "gap",
    "gas",
    "gem",
    "get",
    "gås",
    "gök",
    "gös",
    "haj",
    "hat",
    "hav",
    "hem",
    "hoj",
    "hop",
    "hot",
    "hov",
    "hud",
    "hus",
    "hål",
    "hår",
    "håv",
    "hök",
    "ide",
    "jet",
    "jox",
    "jul",
    "kaj",
    "kam",
    "klo",
    "knä",
    "kod",
    "kol",
    "kor",
    "ko",
    "kub",
    "kuk",
    "kyl",
    "kåk",
    "kål",
    "käk",
    "kök",
    "käx",
    "kön",
    "lag",
    "kör",
    "lax",
    "lek",
    "lem",
    "lie",
    "lim",
    "liv",
    "lok",
    "lov",
    "lur",
    "lus",
    "lut",
    "lya",
    "lyx",
    "lår",
    "låt",
    "lök",
    "lön",
    "löv",
    "maj",
    "mat",
    "mes",
    "mil",
    "mix",
    "mor",
    "mos",
    "mun",
    "mus",
    "mur",
    "myt",
    "mål",
    "mås",
    "nos",
    "nys",
    "nöt",
    "ord",
    "ork",
    "orm",
    "ort",
    "ost",
    "paj",
    "pip",
    "pop",
    "pol",
    "pys",
    "rap",
    "ras",
    "rea",
    "rim",
    "ris",
    "rom",
    "rop",
    "ros",
    "rus",
    "rån",
    "räv",
    "röv",
    "sax",
    "sed",
    "sjö",
    "snö",
    "sol",
    "son",
    "spö",
    "sås",
    "säd",
    "säl",
    "tak",
    "tax",
    "tik",
    "toa",
    "tok",
    "tur",
    "tåg",
    "ugn",
    "val",
    "vax",
    "ved",
    "vev",
    "vin",
    "våg",
    "väg",
    "yxa",
    "zon",
    "zoo",
    "ägg",
    "älg",
  ];
}

class LocalStorageKeys {
  static const String ACTIVE_USER = "active_user";
  static const String ACTIVE_USER_FRIENDS = "active_user_friends";
  static const String LAST_LOGGED_IN_VERSION = "last_logged_in_version";
  static const String LANGUAGE = "language";
  static const String USERS = "users";
  static const String ANON_GAMES = "anon_games";
  static const String SINGLEPLAYER_GAMES = "singleplayer_games";
}

class CloudFunctionName {
  static const String GAME_INVITE = "newGameInvitePush";
  static const String NEXT_TURN = "nextTurnPush";
  static const String ACCEPT_GAME_INVITE = "acceptedGameInvitePush";
  static const String DECLINE_GAME_INVITE = "declinedGameInvitePush";
  static const String DECLINE_DELETE_GAME_INVITE =
      "declinedGameInviteDeletePush";
  static const String NEW_FOLLOWER = "newFollowerPush";
  static const String GAME_FINISHED = "gameFinishedPush";
}
